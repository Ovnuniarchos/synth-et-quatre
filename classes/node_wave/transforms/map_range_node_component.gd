extends WaveNodeComponent
class_name MapRangeNodeComponent

const NODE_TYPE:String="MapRange"


var input_slot:Array=[]
var input_values:Array=[]
var min_in_slot:Array=[]
var min_in_values:Array=[]
var min_in_value:float=-1.0 setget set_min_in_value
var max_in_slot:Array=[]
var max_in_values:Array=[]
var max_in_value:float=1.0 setget set_max_in_value
var min_out_slot:Array=[]
var min_out_values:Array=[]
var min_out_value:float=-1.0 setget set_min_out_value
var max_out_slot:Array=[]
var max_out_values:Array=[]
var max_out_value:float=1.0 setget set_max_out_value
var mix_slot:Array=[]
var mix_values:Array=[]
var mix_value:float=1.0 setget set_mix_value
var clamp_mix_slot:Array=[]
var clamp_mix_values:Array=[]
var clamp_mix_value:float=0.0 setget set_clamp_mix_value
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
		{SLOT_ID:SlotIds.SLOT_MIN_IN,SLOT_IN:min_in_slot},
		{SLOT_ID:SlotIds.SLOT_MAX_IN,SLOT_IN:max_in_slot},
		{SLOT_ID:SlotIds.SLOT_MIN_OUT,SLOT_IN:min_out_slot},
		{SLOT_ID:SlotIds.SLOT_MAX_OUT,SLOT_IN:max_out_slot},
		{SLOT_ID:SlotIds.SLOT_MIX,SLOT_IN:mix_slot},
		{SLOT_ID:SlotIds.SLOT_CLAMP_MIX,SLOT_IN:clamp_mix_slot},
		{SLOT_ID:SlotIds.SLOT_AMPLITUDE,SLOT_IN:amplitude_slot},
		{SLOT_ID:SlotIds.SLOT_POWER,SLOT_IN:power_slot},
		{SLOT_ID:SlotIds.SLOT_DECAY,SLOT_IN:decay_slot},
		{SLOT_ID:SlotIds.SLOT_DC,SLOT_IN:dc_slot},
		{SLOT_ID:SlotIds.SLOT_ISOLATE,SLOT_IN:isolate_slot}
	]


func set_min_in_value(value:float)->void:
	min_in_value=value
	min_in_values.resize(0)


func set_max_in_value(value:float)->void:
	max_in_value=value
	max_in_values.resize(0)


func set_min_out_value(value:float)->void:
	min_out_value=value
	min_out_values.resize(0)


func set_max_out_value(value:float)->void:
	max_out_value=value
	max_out_values.resize(0)


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
	calculate_slot(min_in_values,min_in_slot,min_in_value)
	calculate_slot(max_in_values,max_in_slot,max_in_value)
	calculate_slot(min_out_values,min_out_slot,min_out_value)
	calculate_slot(max_out_values,max_out_slot,max_out_value)
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
	reset_decay()
	for i in sz:
		t=range_lerp(
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
		)*amplitude_values[optr])+dc_values[optr]
		optr=(optr+1)&size_mask
	fill_out_of_region(sz,optr,input_values,isolate_values)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as MapRangeNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"min_in_value","max_in_value","min_out_value","max_out_value",
		"mix_value","clamp_mix_value","isolate","amplitude","power","decay","dc"
	])


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:MapRangeNodeComponent=.duplicate(container) as MapRangeNodeComponent
	nc.min_in_value=min_in_value
	nc.max_in_value=max_in_value
	nc.min_out_value=min_out_value
	nc.max_out_value=max_out_value
	nc.mix_value=mix_value
	nc.clamp_mix_value=clamp_mix_value
	nc.isolate=isolate
	nc.amplitude=amplitude
	nc.power=power
	nc.decay=decay
	nc.dc=dc
	return nc
