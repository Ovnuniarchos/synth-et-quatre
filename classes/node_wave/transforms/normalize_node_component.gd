extends WaveNodeComponent
class_name NormalizeNodeComponent

const NODE_TYPE:String="Normalize"


var input_slot:Array=[]
var input_values:Array=[]
var keep_0_slot:Array=[]
var keep_0_values:Array=[]
var keep_0:float=1.0 setget set_keep_0
var use_full_slot:Array=[]
var use_full_values:Array=[]
var use_full:float=1.0 setget set_use_full
var mix_slot:Array=[]
var mix_values:Array=[]
var mix:float=1.0 setget set_mix
var clamp_mix_slot:Array=[]
var clamp_mix_values:Array=[]
var clamp_mix:float=1.0 setget set_clamp_mix
var amplitude_slot:Array=[]
var amplitude_values:Array=[]
var amplitude:float=1.0 setget set_amplitude
var power_slot:Array=[]
var power_values:Array=[]
var power:float=1.0 setget set_power
var decay_slot:Array=[]
var decay_values:Array=[]
var decay:float=0.0 setget set_decay
var isolate_slot:Array=[]
var isolate_values:Array=[]
var isolate:float=1.0 setget set_isolate


func _init()->void:
	._init()
	inputs=[
		{SLOT_ID:SlotIds.SLOT_INPUT,SLOT_IN:input_slot},
		{SLOT_ID:SlotIds.SLOT_KEEP_0,SLOT_IN:keep_0_slot},
		{SLOT_ID:SlotIds.SLOT_USE_FULL_WAVE,SLOT_IN:use_full_slot},
		{SLOT_ID:SlotIds.SLOT_MIX,SLOT_IN:mix_slot},
		{SLOT_ID:SlotIds.SLOT_CLAMP_MIX,SLOT_IN:clamp_mix_slot},
		{SLOT_ID:SlotIds.SLOT_AMPLITUDE,SLOT_IN:amplitude_slot},
		{SLOT_ID:SlotIds.SLOT_POWER,SLOT_IN:power_slot},
		{SLOT_ID:SlotIds.SLOT_DECAY,SLOT_IN:decay_slot},
		{SLOT_ID:SlotIds.SLOT_ISOLATE,SLOT_IN:isolate_slot}
	]


func set_keep_0(value:float)->void:
	keep_0=value
	keep_0_values.resize(0)


func set_use_full(value:float)->void:
	use_full=value
	use_full_values.resize(0)


func set_mix(value:float)->void:
	mix=value
	mix_values.resize(0)


func set_clamp_mix(value:float)->void:
	clamp_mix=value
	clamp_mix_values.resize(0)


func set_amplitude(value:float)->void:
	amplitude=value
	amplitude_values.resize(0)


func set_power(value:float)->void:
	power=value
	power_values.resize(0)


func set_decay(value:float)->void:
	decay=value
	decay_values.resize(0)


func set_isolate(value:float)->void:
	isolate=value
	isolate_values.resize(0)


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	calculate_slot(input_values,input_slot,NAN)
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	var t:float
	var hi:float=-INF
	var lo:float=INF
	var hilo:float
	var hi_full:float=-INF
	var lo_full:float=INF
	var hilo_full:float
	for i in size:
		if i<sz and not is_nan(input_values[optr]):
			hi=max(hi,input_values[optr])
			lo=min(lo,input_values[optr])
			optr=(optr+1)&size_mask
		if not is_nan(input_values[i]):
			hi_full=max(hi_full,input_values[i])
			lo_full=min(lo_full,input_values[i])
	if hi==-INF and lo==INF and hi_full==-INF and lo_full==INF:
		output_valid=true
		return output
	if hi==-INF and lo==INF:
		hi=1.0
		lo=-1.0
	hilo=max(abs(hi),abs(lo))
	hilo_full=max(abs(hi_full),abs(lo_full))
	calculate_diffuse_boolean_slot(keep_0_values,keep_0_slot,keep_0)
	calculate_diffuse_boolean_slot(use_full_values,use_full_slot,use_full)
	calculate_slot(mix_values,mix_slot,mix)
	calculate_diffuse_boolean_slot(clamp_mix_values,clamp_mix_slot,clamp_mix)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_boolean_slot(isolate_values,isolate_slot,isolate)
	optr=fposmod(range_from*size,size)
	reset_decay()
	var h:float
	var l:float
	var hl:float
	for i in sz:
		h=lerp(hi,hi_full,use_full_values[optr])
		l=lerp(lo,lo_full,use_full_values[optr])
		hl=lerp(hilo,hilo_full,use_full_values[optr])
		t=lerp(range_lerp(input_values[optr],l,h,-1.0,1.0),
			range_lerp(input_values[optr],-hl,hl,-1.0,1.0),
			keep_0_values[optr]
		)
		t=lerp(input_values[optr],t,lerp(mix_values[optr],clamp(mix_values[optr],0.0,1.0),clamp_mix_values[optr]))
		output[optr]=calculate_decay(
			pow(abs(t),power_values[optr])*sign(t),decay_values[optr],sz
		)*amplitude_values[optr]
		optr=(optr+1)&size_mask
	fill_out_of_region(sz,optr,input_values,isolate_values)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as NormalizeNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"keep_0","use_full","mix","clamp_mix","amplitude","power","decay","isolate"
	])
