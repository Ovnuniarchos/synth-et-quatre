extends WaveComponent
class_name QuantizeFilter

const CHUNK_ID:String="qUAF"

var steps:int

func _init().()->void:
	output_mode=OUT_MODE.REPLACE
	input_comp=null
	steps=3

func duplicate()->WaveComponent:
	var nc:QuantizeFilter=.duplicate() as QuantizeFilter
	nc.steps=steps
	return nc

func calculate(size:int,input:Array,caller:WaveComponent)->Array:
	if caller==null:
		GLOBALS.array_fill(generated,0.0,size)
		is_generated=false
	if input_comp!=null:
		if !input_comp.is_generated and caller==null:
			input_comp.calculate(size,input,self)
		modulator=input_comp.generated
	else:
		modulator=input
	var st:float=2.0/(steps-1)
	for i in range(0,size):
		var val:float=stepify(modulator[i]+1.0,st)-1.0
		generated[i]=val
	return generate_output(size,input,caller)

#

func serialize(out:ChunkedFile,components:Array)->void:
	serialize_start(out,CHUNK_ID,components)
	out.store_8(steps)
	out.end_chunk()

#

func deserialize(inf:ChunkedFile,c:QuantizeFilter,components:Array)->void:
	deserialize_start(inf,c,components)
	c.steps=inf.get_8()