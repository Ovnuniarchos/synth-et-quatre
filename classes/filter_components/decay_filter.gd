extends WaveComponent
class_name DecayFilter

const COMPONENT_ID:String="Decay"

var decay:float

func _init().()->void:
	output_mode=OUT_MODE.REPLACE
	input_comp=null
	decay=0.0

func duplicate()->WaveComponent:
	var nc:DecayFilter=.duplicate() as DecayFilter
	nc.decay=decay
	return nc

func equals(other:WaveComponent)->bool:
	if !.equals(other):
		return false
	return is_equal_approx(decay,other.decay)

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
	DSP.decay(modulator,generated,decay,vol)
	return generate_output(size,input,caller)
