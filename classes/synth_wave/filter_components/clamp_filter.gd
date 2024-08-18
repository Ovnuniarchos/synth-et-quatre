extends WaveComponent
class_name ClampFilter

const COMPONENT_ID:String="Clamp"

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

func equals(other:WaveComponent)->bool:
	if !.equals(other):
		return false
	if u_clamp_on!=other.u_clamp_on or l_clamp_on!=other.l_clamp_on\
			or !are_equal_approx([u_clamp,other.u_clamp,l_clamp,other.l_clamp]):
		return false
	return true


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
	DSP.clamp(modulator,generated,l_clamp,u_clamp,l_clamp_on,u_clamp_on,vol)
	return generate_output(size,input,caller)
