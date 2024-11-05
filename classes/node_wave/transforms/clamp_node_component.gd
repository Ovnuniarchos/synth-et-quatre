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
var mix_slot:Array=[]
var mix_values:Array=[]
var mix_value:float=1.0
var clamp_mix_slot:Array=[]
var clamp_mix_values:Array=[]
var clamp_mix_value:float=1.0
var isolate_slot:Array=[]
var isolate_values:Array=[]
var isolate:float=0.0
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
		mix_slot,clamp_mix_slot,amplitude_slot,power_slot,decay_slot,dc_slot,isolate_slot
	]


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	calculate_slot(input_values,input_slot,NAN)
	calculate_slot(level_hi_values,level_hi_slot,level_hi_value)
	calculate_slot(clamp_hi_values,clamp_hi_slot,clamp_hi_value)
	calculate_slot(level_lo_values,level_lo_slot,level_lo_value)
	calculate_slot(clamp_lo_values,clamp_lo_slot,clamp_lo_value)
	calculate_slot(mix_values,mix_slot,mix_value)
	calculate_diffuse_boolean_slot(clamp_mix_values,clamp_mix_slot,clamp_mix_value)
	calculate_boolean_slot(isolate_values,isolate_slot,isolate)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	var t:float
	var mix:float
	reset_decay()
	for i in sz:
		mix=lerp(mix_values[optr],clamp(mix_values[optr],0.0,1.0),clamp_mix_values[optr])
		t=lerp(input_values[optr],min(input_values[optr],level_hi_values[optr]),clamp_hi_values[optr])
		t=lerp(t,max(t,level_lo_values[optr]),clamp_lo_values[optr])
		t=lerp(input_values[optr],t,mix)
		output[optr]=(calculate_decay(
			pow(abs(t),power_values[optr])*sign(t),decay_values[optr],sz
		)*amplitude_values[optr])+dc_values[optr]
		optr=(optr+1)&size_mask
	fill_out_of_region(sz,optr,input_values,isolate_values)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as ClampNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"level_hi_value","clamp_hi_value","level_lo_value","clamp_lo_value",
		"mix_value","clamp_mix_value","isolate","amplitude","power","decay","dc"
	])
