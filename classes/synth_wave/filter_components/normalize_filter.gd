extends WaveComponent
class_name NormalizeFilter

const COMPONENT_ID:String="Normalize"

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
	DSP.normalize(modulator,generated,keep_center,vol)
	return generate_output(size,input,caller)
