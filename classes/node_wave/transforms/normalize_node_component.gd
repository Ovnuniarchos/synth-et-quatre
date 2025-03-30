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
	var hl_values:Array=[0.0,0.0,0.0,0.0,0.0,0.0]
	NODES.find_amplitude_bounds(input_values,sz,optr,hl_values)
	var hi:float=hl_values[0]
	var lo:float=hl_values[1]
	var hilo:float=hl_values[2]
	var hi_full:float=hl_values[3]
	var lo_full:float=hl_values[4]
	var hilo_full:float=hl_values[5]
	if hi_full==-INF and lo_full==INF:
		output_valid=true
		return output
	calculate_diffuse_boolean_slot(keep_0_values,keep_0_slot,keep_0)
	calculate_diffuse_boolean_slot(use_full_values,use_full_slot,use_full)
	calculate_slot(mix_values,mix_slot,mix)
	calculate_diffuse_boolean_slot(clamp_mix_values,clamp_mix_slot,clamp_mix)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_boolean_slot(isolate_values,isolate_slot,isolate)
	NODES.normalize(output,sz,optr,
		hi,lo,hilo,hi_full,lo_full,hilo_full,
		input_values,keep_0_values,use_full_values,
		mix_values,clamp_mix_values,isolate_values,
		amplitude_values,power_values,decay_values
	)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as NormalizeNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"keep_0","use_full","mix","clamp_mix","amplitude","power","decay","isolate"
	])


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:NormalizeNodeComponent=.duplicate(container) as NormalizeNodeComponent
	nc.keep_0=keep_0
	nc.use_full=use_full
	nc.mix=mix
	nc.clamp_mix=clamp_mix
	nc.amplitude=amplitude
	nc.power=power
	nc.decay=decay
	nc.isolate=isolate
	return nc
