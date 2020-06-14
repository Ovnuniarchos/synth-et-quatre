extends WaveComponent
class_name HpfFilter

const CHUNK_ID:String="hPFF"

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
	var size1:int=size-1
	var r:Array=range(0,(taps*2)+1)
	for i in range(0,size):
		var phi:int=-taps
		var val:float=0.0
		for j in r:
			val+=modulator[(i+phi)&size1]*coeffs[j]
			phi+=1
		generated[i]=val
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
	for i in range(-taps,taps+1):
		var t:float
		if i==0:
			t=1.0-2.0*f
		else:
			t=-sin(o*i)/(PI*i)
		coeffs[i+taps]=t

#

func serialize(out:ChunkedFile,components:Array)->void:
	serialize_start(out,CHUNK_ID,components)
	out.store_float(cutoff)
	out.store_16(taps)
	out.end_chunk()

#

func deserialize(inf:ChunkedFile,c:LpfFilter,components:Array)->void:
	deserialize_start(inf,c,components)
	c.cutoff=inf.get_float()
	c.taps=inf.get_16()
