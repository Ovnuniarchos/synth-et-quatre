extends WaveNodeComponent
class_name MapWaveNodeComponent

const NODE_TYPE:String="MapWave"


var input_slot:Array=[]
var input_values:Array=[]
var mapping_slot:Array=[]
var mapping_values:Array=[]
var lerp_slot:Array=[]
var lerp_values:Array=[]
var lerp_value:float=MapWaveNodeConstants.LERP_LINEAR
var extrapolate_slot:Array=[]
var extrapolate_values:Array=[]
var extrapolate:float=MapWaveNodeConstants.XERP_WRAP
var mix_slot:Array=[]
var mix_values:Array=[]
var mix_value:float=1.0
var clamp_mix_slot:Array=[]
var clamp_mix_values:Array=[]
var clamp_mix_value:float=0.0
var map_empty_slot:Array=[]
var map_empty_values:Array=[]
var map_empty:float=0.0
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
var isolate_slot:Array=[]
var isolate_values:Array=[]
var isolate:float=0.0


func _init()->void:
	._init()
	inputs=[
		input_slot,mapping_slot,lerp_slot,extrapolate_slot,mix_slot,clamp_mix_slot,
		map_empty_slot,amplitude_slot,power_slot,decay_slot,dc_slot,isolate_slot
	]


func calculate_slope(exit:float,prev:float)->float:
	if is_nan(exit) or is_nan(prev):
		return 0.0
	return exit-prev


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	calculate_slot(input_values,input_slot,NAN)
	calculate_slot(mapping_values,mapping_slot,NAN)
	var slope_left:float=calculate_slope(mapping_values[0],mapping_values[1])
	var slope_right:float=calculate_slope(mapping_values[size_mask],mapping_values[size_mask-1])
	calculate_option_slot(lerp_values,lerp_slot,MapWaveNodeConstants.LERPS_AS_ARRAY,lerp_value)
	calculate_option_slot(extrapolate_values,extrapolate_slot,MapWaveNodeConstants.XERPS_AS_ARRAY,extrapolate)
	calculate_slot(mix_values,mix_slot,mix_value)
	calculate_diffuse_boolean_slot(clamp_mix_values,clamp_mix_slot,clamp_mix_value)
	calculate_boolean_slot(map_empty_values,map_empty_slot,map_empty)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	calculate_boolean_slot(isolate_values,isolate_slot,isolate)
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	var t:float
	var t1:float
	var t2:float
	reset_decay()
	for i in sz:
		if not is_nan(input_values[optr]):
			t=range_lerp(input_values[optr],-1.0,1.0,0.0,size)
			t1=t+1.0
			if extrapolate_values[optr]==MapWaveNodeConstants.XERP_CONSTANT:
				t=clamp(t,0,size_mask)
				t1=clamp(t1,0,size_mask)
			elif extrapolate_values[optr]==MapWaveNodeConstants.XERP_WRAP:
				t=fposmod(t,size)
				t1=fposmod(t1,size)
			if t<0.0:
				t=mapping_values[0]+slope_left*-t
			elif t>=size:
				t=mapping_values[size_mask]+slope_right*(t-1.0)
			elif lerp_values[optr]==MapWaveNodeConstants.LERP_NONE:
				t=mapping_values[t]
			elif lerp_values[optr]==MapWaveNodeConstants.LERP_LINEAR:
				if t1<0.0:
					t1=mapping_values[0]+slope_left*-t1
				elif t1>=size:
					t1=mapping_values[size_mask]+slope_right*(t1-1.0)
				else:
					t1=mapping_values[t1]
				t2=t-floor(t)
				t=lerp(mapping_values[t],t1,t2)
			else:
				if t1<0.0:
					t1=mapping_values[0]+slope_left*-t1
				elif t1>=size:
					t1=mapping_values[size_mask]+slope_right*(t1-1.0)
				else:
					t1=mapping_values[t1]
				t2=(1-cos((t-floor(t))*PI))*0.5
				t=lerp(mapping_values[t],t1,t2)
		else:
			t=NAN
		if map_empty_values[optr]>=0.5:
			output[optr]=t
		else:
			output[optr]=input_values[optr] if is_nan(t) else t
		optr=(optr+1)&size_mask
	fill_out_of_region(sz,optr,input_values,isolate_values)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as MapWaveNodeComponent)==null:
		return false
	return .equals(other)
