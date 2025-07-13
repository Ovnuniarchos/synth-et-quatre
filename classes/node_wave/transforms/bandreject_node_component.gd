extends WaveNodeComponent
class_name BandRejectNodeComponent

const NODE_TYPE:String="BandReject"


var input_slot:Array=[]
var input_values:Array=[]
var cutofflo_slot:Array=[]
var cutofflo_values:Array=[]
var cutofflo:float=0.0 setget set_cutofflo
var cutoffhi_slot:Array=[]
var cutoffhi_values:Array=[]
var cutoffhi:float=0.0 setget set_cutoffhi
var attenuation_slot:Array=[]
var attenuation_values:Array=[]
var attenuation:float=0.0 setget set_attenuation
var resonance_slot:Array=[]
var resonance_values:Array=[]
var resonance:float=0.0 setget set_resonance
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
var steps:int=1


func _init()->void:
	inputs=[
		{SLOT_ID:SlotIds.SLOT_INPUT,SLOT_IN:input_slot},
		{SLOT_ID:SlotIds.SLOT_CUTOFFLO,SLOT_IN:cutofflo_slot},
		{SLOT_ID:SlotIds.SLOT_CUTOFFHI,SLOT_IN:cutoffhi_slot},
		{SLOT_ID:SlotIds.SLOT_ATTENUATION,SLOT_IN:attenuation_slot},
		{SLOT_ID:SlotIds.SLOT_RESONANCE,SLOT_IN:resonance_slot},
		{SLOT_ID:SlotIds.SLOT_MIX,SLOT_IN:mix_slot},
		{SLOT_ID:SlotIds.SLOT_CLAMP_MIX,SLOT_IN:clamp_mix_slot},
		{SLOT_ID:SlotIds.SLOT_AMPLITUDE,SLOT_IN:amplitude_slot},
		{SLOT_ID:SlotIds.SLOT_POWER,SLOT_IN:power_slot},
		{SLOT_ID:SlotIds.SLOT_DECAY,SLOT_IN:decay_slot},
		{SLOT_ID:SlotIds.SLOT_DC,SLOT_IN:dc_slot},
		{SLOT_ID:SlotIds.SLOT_ISOLATE,SLOT_IN:isolate_slot}
	]


func set_cutofflo(value:float)->void:
	cutofflo=value
	cutofflo_values.resize(0)


func set_cutoffhi(value:float)->void:
	cutoffhi=value
	cutoffhi_values.resize(0)


func set_attenuation(value:float)->void:
	attenuation=value
	attenuation_values.resize(0)


func set_resonance(value:float)->void:
	resonance=value
	resonance_values.resize(0)


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
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	var bounds:Array=[0.0,0.0,0.0,0.0,0.0,0.0]
	calculate_slot(input_values,input_slot,NAN)
	NODES.find_amplitude_bounds(input_values,sz,optr,bounds)
	if bounds[5]==INF:
		output_valid=true
		return output
	calculate_diffuse_boolean_slot(cutofflo_values,cutofflo_slot,1.0)
	calculate_diffuse_boolean_slot(cutoffhi_values,cutoffhi_slot,1.0)
	calculate_diffuse_boolean_slot(attenuation_values,attenuation_slot,attenuation)
	calculate_diffuse_boolean_slot(resonance_values,resonance_slot,resonance)
	calculate_slot(mix_values,mix_slot,mix)
	calculate_diffuse_boolean_slot(clamp_mix_values,clamp_mix_slot,clamp_mix)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	calculate_boolean_slot(isolate_values,isolate_slot,isolate)
	NODES.band_reject(output,sz,optr,cutofflo,cutoffhi,steps,
		input_values,cutofflo_values,cutoffhi_values,attenuation_values,resonance_values,
		mix_values,clamp_mix_values,isolate_values,
		amplitude_values,power_values,decay_values,dc_values
	)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as BandRejectNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"cutofflo","cutoffhi","attenuation","mix","clamp_mix","amplitude","power","isolate",
		"decay","dc","steps"
	])


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:BandRejectNodeComponent=.duplicate(container) as BandRejectNodeComponent
	nc.cutofflo=cutofflo
	nc.cutoffhi=cutoffhi
	nc.attenuation=attenuation
	nc.mix=mix
	nc.clamp_mix=clamp_mix
	nc.amplitude=amplitude
	nc.power=power
	nc.decay=decay
	nc.dc=dc
	nc.isolate=isolate
	nc.steps=steps
	return nc
