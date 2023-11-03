extends WaveComponent
class_name LpfFilter

const COMPONENT_ID:String="LowPass"
const CHUNK_ID:String="lPFF"
const CHUNK_VERSION:int=0

var cutoff:float=1.0 setget set_cutoff
var coeffs:Array=[]
var taps:int=16 setget set_taps
var wave_size:int=-1

func _init().()->void:
	output_mode=OUT_MODE.REPLACE
	input_comp=null
	cutoff=1.0
	taps=16

func duplicate()->WaveComponent:
	var nc:LpfFilter=.duplicate() as LpfFilter
	nc.set_taps(taps)
	nc.set_cutoff(cutoff)
	return nc

func equals(other:WaveComponent)->bool:
	if !.equals(other):
		return false
	if taps!=other.taps or !is_equal_approx(cutoff,other.cutoff):
		return false
	return true

func calculate(size:int,input:Array,caller:WaveComponent)->Array:
	if size!=wave_size:
		wave_size=size
		set_coeffs()
	if caller==null:
		GLOBALS.array_fill(generated,0.0,size)
		is_generated=false
	if input_comp!=null:
		if !input_comp.is_generated and caller==null:
			input_comp.calculate(size,input,self)
		modulator=input_comp.generated
	else:
		modulator=input
	DSP.convolution_filter(modulator,generated,coeffs)
	return generate_output(size,input,caller)

func set_taps(t:int)->void:
	taps=t
	set_coeffs()

func set_cutoff(i:float)->void:
	cutoff=i
	set_coeffs()

func set_coeffs()->void:
	if wave_size<1:
		return
	coeffs.resize((taps*2)+1)
	var f:float=cutoff/wave_size
	var o:float=TAU*f
	var sum:float=0.0
	for i in range(-taps,taps+1):
		var t:float
		if i==0:
			t=2.0*f
		else:
			t=sin(o*i)/(PI*i)
		coeffs[i+taps]=t
		sum+=abs(t)
	for i in range(coeffs.size()):
		coeffs[i]/=sum

#

func serialize(out:ChunkedFile,components:Array)->void:
	serialize_start(out,CHUNK_ID,CHUNK_VERSION,components)
	out.store_float(cutoff)
	out.store_16(taps)
	out.end_chunk()

#

func deserialize(inf:ChunkedFile,c:LpfFilter,components:Array,version:int)->void:
	deserialize_start(inf,c,components,version)
	c.cutoff=inf.get_float()
	c.taps=inf.get_16()
