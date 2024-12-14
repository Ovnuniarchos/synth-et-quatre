extends WaveNodeComponent
class_name ClampNodeComponent

const NODE_TYPE:String="Clamp"


var input_slot:Array=[]
var input_values:Array=[]
var level_hi_slot:Array=[]
var level_hi_values:Array=[]
var level_hi_value:float=1.0 setget set_level_hi_value
var clamp_hi_slot:Array=[]
var clamp_hi_values:Array=[]
var clamp_hi_value:float=1.0 setget set_clamp_hi_value
var mode_hi_slot:Array=[]
var mode_hi_values:Array=[]
var mode_hi:int=ClampNodeConstants.CLAMP_CLAMP setget set_mode_hi
var level_lo_slot:Array=[]
var level_lo_values:Array=[]
var level_lo_value:float=-1.0 setget set_level_lo_value
var clamp_lo_slot:Array=[]
var clamp_lo_values:Array=[]
var clamp_lo_value:float=1.0 setget set_clamp_lo_value
var mode_lo_slot:Array=[]
var mode_lo_values:Array=[]
var mode_lo:int=ClampNodeConstants.CLAMP_CLAMP setget set_mode_lo
var mix_slot:Array=[]
var mix_values:Array=[]
var mix_value:float=1.0 setget set_mix_value
var clamp_mix_slot:Array=[]
var clamp_mix_values:Array=[]
var clamp_mix_value:float=1.0 setget set_clamp_mix_value
var isolate_slot:Array=[]
var isolate_values:Array=[]
var isolate:float=0.0 setget set_isolate
var amplitude_slot:Array=[]
var amplitude_values:Array=[]
var amplitude:float=1.0 setget set_amplitude
var power_slot:Array=[]
var power_values:Array=[]
var power:float=1.0 setget set_power
var decay_slot:Array=[]
var decay_values:Array=[]
var decay:float=0.0 setget set_decay
var dc_slot:Array=[]
var dc_values:Array=[]
var dc:float=0.0 setget set_dc


func _init()->void:
	._init()
	inputs=[
		input_slot,level_hi_slot,clamp_hi_slot,mode_hi_slot,level_lo_slot,clamp_lo_slot,mode_lo_slot,
		mix_slot,clamp_mix_slot,amplitude_slot,power_slot,decay_slot,dc_slot,isolate_slot
	]


func set_level_hi_value(value:float)->void:
	level_hi_value=value
	level_hi_values.resize(0)


func set_clamp_hi_value(value:float)->void:
	clamp_hi_value=value
	clamp_hi_values.resize(0)


func set_mode_hi(value:int)->void:
	mode_hi=value
	mode_hi_values.resize(0)


func set_level_lo_value(value:float)->void:
	level_lo_value=value
	level_lo_values.resize(0)


func set_clamp_lo_value(value:float)->void:
	clamp_lo_value=value
	clamp_lo_values.resize(0)


func set_mode_lo(value:int)->void:
	mode_lo=value
	mode_lo_values.resize(0)


func set_mix_value(value:float)->void:
	mix_value=value
	mix_values.resize(0)


func set_clamp_mix_value(value:float)->void:
	clamp_mix_value=value
	clamp_mix_values.resize(0)


func set_isolate(value:float)->void:
	isolate=value
	isolate_values.resize(0)


func set_amplitude(value:float)->void:
	amplitude=value
	amplitude_values.resize(0)


func set_power(value:float)->void:
	power=value
	power_values.resize(0)


func set_decay(value:float)->void:
	decay=value
	decay_values.resize(0)


func set_dc(value:float)->void:
	dc=value
	dc_values.resize(0)


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
	var mode:int
	var lvh:float
	var lvl:float
	reset_decay()
	for i in sz:
		mix=lerp(mix_values[optr],clamp(mix_values[optr],0.0,1.0),clamp_mix_values[optr])
		if is_nan(mode_hi_values[optr]) or is_nan(mode_lo_values[optr]):
			mode=ClampNodeConstants.CLAMP_SHIFT
		else:
			mode=(int(mode_hi_values[optr])<<ClampNodeConstants.CLAMP_SHIFT)|int(mode_lo_values[optr])
		t=input_values[optr]
		lvh=lerp(level_hi_values[optr],clamp(level_hi_values[optr],-1.0,1.0),clamp_hi_values[optr])
		lvl=lerp(level_lo_values[optr],clamp(level_lo_values[optr],-1.0,1.0),clamp_lo_values[optr])
		if mode==ClampNodeConstants.CLAMP_NC:
			t=max(t,lvl)
		elif mode==ClampNodeConstants.CLAMP_NW:
			if t<lvl:
				t=wrapf(t,lvl,1.0)
		elif mode==ClampNodeConstants.CLAMP_NB:
			if t<lvl:
				t=lvl-(t-lvl)
		elif mode==ClampNodeConstants.CLAMP_CN:
			t=min(t,lvh)
		elif mode==ClampNodeConstants.CLAMP_CC:
			t=clamp(t,lvl,lvh)
		elif mode==ClampNodeConstants.CLAMP_CW:
			if t<lvl:
				t=wrapf(t,lvl,lvh)
			t=min(lvh,t)
		elif mode==ClampNodeConstants.CLAMP_CB:
			if t<lvl:
				t=lvl-(t-lvl)
			t=min(t,lvh)
		elif mode==ClampNodeConstants.CLAMP_WN:
			if t>lvh:
				t=wrapf(t,-1.0,lvh)
		elif mode==ClampNodeConstants.CLAMP_WC:
			if t>lvh:
				t=wrapf(t,lvl,lvh)
			t=max(t,lvl)
		elif mode==ClampNodeConstants.CLAMP_WW:
			t=wrapf(t,lvl,lvh)
		elif mode==ClampNodeConstants.CLAMP_WB:
			if t<lvl:
				t=lvl-(t-lvl)
			t=wrapf(t,lvl,lvh)
		elif mode==ClampNodeConstants.CLAMP_BN:
			if t>lvh:
				t=lvh-(t-lvh)
		elif mode==ClampNodeConstants.CLAMP_BC:
			if t>lvh:
				t=lvh-(t-lvh)
			t=max(t,lvl)
		elif mode==ClampNodeConstants.CLAMP_BW:
			if t>lvh:
				t=lvh-(t-lvh)
			t=wrapf(t,lvl,lvh)
		elif mode==ClampNodeConstants.CLAMP_BB:
			if t<lvl or t>lvh:
				d=lvh-lvl
				if is_nan(d) or is_zero_approx(d):
					t=(lvh+lvl)*0.5
				elif t<lvl:
					d2=fposmod((t-lvl)/d,2.0)
					t=fposmod(t-lvl,abs(d))
					if d2<1.0:
						t=lvl+t
					else:
						t=lvh-t
				else:
					d2=fposmod((t-lvh)/d,2.0)
					t=fposmod(t-lvh,abs(d))
					if d2<1.0:
						t=lvh-t
					else:
						t=lvl+t
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
		"level_hi_value","mode_hi","clamp_hi_value","level_lo_value","mode_lo","clamp_lo_value",
		"mix_value","clamp_mix_value","isolate","amplitude","power","decay","dc"
	])
