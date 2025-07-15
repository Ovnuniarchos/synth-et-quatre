extends Waveform
class_name SynthWave

const WAVE_TYPE:String="Synth"


var size_po2:int=8 setget set_size_po2
var components:Array=[]


func _init()->void:
	name=tr("DEFN_SIMPLE_WAVE")
	resize_data(1<<size_po2)


func set_size_po2(s:int)->void:
	size_po2=int(clamp(s,4.0,16.0))
	size=1<<size_po2
	resize_data(size)


func calculate()->void:
	var buf_size:int=data.size()
	var buffer:Array=[]
	buffer.resize(buf_size)
	buffer.fill(0.0)
	for comp in components:
		buffer=comp.calculate(buf_size,buffer,null)
	data=buffer


func duplicate()->Waveform:
	var nw:SynthWave=.duplicate() as SynthWave
	nw.size_po2=size_po2
	nw.components=[]
	for c in components:
		nw.components.append(c.duplicate())
	for i in components.size():
		var ii:int=components.find(components[i].input_comp)
		nw.components[i].input_comp=null if ii==-1 else nw.components[ii]
	nw.calculate()
	return nw


func copy(from:Waveform,full:bool=false)->void:
	if from.WAVE_TYPE==WAVE_TYPE:
		.copy(from,full)
		size_po2=from.size_po2
		components=[]
		for c in from.components:
			components.append(c.duplicate())
		for i in from.components.size():
			var ii:int=from.components.find(from.components[i].input_comp)
			components[i].input_comp=null if ii==-1 else components[ii]
		calculate()


func equals(other:Waveform)->bool:
	if !.equals(other):
		return false
	if other.components.size()!=components.size():
		return false
	for i in components.size():
		var c0:WaveComponent=components[i]
		var c1:WaveComponent=other.components[i]
		if !c0.equals(c1) or components.find(c0.input_comp)!=other.components.find(c1.input_comp):
			return false
	return true


func get_component(index:int)->WaveComponent:
	if index<0 or index>=components.size():
		return null
	return components[index]


func readjust_inputs()->void:
	for i in range(components.size()):
		var c:WaveComponent=components[i] as WaveComponent
		if components.find(c.input_comp)>components.find(c):
			c.input_comp=null
		c.is_generated=false
