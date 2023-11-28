extends WaveComponent
class_name PowerFilter

const COMPONENT_ID:String="Power"

var power:float

func _init().()->void:
	output_mode=OUT_MODE.REPLACE
	input_comp=null
	power=1.0

func duplicate()->WaveComponent:
	var nc:PowerFilter=.duplicate() as PowerFilter
	nc.power=power
	return nc

func equals(other:WaveComponent)->bool:
	if !.equals(other):
		return false
	return is_equal_approx(power,other.power)

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
	DSP.power(modulator,generated,power,vol)
	return generate_output(size,input,caller)
