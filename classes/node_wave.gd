extends Waveform
class_name NodeWave

const WAVE_TYPE:String="Node"


var size_po2:int=8 setget set_size_po2
var components:Array=[]


func _init()->void:
	name=tr("DEFN_SYNTH_WAVE")
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
	# TODO
	data=buffer


func duplicate()->Waveform:
	var nw:SynthWave=.duplicate() as SynthWave
	nw.size_po2=size_po2
	nw.components=[]
	for c in components:
		nw.components.append(c.duplicate())
	# TODO?
	nw.calculate()
	return nw


func copy(from:Waveform,full:bool=false)->void:
	if from.WAVE_TYPE==WAVE_TYPE:
		.copy(from,full)
		size_po2=from.size_po2
		components=[]
		for c in from.components:
			components.append(c.duplicate())
		# TODO?
		calculate()


func equals(other:Waveform)->bool:
	if !.equals(other):
		return false
	if other.components.size()!=components.size():
		return false
	for i in components.size():
		var c0:WaveComponent=components[i]
		var c1:WaveComponent=other.components[i]
		if not c0.equals(c1) or components.find(c0.input_comp)!=other.components.find(c1.input_comp):
			return false
	return true
