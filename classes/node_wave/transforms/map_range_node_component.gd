extends WaveNodeComponent
class_name MapRangeNodeComponent

const NODE_TYPE:String="MapRange"


var input_slot:Array=[]
var input_values:Array=[]
var min_in_slot:Array=[]
var min_in_values:Array=[]
var min_in_value:float=-1.0
var max_in_slot:Array=[]
var max_in_values:Array=[]
var max_in_value:float=1.0
var min_out_slot:Array=[]
var min_out_values:Array=[]
var min_out_value:float=-1.0
var max_out_slot:Array=[]
var max_out_values:Array=[]
var max_out_value:float=1.0
var mix_slot:Array=[]
var mix_values:Array=[]
var mix_value:float=1.0
var clamp_mix_slot:Array=[]
var clamp_mix_values:Array=[]
var clamp_mix_value:float=0.0
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
		input_slot,min_in_slot,max_in_slot,min_out_slot,max_out_slot,
		mix_slot,clamp_mix_slot,amplitude_slot,power_slot,decay_slot,dc_slot,isolate_slot
	]


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	calculate_slot(input_values,input_slot,NAN)
	calculate_slot(min_in_values,min_in_slot,min_in_value)
	calculate_slot(max_in_values,max_in_slot,max_in_value)
	calculate_slot(min_out_values,min_out_slot,min_out_value)
	calculate_slot(max_out_values,max_out_slot,max_out_value)
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
	reset_decay()
	for i in sz:
		t=range_lerp(
			input_values[optr],
			min_in_values[optr],max_in_values[optr],
			min_out_values[optr],max_out_values[optr]
		)
		t=lerp(
			input_values[optr],t,
			lerp(mix_values[optr],clamp(mix_values[optr],0.0,1.0),clamp_mix_values[optr])
		)
		output[optr]=(calculate_decay(
			pow(abs(t),power_values[optr])*sign(t),decay_values[optr],sz
		)*amplitude_values[optr])+dc_values[optr]
		optr=(optr+1)&size_mask
	fill_out_of_region(sz,optr,input_values,isolate_values)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as MapRangeNodeComponent)==null:
		return false
	return .equals(other)
