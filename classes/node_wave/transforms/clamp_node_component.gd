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
var mode_hi_slot:Array=[]
var mode_hi_values:Array=[]
var mode_hi:int=ClampNodeConstants.CLAMP_CLAMP
var level_lo_slot:Array=[]
var level_lo_values:Array=[]
var level_lo_value:float=-1.0
var clamp_lo_slot:Array=[]
var clamp_lo_values:Array=[]
var clamp_lo_value:float=1.0
var mode_lo_slot:Array=[]
var mode_lo_values:Array=[]
var mode_lo:int=ClampNodeConstants.CLAMP_CLAMP
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
		input_slot,level_hi_slot,clamp_hi_slot,mode_hi_slot,level_lo_slot,clamp_lo_slot,mode_lo_slot,
		mix_slot,clamp_mix_slot,amplitude_slot,power_slot,decay_slot,dc_slot,isolate_slot
	]


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	calculate_slot(input_values,input_slot,NAN)
	calculate_slot(level_hi_values,level_hi_slot,level_hi_value)
	calculate_slot(clamp_hi_values,clamp_hi_slot,clamp_hi_value)
	calculate_option_slot(mode_hi_values,mode_hi_slot,ClampNodeConstants.AS_ARRAY,mode_hi)
	calculate_slot(level_lo_values,level_lo_slot,level_lo_value)
	calculate_slot(clamp_lo_values,clamp_lo_slot,clamp_lo_value)
	calculate_option_slot(mode_lo_values,mode_lo_slot,ClampNodeConstants.AS_ARRAY,mode_lo)
	for i in size:
		if not (is_nan(mode_hi_values[i]) or is_nan(mode_lo_values[i])):
			mode_hi_values[i]=(int(mode_hi_values[i])<<ClampNodeConstants.CLAMP_SHIFT)|int(mode_lo_values[i])
		else:
			mode_hi_values[i]=NAN
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
	var d:float
	var d2:float
	var mix:float
	var mode
	reset_decay()
	for i in sz:
		mix=lerp(mix_values[optr],clamp(mix_values[optr],0.0,1.0),clamp_mix_values[optr])
		mode=mode_hi_values[optr]
		t=input_values[optr]
		if mode==ClampNodeConstants.CLAMP_NC:
			t=max(t,level_lo_values[optr])
		elif mode==ClampNodeConstants.CLAMP_NW:
			if t<level_lo_values[optr]:
				t=wrapf(t,level_lo_values[optr],1.0)
		elif mode==ClampNodeConstants.CLAMP_NB:
			if t<level_lo_values[optr]:
				t=level_lo_values[optr]-(t-level_lo_values[optr])
		elif mode==ClampNodeConstants.CLAMP_CN:
			t=min(t,level_hi_values[optr])
		elif mode==ClampNodeConstants.CLAMP_CC:
			t=clamp(t,level_lo_values[optr],level_hi_values[optr])
		elif mode==ClampNodeConstants.CLAMP_CW:
			if t<level_lo_values[optr]:
				t=wrapf(t,level_lo_values[optr],level_hi_values[optr])
			t=min(level_hi_values[optr],t)
		elif mode==ClampNodeConstants.CLAMP_CB:
			if t<level_lo_values[optr]:
				t=level_lo_values[optr]-(t-level_lo_values[optr])
			t=min(t,level_hi_values[optr])
		elif mode==ClampNodeConstants.CLAMP_WN:
			if t>level_hi_values[optr]:
				t=wrapf(t,-1.0,level_hi_values[optr])
		elif mode==ClampNodeConstants.CLAMP_WC:
			if t>level_hi_values[optr]:
				t=wrapf(t,level_lo_values[optr],level_hi_values[optr])
			t=max(t,level_lo_values[optr])
		elif mode==ClampNodeConstants.CLAMP_WW:
			t=wrapf(t,level_lo_values[optr],level_hi_values[optr])
		elif mode==ClampNodeConstants.CLAMP_WB:
			if t<level_lo_values[optr]:
				t=level_lo_values[optr]-(t-level_lo_values[optr])
			t=wrapf(t,level_lo_values[optr],level_hi_values[optr])
		elif mode==ClampNodeConstants.CLAMP_BN:
			if t>level_hi_values[optr]:
				t=level_hi_values[optr]-(t-level_hi_values[optr])
		elif mode==ClampNodeConstants.CLAMP_BC:
			if t>level_hi_values[optr]:
				t=level_hi_values[optr]-(t-level_hi_values[optr])
			t=max(t,level_lo_values[optr])
		elif mode==ClampNodeConstants.CLAMP_BW:
			if t>level_hi_values[optr]:
				t=level_hi_values[optr]-(t-level_hi_values[optr])
			t=wrapf(t,level_lo_values[optr],level_hi_values[optr])
		elif mode==ClampNodeConstants.CLAMP_BB:
			if t<level_lo_values[optr] or t>level_hi_values[optr]:
				d=level_hi_values[optr]-level_lo_values[optr]
				if is_nan(d) or is_zero_approx(d):
					t=(level_hi_values[optr]+level_lo_values[optr])*0.5
				elif t<level_lo_values[optr]:
					d2=fposmod((t-level_lo_values[optr])/d,2.0)
					t=fposmod(t-level_lo_values[optr],abs(d))
					if d2<1.0:
						t=level_lo_values[optr]+t
					else:
						t=level_hi_values[optr]-t
				else:
					d2=fposmod((t-level_hi_values[optr])/d,2.0)
					t=fposmod(t-level_hi_values[optr],abs(d))
					if d2<1.0:
						t=level_hi_values[optr]-t
					else:
						t=level_lo_values[optr]+t
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
