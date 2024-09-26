extends WaveNodeComponent
class_name ClampNodeComponent

const NODE_TYPE:String="Clamp"


var input_slot:Array=[]
var input_values:Array=[]
var level_hi_slot:Array=[]
var level_hi_values:Array=[]
var level_hi_value:float=1.0
var clamp_hi_slot:Array=[]
var clamp_hi_values:Array=[]
var clamp_hi_value:float=1.0
var level_lo_slot:Array=[]
var level_lo_values:Array=[]
var level_lo_value:float=-1.0
var clamp_lo_slot:Array=[]
var clamp_lo_values:Array=[]
var clamp_lo_value:float=1.0
var amplitude_slot:Array=[]
var amplitude_values:Array=[]
var amplitude:float=1.0
var power_slot:Array=[]
var power_values:Array=[]
var power:float=1.0
var decay_slot:Array=[]
var decay_values:Array=[]
var decay:float=0.0
var dc_slot:Array=[]
var dc_values:Array=[]
var dc:float=0.0


func _init()->void:
	._init()
	inputs=[
		input_slot,level_hi_slot,clamp_hi_slot,level_lo_slot,clamp_lo_slot,
		amplitude_slot,power_slot,decay_slot,dc_slot
	]


func calculate()->Array:
	if output_valid:
		return output
	calculate_slot(input_values,input_slot,0.0)
	output=input_values.duplicate()
	calculate_slot(level_hi_values,level_hi_slot,level_hi_value)
	calculate_slot(clamp_hi_values,clamp_hi_slot,clamp_hi_value)
	calculate_slot(level_lo_values,level_lo_slot,level_lo_value)
	calculate_slot(clamp_lo_values,clamp_lo_slot,clamp_lo_value)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	var t:float
	reset_decay()
	for i in sz:
		t=lerp(input_values[optr],min(input_values[optr],level_hi_values[optr]),clamp_hi_values[optr])
		t=lerp(t,max(t,level_lo_values[optr]),clamp_lo_values[optr])
		output[optr]=(calculate_decay(
			pow(abs(t),power_values[optr])*sign(t),decay_values[optr],sz
		)*amplitude_values[optr])+dc_values[optr]
		optr=(optr+1)&(size-1)
	output_valid=true
	return output
