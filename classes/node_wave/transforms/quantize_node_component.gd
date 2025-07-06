extends WaveNodeComponent
class_name QuantizeNodeComponent

const NODE_TYPE:String="Quantize"


var input_slot:Array=[]
var input_values:Array=[]
var levels_slot:Array=[]
var levels_values:Array=[]
var levels_value:float=2.0 setget set_levels_value
var dither_slot:Array=[]
var dither_values:Array=[]
var dither_value:float=0.0 setget set_dither_value
var use_full_slot:Array=[]
var use_full_values:Array=[]
var use_full_value:float=1.0 setget set_use_full_value
var full_amplitude_slot:Array=[]
var full_amplitude_values:Array=[]
var full_amplitude_value:float=1.0 setget set_full_amplitude_value
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
		{SLOT_ID:SlotIds.SLOT_LEVELS,SLOT_IN:levels_slot},
		{SLOT_ID:SlotIds.SLOT_DITHER,SLOT_IN:dither_slot},
		{SLOT_ID:SlotIds.SLOT_USE_FULL_WAVE,SLOT_IN:use_full_slot},
		{SLOT_ID:SlotIds.SLOT_FULL_AMPLITUDE,SLOT_IN:full_amplitude_slot},
		{SLOT_ID:SlotIds.SLOT_MIX,SLOT_IN:mix_slot},
		{SLOT_ID:SlotIds.SLOT_CLAMP_MIX,SLOT_IN:clamp_mix_slot},
		{SLOT_ID:SlotIds.SLOT_AMPLITUDE,SLOT_IN:amplitude_slot},
		{SLOT_ID:SlotIds.SLOT_POWER,SLOT_IN:power_slot},
		{SLOT_ID:SlotIds.SLOT_DECAY,SLOT_IN:decay_slot},
		{SLOT_ID:SlotIds.SLOT_DC,SLOT_IN:dc_slot},
		{SLOT_ID:SlotIds.SLOT_ISOLATE,SLOT_IN:isolate_slot}
	]


func set_levels_value(value:float)->void:
	levels_value=value
	levels_values.resize(0)


func set_dither_value(value:float)->void:
	dither_value=value
	dither_values.resize(0)


func set_use_full_value(value:float)->void:
	use_full_value=value
	use_full_values.resize(0)


func set_full_amplitude_value(value:float)->void:
	full_amplitude_value=value
	full_amplitude_values.resize(0)


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
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	var hl_values:Array=[0.0,0.0,0.0,0.0,0.0,0.0]
	NODES.find_amplitude_bounds(input_values,sz,optr,hl_values)
	if hl_values[5]==INF:
		output_valid=true
		return output
	if hl_values[2]==INF:
		hl_values[0]=1.0
		hl_values[1]=-1.0
	var hi:float=hl_values[0]
	var lo:float=hl_values[1]
	var hi_full:float=hl_values[3]
	var lo_full:float=hl_values[4]
	calculate_slot(levels_values,levels_slot,levels_value)
	calculate_diffuse_boolean_slot(dither_values,dither_slot,dither_value)
	calculate_diffuse_boolean_slot(use_full_values,use_full_slot,use_full_value)
	calculate_diffuse_boolean_slot(full_amplitude_values,full_amplitude_slot,full_amplitude_value)
	calculate_slot(mix_values,mix_slot,mix_value)
	calculate_diffuse_boolean_slot(clamp_mix_values,clamp_mix_slot,clamp_mix_value)
	calculate_boolean_slot(isolate_values,isolate_slot,isolate)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	NODES.quantize(output,sz,optr,hi,lo,hi_full,lo_full,
		input_values,levels_values,dither_values,use_full_values,full_amplitude_values,
		mix_values,clamp_mix_values,isolate_values,
		amplitude_values,power_values,decay_values
	)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as ClampNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"levels_value","dither_value","use_full_value","full_amplitude_value",
		"mix_value","clamp_mix_value","isolate",
		"amplitude","power","decay","dc"
	])


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:QuantizeNodeComponent=.duplicate(container) as QuantizeNodeComponent
	nc.levels_value=levels_value
	nc.dither_value=dither_value
	nc.use_full_value=use_full_value
	nc.full_amplitude_value=full_amplitude_value
	nc.mix_value=mix_value
	nc.clamp_mix_value=clamp_mix_value
	nc.isolate=isolate
	nc.amplitude=amplitude
	nc.power=power
	nc.decay=decay
	nc.dc=dc
	return nc
