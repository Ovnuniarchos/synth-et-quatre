extends WaveComponent
class_name NormalizeFilter

const CHUNK_ID:String="nORF"
const CHUNK_VERSION:int=0

var keep_center:bool=true

func _init().()->void:
	output_mode=OUT_MODE.REPLACE
	keep_center=true
	input_comp=null

func duplicate()->WaveComponent:
	var nc:NormalizeFilter=.duplicate() as NormalizeFilter
	return nc

func equals(other:WaveComponent)->bool:
	if !.equals(other):
		return false
	if other.get("CHUNK_ID")!=CHUNK_ID:
		return false
	return keep_center==other.keep_center

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
	DSP.normalize(modulator,generated,keep_center)
	return generate_output(size,input,caller)

#

func serialize(out:ChunkedFile,components:Array)->void:
	serialize_start(out,CHUNK_ID,CHUNK_VERSION,components)
	out.store_8(int(keep_center))
	out.end_chunk()

#

func deserialize(inf:ChunkedFile,c:NormalizeFilter,components:Array,version:int)->void:
	deserialize_start(inf,c,components,version)
	c.keep_center=bool(inf.get_8())
