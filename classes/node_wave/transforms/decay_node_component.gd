extends WaveNodeComponent
class_name DecayNodeComponent

const NODE_TYPE:String="Decay"


var input_slot:Array=[]
var input_values:Array=[]
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
var dc_slot:Array=[]
var dc_values:Array=[]
var dc:float=0.0 setget set_dc
var isolate_slot:Array=[]
var isolate_values:Array=[]
var isolate:float=1.0 setget set_isolate


func _init()->void:
	inputs=[
		{SLOT_ID:SlotIds.SLOT_INPUT,SLOT_IN:input_slot},
		{SLOT_ID:SlotIds.SLOT_DECAY,SLOT_IN:decay_slot},
		{SLOT_ID:SlotIds.SLOT_MIX,SLOT_IN:mix_slot},
		{SLOT_ID:SlotIds.SLOT_CLAMP_MIX,SLOT_IN:clamp_mix_slot},
		{SLOT_ID:SlotIds.SLOT_AMPLITUDE,SLOT_IN:amplitude_slot},
		{SLOT_ID:SlotIds.SLOT_POWER,SLOT_IN:power_slot},
		{SLOT_ID:SlotIds.SLOT_DC,SLOT_IN:dc_slot},
		{SLOT_ID:SlotIds.SLOT_ISOLATE,SLOT_IN:isolate_slot}
	]


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


func set_dc(value:float)->void:
	dc=value
	dc_values.resize(0)


func set_isolate(value:float)->void:
	isolate=value
	isolate_values.resize(0)


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	calculate_slot(input_values,input_slot,NAN)
	calculate_slot(mix_values,mix_slot,mix)
	calculate_diffuse_boolean_slot(clamp_mix_values,clamp_mix_slot,clamp_mix)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	calculate_boolean_slot(isolate_values,isolate_slot,isolate)
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	var t:float
	reset_decay(sz)
	for i in sz:
		t=calculate_decay(input_values[optr],decay_values[optr])
		t=lerp(input_values[optr],t,lerp(mix_values[optr],clamp(mix_values[optr],0.0,1.0),clamp_mix_values[optr]))
		output[optr]=pow(abs(t),power_values[optr])*sign(t)*amplitude_values[optr]+dc_values[optr]
		optr=(optr+1)&size_mask
	fill_out_of_region(sz,optr,input_values,isolate_values)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as DecayNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"mix","clamp_mix","amplitude","power","decay","isolate"
	])


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:DecayNodeComponent=.duplicate(container) as DecayNodeComponent
	nc.mix=mix
	nc.clamp_mix=clamp_mix
	nc.amplitude=amplitude
	nc.power=power
	nc.decay=decay
	nc.isolate=isolate
	return nc
