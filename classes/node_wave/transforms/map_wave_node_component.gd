extends WaveNodeComponent
class_name MapWaveNodeComponent

const NODE_TYPE:String="MapWave"


var input_slot:Array=[]
var input_values:Array=[]
var mapping_slot:Array=[]
var mapping_values:Array=[]
var lerp_slot:Array=[]
var lerp_values:Array=[]
var lerp_value:int=MapWaveNodeConstants.LERP_LINEAR setget set_lerp_value
var extrapolate_slot:Array=[]
var extrapolate_values:Array=[]
var extrapolate:int=MapWaveNodeConstants.XERP_WRAP setget set_extrapolate
var mix_slot:Array=[]
var mix_values:Array=[]
var mix_value:float=1.0 setget set_mix_value
var clamp_mix_slot:Array=[]
var clamp_mix_values:Array=[]
var clamp_mix_value:float=0.0 setget set_clamp_mix_value
var map_empty_slot:Array=[]
var map_empty_values:Array=[]
var map_empty:float=0.0 setget set_map_empty
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
var isolate_slot:Array=[]
var isolate_values:Array=[]
var isolate:float=0.0 setget set_isolate


func _init()->void:
	inputs=[
		{SLOT_ID:SlotIds.SLOT_INPUT,SLOT_IN:input_slot},
		{SLOT_ID:SlotIds.SLOT_MAPPING,SLOT_IN:mapping_slot},
		{SLOT_ID:SlotIds.SLOT_LERP,SLOT_IN:lerp_slot},
		{SLOT_ID:SlotIds.SLOT_EXTRAPOLATE,SLOT_IN:extrapolate_slot},
		{SLOT_ID:SlotIds.SLOT_MIX,SLOT_IN:mix_slot},
		{SLOT_ID:SlotIds.SLOT_CLAMP_MIX,SLOT_IN:clamp_mix_slot},
		{SLOT_ID:SlotIds.SLOT_MAP_EMPTY,SLOT_IN:map_empty_slot},
		{SLOT_ID:SlotIds.SLOT_AMPLITUDE,SLOT_IN:amplitude_slot},
		{SLOT_ID:SlotIds.SLOT_POWER,SLOT_IN:power_slot},
		{SLOT_ID:SlotIds.SLOT_DECAY,SLOT_IN:decay_slot},
		{SLOT_ID:SlotIds.SLOT_DC,SLOT_IN:dc_slot},
		{SLOT_ID:SlotIds.SLOT_ISOLATE,SLOT_IN:isolate_slot}
	]


func set_lerp_value(value:int)->void:
	lerp_value=value
	lerp_values.resize(0)


func set_extrapolate(value:int)->void:
	extrapolate=value
	extrapolate_values.resize(0)


func set_mix_value(value:float)->void:
	mix_value=value
	mix_values.resize(0)


func set_clamp_mix_value(value:float)->void:
	clamp_mix_value=value
	clamp_mix_values.resize(0)


func set_map_empty(value:float)->void:
	map_empty=value
	map_empty_values.resize(0)


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
	calculate_option_slot(lerp_values,lerp_slot,MapWaveNodeConstants.LERP_END,lerp_value)
	calculate_option_slot(extrapolate_values,extrapolate_slot,MapWaveNodeConstants.XERP_END,extrapolate)
	calculate_slot(mix_values,mix_slot,mix_value)
	calculate_diffuse_boolean_slot(clamp_mix_values,clamp_mix_slot,clamp_mix_value)
	calculate_boolean_slot(map_empty_values,map_empty_slot,map_empty)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	calculate_boolean_slot(isolate_values,isolate_slot,isolate)
	NODES.map_wave(output,max(1.0,size*range_length),fposmod(range_from*size,size),input_values,
		mapping_values,slope_left,slope_right,lerp_values,extrapolate_values,
		mix_values,clamp_mix_values,map_empty_values,isolate_values,
		amplitude_values,power_values,decay_values,dc_values
	)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as MapWaveNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"lerp_value","extrapolate","mix_value","clamp_mix_value","map_empty",
		"amplitude","power","decay","dc","isolate",
	])


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:MapWaveNodeComponent=.duplicate(container) as MapWaveNodeComponent
	nc.lerp_value=lerp_value
	nc.extrapolate=extrapolate
	nc.mix_value=mix_value
	nc.clamp_mix_value=clamp_mix_value
	nc.map_empty=map_empty
	nc.amplitude=amplitude
	nc.power=power
	nc.decay=decay
	nc.dc=dc
	nc.isolate=isolate
	return nc
