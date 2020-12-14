extends Waveform
class_name SynthWave

const CHUNK_ID:String="sYNW"
const CHUNK_VERSION:int=0

var size_po2:int=8 setget set_size_po2
var components:Array=[]

func _init()->void:
	resize_data(1<<size_po2)

func set_size_po2(s:int)->void:
	size_po2=int(clamp(s,4.0,16.0))
	size=1<<size_po2
	resize_data(size)

func calculate()->void:
	var buf_size:int=data.size()
	var buffer:Array=[]
	buffer.resize(buf_size)
	for i in range(0,buf_size):
		buffer[i]=0.0
	for comp in components:
		buffer=comp.calculate(buf_size,buffer,null)
	data=buffer

func duplicate()->Waveform:
	var nw:SynthWave=.duplicate() as SynthWave
	nw.size_po2=size_po2
	nw.components=[]
	for c in components:
		nw.components.append(c.duplicate())
	for i in range(0,components.size()):
		var ii:int=components.find(components[i].input_comp)
		nw.components[i].input_comp=null if ii==-1 else nw.components[ii]
	return nw

func equals(other:Waveform)->bool:
	if !.equals(other):
		return false
	if other.get("CHUNK_ID")!=CHUNK_ID:
		return false
	if other.components.size()!=components.size():
		return false
	for i in range(components.size()):
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
	for i in range(0,components.size()):
		var c:WaveComponent=components[i] as WaveComponent
		if components.find(c.input_comp)>components.find(c):
			c.input_comp=null
		c.is_generated=false

#

func serialize(out:ChunkedFile)->void:
	out.start_chunk(CHUNK_ID,CHUNK_VERSION)
	out.store_8(size_po2)
	out.store_pascal_string(name)
	out.store_16(components.size())
	for comp in components:
		comp.serialize(out,components)
	out.end_chunk()

#

func deserialize(inf:ChunkedFile,w:SynthWave)->void:
	w.size_po2=inf.get_8()
	w.name=inf.get_pascal_string()
	w.components=[]
	w.components.resize(inf.get_16())
	for i in range(0,w.components.size()):
		var hdr:Dictionary=inf.get_chunk_header()
		var nw:WaveComponent=null
		match hdr[ChunkedFile.CHUNK_ID]:
			TriangleWave.CHUNK_ID:
				nw=TriangleWave.new()
			SineWave.CHUNK_ID:
				nw=SineWave.new()
			SawWave.CHUNK_ID:
				nw=SawWave.new()
			RectangleWave.CHUNK_ID:
				nw=RectangleWave.new()
			NormalizeFilter.CHUNK_ID:
				nw=NormalizeFilter.new()
			LpfFilter.CHUNK_ID:
				nw=LpfFilter.new()
			HpfFilter.CHUNK_ID:
				nw=HpfFilter.new()
			ClampFilter.CHUNK_ID:
				nw=ClampFilter.new()
			_:
				print("Unrecognized chunk [%s]"%[hdr[ChunkedFile.CHUNK_ID]])
		if nw!=null:
			w.components[i]=nw
			nw.deserialize(inf,nw,w.components)
		inf.skip_chunk(hdr)
	w.resize_data(1<<w.size_po2)
	w.calculate()
