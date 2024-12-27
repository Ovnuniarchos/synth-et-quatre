extends Waveform
class_name NodeWave

const WAVE_TYPE:String="Node"


var size_po2:int=8 setget set_size_po2
var components:Array
var output:OutputNodeComponent


func _init()->void:
	name=tr("DEFN_NODE_WAVE")
	output=OutputNodeComponent.new()
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
		var nc:WaveNodeComponent=c.duplicate()
		nw.components.append(nc)
		if nc is OutputNodeComponent:
			nw.output=nc
	nw.calculate()
	return nw


func copy(from:Waveform,full:bool=false)->void:
	if (from as NodeWave)==null:
		return
	.copy(from,full)
	size_po2=from.size_po2
	components=[]
	for c in from.components:
		var nc:WaveNodeComponent=c.duplicate()
		components.append(nc)
		if nc is OutputNodeComponent:
			output=nc
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
		components.append(node)


func remove_component(node:WaveNodeComponent)->void:
	components.erase(node)


func find_component(node:WaveNodeComponent)->int:
	if node==output:
		return 0
	return components.find(node)+1
