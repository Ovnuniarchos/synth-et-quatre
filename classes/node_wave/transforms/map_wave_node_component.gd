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
var mix_slot:Array=[]
var mix_values:Array=[]
var mix_value:float=1.0
var clamp_mix_slot:Array=[]
var clamp_mix_values:Array=[]
var clamp_mix_value:float=0.0
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
		input_slot,mapping_slot,amplitude_slot,power_slot,decay_slot,dc_slot
	]


func calculate()->Array:
	if output_valid:
		return output
	calculate_slot(input_values,input_slot,NAN)
	output=input_values.duplicate()
	calculate_slot(mapping_values,mapping_slot,NAN)
	calculate_option_slot(lerp_values,lerp_slot,MapWaveNodeConstants.LERPS_AS_ARRAY,lerp_value)
	calculate_slot(mix_values,mix_slot,mix_value)
	calculate_boolean_slot(clamp_mix_values,clamp_mix_slot,clamp_mix_value)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	var t:float
	var t2:float
	reset_decay()
	for i in sz:
		if not is_nan(input_values[optr]):
			t=fposmod(range_lerp(input_values[optr],-1.0,1.0,0.0,size-1),size)
			if lerp_values[optr]==MapWaveNodeConstants.LERP_NONE:
				output[optr]=mapping_values[t]
			elif lerp_values[optr]==MapWaveNodeConstants.LERP_LINEAR:
				t2=t-floor(t)
				output[optr]=lerp(mapping_values[t],mapping_values[fmod(t+1,size)],t2)
			else:
				t2=(1-cos((t-floor(t))*PI))*0.5
				output[optr]=lerp(mapping_values[t],mapping_values[fmod(t+1,size)],t2)
		else:
			output[optr]=input_values[optr]
		"""t=range_lerp(
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
		)*amplitude_values[optr])+dc_values[optr]"""
		optr=(optr+1)&(size-1)
	output_valid=true
	return output
