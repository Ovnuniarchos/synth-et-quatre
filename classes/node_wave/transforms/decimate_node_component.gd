extends WaveNodeComponent
class_name DecimateNodeComponent

const NODE_TYPE:String="Decimate"


var input_slot:Array=[]
var input_values:Array=[]
var samples_slot:Array=[]
var samples_values:Array=[]
var samples_value:float=16.0 setget set_samples_value
var use_full_slot:Array=[]
var use_full_values:Array=[]
var use_full_value:float=1.0 setget set_use_full_value
var lerp_slot:Array=[]
var lerp_values:Array=[]
var lerp_value:int=0 setget set_lerp_value
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
	inputs=[
		{SLOT_ID:SlotIds.SLOT_INPUT,SLOT_IN:input_slot},
		{SLOT_ID:SlotIds.SLOT_LEVELS,SLOT_IN:samples_slot},
		{SLOT_ID:SlotIds.SLOT_USE_FULL_WAVE,SLOT_IN:use_full_slot},
		{SLOT_ID:SlotIds.SLOT_LERP,SLOT_IN:lerp_slot},
		{SLOT_ID:SlotIds.SLOT_MIX,SLOT_IN:mix_slot},
		{SLOT_ID:SlotIds.SLOT_CLAMP_MIX,SLOT_IN:clamp_mix_slot},
		{SLOT_ID:SlotIds.SLOT_AMPLITUDE,SLOT_IN:amplitude_slot},
		{SLOT_ID:SlotIds.SLOT_POWER,SLOT_IN:power_slot},
		{SLOT_ID:SlotIds.SLOT_DECAY,SLOT_IN:decay_slot},
		{SLOT_ID:SlotIds.SLOT_DC,SLOT_IN:dc_slot},
		{SLOT_ID:SlotIds.SLOT_ISOLATE,SLOT_IN:isolate_slot}
	]


func set_samples_value(value:float)->void:
	samples_value=value
	samples_values.resize(0)


func set_use_full_value(value:float)->void:
	use_full_value=value
	use_full_values.resize(0)


func set_lerp_value(value:int)->void:
	lerp_value=value
	lerp_values.resize(0)


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
	calculate_diffuse_boolean_slot(samples_values,samples_slot,samples_value)
	calculate_diffuse_boolean_slot(use_full_values,use_full_slot,use_full_value)
	calculate_option_slot(lerp_values,lerp_slot,MapWaveNodeConstants.LERP_END,lerp_value)
	calculate_slot(mix_values,mix_slot,mix_value)
	calculate_diffuse_boolean_slot(clamp_mix_values,clamp_mix_slot,clamp_mix_value)
	calculate_boolean_slot(isolate_values,isolate_slot,isolate)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	NODES.decimate(output,max(1.0,size*range_length),fposmod(range_from*size,size),
		input_values,samples_values,use_full_values,lerp_values,
		mix_values,clamp_mix_values,isolate_values,
		amplitude_values,power_values,decay_values,dc_values
	)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as ClampNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"samples_value","use_full_value","lerp_value",
		"mix_value","clamp_mix_value","isolate",
		"amplitude","power","decay","dc"
	])


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:QuantizeNodeComponent=.duplicate(container) as QuantizeNodeComponent
	nc.samples_value=samples_value
	nc.use_full_value=use_full_value
	nc.lerp_value=lerp_value
	nc.mix_value=mix_value
	nc.clamp_mix_value=clamp_mix_value
	nc.isolate=isolate
	nc.amplitude=amplitude
	nc.power=power
	nc.decay=decay
	nc.dc=dc
	return nc
