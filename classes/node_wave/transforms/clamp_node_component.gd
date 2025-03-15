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
	inputs=[
		{SLOT_ID:SlotIds.SLOT_INPUT,SLOT_IN:input_slot},
		{SLOT_ID:SlotIds.SLOT_LEVEL_HI,SLOT_IN:level_hi_slot},
		{SLOT_ID:SlotIds.SLOT_CLAMP_HI,SLOT_IN:clamp_hi_slot},
		{SLOT_ID:SlotIds.SLOT_MODE_HI,SLOT_IN:mode_hi_slot},
		{SLOT_ID:SlotIds.SLOT_LEVEL_LO,SLOT_IN:level_lo_slot},
		{SLOT_ID:SlotIds.SLOT_CLAMP_LO,SLOT_IN:clamp_lo_slot},
		{SLOT_ID:SlotIds.SLOT_MODE_LO,SLOT_IN:mode_lo_slot},
		{SLOT_ID:SlotIds.SLOT_MIX,SLOT_IN:mix_slot},
		{SLOT_ID:SlotIds.SLOT_CLAMP_MIX,SLOT_IN:clamp_mix_slot},
		{SLOT_ID:SlotIds.SLOT_AMPLITUDE,SLOT_IN:amplitude_slot},
		{SLOT_ID:SlotIds.SLOT_POWER,SLOT_IN:power_slot},
		{SLOT_ID:SlotIds.SLOT_DECAY,SLOT_IN:decay_slot},
		{SLOT_ID:SlotIds.SLOT_DC,SLOT_IN:dc_slot},
		{SLOT_ID:SlotIds.SLOT_ISOLATE,SLOT_IN:isolate_slot}
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
	calculate_option_slot(mode_hi_values,mode_hi_slot,ClampNodeConstants.CLAMP_END,mode_hi)
	calculate_slot(level_lo_values,level_lo_slot,level_lo_value)
	calculate_slot(clamp_lo_values,clamp_lo_slot,clamp_lo_value)
	calculate_option_slot(mode_lo_values,mode_lo_slot,ClampNodeConstants.CLAMP_END,mode_lo)
	calculate_slot(mix_values,mix_slot,mix_value)
	calculate_diffuse_boolean_slot(clamp_mix_values,clamp_mix_slot,clamp_mix_value)
	calculate_boolean_slot(isolate_values,isolate_slot,isolate)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	NODES.multiclamp(output,max(1.0,size*range_length),fposmod(range_from*size,size),input_values,
		level_hi_values,clamp_hi_values,mode_hi_values,
		level_lo_values,clamp_lo_values,mode_lo_values,
		mix_values,clamp_mix_values,isolate_values,
		amplitude_values,power_values,decay_values,dc_values
	)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as ClampNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"level_hi_value","mode_hi","clamp_hi_value","level_lo_value","mode_lo","clamp_lo_value",
		"mix_value","clamp_mix_value","isolate","amplitude","power","decay","dc"
	])


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:ClampNodeComponent=.duplicate(container) as ClampNodeComponent
	nc.level_hi_value=level_hi_value
	nc.clamp_hi_value=clamp_hi_value
	nc.mode_hi=mode_hi
	nc.level_lo_value=level_lo_value
	nc.clamp_lo_value=clamp_lo_value
	nc.mode_lo=mode_lo
	nc.mix_value=mix_value
	nc.clamp_mix_value=clamp_mix_value
	nc.isolate=isolate
	nc.amplitude=amplitude
	nc.power=power
	nc.decay=decay
	nc.dc=dc
	return nc
