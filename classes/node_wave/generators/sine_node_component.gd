extends WaveNodeComponent
class_name SineNodeComponent


const NODE_TYPE:String="Sine"


var frequency_slot:Array=[]
var frequency_values:Array=[]
var frequency:float=1.0 setget set_frequency
var amplitude_slot:Array=[]
var amplitude_values:Array=[]
var amplitude:float=1.0 setget set_amplitude
var phi0_slot:Array=[]
var phi0_values:Array=[]
var phi0:float=0.0 setget set_phi0
var power_slot:Array=[]
var power_values:Array=[]
var power:float=1.0 setget set_power
var decay_slot:Array=[]
var decay_values:Array=[]
var decay:float=0.0 setget set_decay
var dc_slot:Array=[]
var dc_values:Array=[]
var dc:float=0.0 setget set_dc
var quarter_slots:Array=[[],[],[],[]]
var quarter_values:Array=[[],[],[],[]]
var quarters:Array=SineNodeConstants.get_defaults()


func _init()->void:
	inputs=[
		{SLOT_ID:SlotIds.SLOT_FREQUENCY,SLOT_IN:frequency_slot},
		{SLOT_ID:SlotIds.SLOT_AMPLITUDE,SLOT_IN:amplitude_slot},
		{SLOT_ID:SlotIds.SLOT_PHI0,SLOT_IN:phi0_slot},
		{SLOT_ID:SlotIds.SLOT_POWER,SLOT_IN:power_slot},
		{SLOT_ID:SlotIds.SLOT_DECAY,SLOT_IN:decay_slot},
		{SLOT_ID:SlotIds.SLOT_DC,SLOT_IN:dc_slot},
		{SLOT_ID:SlotIds.SLOT_QUARTER0,SLOT_IN:quarter_slots[0]},
		{SLOT_ID:SlotIds.SLOT_QUARTER1,SLOT_IN:quarter_slots[1]},
		{SLOT_ID:SlotIds.SLOT_QUARTER2,SLOT_IN:quarter_slots[2]},
		{SLOT_ID:SlotIds.SLOT_QUARTER3,SLOT_IN:quarter_slots[3]}
	]


func set_frequency(value:float)->void:
	frequency=value
	frequency_values.resize(0)


func set_amplitude(value:float)->void:
	amplitude=value
	amplitude_values.resize(0)


func set_phi0(value:float)->void:
	phi0=value
	phi0_values.resize(0)


func set_power(value:float)->void:
	power=value
	power_values.resize(0)


func set_decay(value:float)->void:
	decay=value
	decay_values.resize(0)


func set_dc(value:float)->void:
	dc=value
	dc_values.resize(0)


func set_quarter(quarter:int,value:int)->void:
	quarters[quarter]=value
	quarter_values[quarter].resize(0)


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	calculate_slot(frequency_values,frequency_slot,frequency)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(phi0_values,phi0_slot,phi0)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	for i in 4:
		calculate_option_slot(
			quarter_values[i],quarter_slots[i],
			SineNodeConstants.SNQ_MAX,
			quarters[i]
		)
	NODES.sine(output,max(1.0,size*range_length),fposmod(range_from*size,size),
		frequency_values,amplitude_values,phi0_values,power_values,decay_values,dc_values,
		quarter_values[0],quarter_values[1],quarter_values[2],quarter_values[3]
	)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as SineNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"frequency","amplitude","phi0","power","decay","dc","quarters"
	])


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:SineNodeComponent=.duplicate(container) as SineNodeComponent
	nc.frequency=frequency
	nc.amplitude=amplitude
	nc.phi0=phi0
	nc.power=power
	nc.decay=decay
	nc.dc=dc
	for i in 4:
		nc.quarters[i]=quarters[i].duplicate()
	return nc
