extends WaveComponent
class_name QuantizeFilter

const COMPONENT_ID:String="Quantize"

var steps:int

func _init().()->void:
	output_mode=OUT_MODE.REPLACE
	input_comp=null
	steps=3

func duplicate()->WaveComponent:
	var nc:QuantizeFilter=.duplicate() as QuantizeFilter
	nc.steps=steps
	return nc

func equals(other:WaveComponent)->bool:
	if !.equals(other):
		return false
	return steps==other.steps

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
	DSP.quantize(modulator,generated,steps)
	return generate_output(size,input,caller)
