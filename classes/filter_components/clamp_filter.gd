extends WaveComponent
class_name ClampFilter

const CHUNK_ID:String="cLAF"

var u_clamp_on:bool=true
var u_clamp:float=1.0
var l_clamp_on:bool=true
var l_clamp:float=-1.0

func _init().()->void:
	output_mode=OUT_MODE.REPLACE
	input_comp=null
	u_clamp_on=true
	u_clamp=1.0
	l_clamp_on=true
	l_clamp=-1.0

func duplicate()->WaveComponent:
	var nc:ClampFilter=.duplicate() as ClampFilter
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
	for i in range(0,size):
		var val:float=modulator[i]
		val=clamp(val,l_clamp if l_clamp_on else val,u_clamp if u_clamp_on else val)
		generated[i]=val
	return generate_output(size,input,caller)

#

func serialize(out:ChunkedFile,components:Array)->void:
	serialize_start(out,CHUNK_ID,components)
	out.store_8(int(u_clamp_on))
	out.store_8(int(l_clamp_on))
	out.store_float(u_clamp)
	out.store_float(l_clamp)
	out.end_chunk()

#

func deserialize(inf:ChunkedFile,c:ClampFilter,components:Array)->void:
	deserialize_start(inf,c,components)
	c.u_clamp_on=bool(inf.get_8())
	c.l_clamp_on=bool(inf.get_8())
	c.u_clamp=inf.get_float()
	c.l_clamp=inf.get_float()
