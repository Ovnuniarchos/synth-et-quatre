extends Waveform
class_name NodeWave

const WAVE_TYPE:String="Node"


var size_po2:int=8 setget set_size_po2
var components:Array
var output:OutputNodeComponent


func _init()->void:
	name=tr("DEFN_NODE_WAVE")
	output=OutputNodeComponent.new()
	output.wave=weakref(self)
	components=[output]
	data=output.output
	resize_data(1<<size_po2)


func set_size_po2(s:int)->void:
	size_po2=int(clamp(s,4.0,16.0))
	size=1<<size_po2
	for c in components:
		c.set_size_po2(size_po2)


func calculate()->void:
	data=output.calculate()


func duplicate()->Waveform:
	var nw:NodeWave=.duplicate() as NodeWave
	nw.size_po2=size_po2
	nw.components=[]
	for c in components:
		var nc:WaveNodeComponent=c.duplicate(nw)
		nw.components.append(nc)
		if nc is OutputNodeComponent:
			nw.output=nc
	for nc in nw.components:
		nc.post_duplicate()
	nw.calculate()
	return nw


func copy(from:Waveform,full:bool=false)->void:
	if from.WAVE_TYPE==WAVE_TYPE:
		.copy(from,full)
		size_po2=from.size_po2
		components=[]
		for c in from.components:
			var nc:WaveNodeComponent=c.duplicate(self)
			components.append(nc)
			if nc is OutputNodeComponent:
				output=nc
		for comp in components:
			comp.post_duplicate()
		calculate()


func equals(other:Waveform)->bool:
	if not .equals(other):
		return false
	if other.components.size()!=components.size():
		return false
	for i in components:
		var found:bool=false
		for j in other.components:
			if i.equals(j):
				found=true
				break
		if not found:
			return false
	return true


func add_component(node:WaveNodeComponent)->void:
	if not node in components:
		node.wave=weakref(self)
		components.append(node)


func remove_component(node:WaveNodeComponent)->void:
	components.erase(node)


func find_component(node:WaveNodeComponent)->int:
	return components.find(node)
