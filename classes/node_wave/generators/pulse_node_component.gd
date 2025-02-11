extends WaveNodeComponent
class_name PulseNodeComponent


const NODE_TYPE:String="Pulse"


var ppulse_start_slot:Array=[]
var ppulse_start_values:Array=[]
var ppulse_start:float=0.0
var ppulse_length_slot:Array=[]
var ppulse_length_values:Array=[]
var ppulse_length:float=0.5
var ppulse_amplitude_slot:Array=[]
var ppulse_amplitude_values:Array=[]
var ppulse_amplitude:float=1.0
var npulse_start_slot:Array=[]
var npulse_start_values:Array=[]
var npulse_start:float=0.5
var npulse_length_slot:Array=[]
var npulse_length_values:Array=[]
var npulse_length:float=0.5
var npulse_amplitude_slot:Array=[]
var npulse_amplitude_values:Array=[]
var npulse_amplitude:float=1.0
var frequency_slot:Array=[]
var frequency_values:Array=[]
var frequency:float=1.0
var amplitude_slot:Array=[]
var amplitude_values:Array=[]
var amplitude:float=1.0
var phi0_slot:Array=[]
var phi0_values:Array=[]
var phi0:float=0.0
var decay_slot:Array=[]
var decay_values:Array=[]
var decay:float=0.0
var dc_slot:Array=[]
var dc_values:Array=[]
var dc:float=0.0


func _init()->void:
	inputs=[
		{SLOT_ID:SlotIds.SLOT_FREQUENCY,SLOT_IN:frequency_slot},
		{SLOT_ID:SlotIds.SLOT_AMPLITUDE,SLOT_IN:amplitude_slot},
		{SLOT_ID:SlotIds.SLOT_PHI0,SLOT_IN:phi0_slot},
		{SLOT_ID:SlotIds.SLOT_DECAY,SLOT_IN:decay_slot},
		{SLOT_ID:SlotIds.SLOT_DC,SLOT_IN:dc_slot},
		{SLOT_ID:SlotIds.SLOT_POS_PULSE_START,SLOT_IN:ppulse_start_slot},
		{SLOT_ID:SlotIds.SLOT_POS_PULSE_LENGTH,SLOT_IN:ppulse_length_slot},
		{SLOT_ID:SlotIds.SLOT_POS_PULSE_AMPLITUDE,SLOT_IN:ppulse_amplitude_slot},
		{SLOT_ID:SlotIds.SLOT_NEG_PULSE_START,SLOT_IN:npulse_start_slot},
		{SLOT_ID:SlotIds.SLOT_NEG_PULSE_LENGTH,SLOT_IN:npulse_length_slot},
		{SLOT_ID:SlotIds.SLOT_NEG_PULSE_AMPLITUDE,SLOT_IN:npulse_amplitude_slot}
	]


func set_ppulse_start(value:float)->void:
	ppulse_start=value
	ppulse_start_values.resize(0)


func set_ppulse_length(value:float)->void:
	ppulse_length=value
	ppulse_length_values.resize(0)


func set_ppulse_amplitude(value:float)->void:
	ppulse_amplitude=value
	ppulse_amplitude_values.resize(0)


func set_npulse_start(value:float)->void:
	npulse_start=value
	npulse_start_values.resize(0)


func set_npulse_length(value:float)->void:
	npulse_length=value
	npulse_length_values.resize(0)


func set_npulse_amplitude(value:float)->void:
	npulse_amplitude=value
	npulse_amplitude_values.resize(0)


func set_frequency(value:float)->void:
	frequency=value
	frequency_values.resize(0)


func set_amplitude(value:float)->void:
	amplitude=value
	amplitude_values.resize(0)


func set_phi0(value:float)->void:
	phi0=value
	phi0_values.resize(0)


func set_decay(value:float)->void:
	decay=value
	decay_values.resize(0)


func set_dc(value:float)->void:
	dc=value
	dc_values.resize(0)


func calculate()->Array:
	if output_valid:
		return output
	var pps:Array=[]
	var ppl:Array=[]
	var nps:Array=[]
	var npl:Array=[]
	clear_array(output,size,NAN)
	calculate_slot(ppulse_start_values,ppulse_start_slot,ppulse_start)
	calculate_slot(ppulse_length_values,ppulse_length_slot,ppulse_length)
	calculate_slot(ppulse_amplitude_values,ppulse_amplitude_slot,ppulse_amplitude)
	calculate_slot(npulse_start_values,npulse_start_slot,npulse_start)
	calculate_slot(npulse_length_values,npulse_length_slot,npulse_length)
	calculate_slot(npulse_amplitude_values,npulse_amplitude_slot,npulse_amplitude)
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	pps.resize(sz)
	ppl.resize(sz)
	nps.resize(sz)
	npl.resize(sz)
	for i in sz:
		pps[i]=fposmod(ppulse_start_values[optr],1.0)
		ppl[i]=clamp(ppulse_length_values[optr],0.0,1.0)+pps[i]
		nps[i]=fposmod(npulse_start_values[optr],1.0)
		npl[i]=clamp(npulse_length_values[optr],0.0,1.0)+nps[i]
		optr=(optr+1)&size_mask
	calculate_slot(frequency_values,frequency_slot,frequency)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(phi0_values,phi0_slot,phi0)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	var cycle:float=1.0/sz
	var phi:float
	var iphi:float=0.0
	var q:float
	reset_decay(sz)
	optr=fposmod(range_from*size,size)
	for i in sz:
		phi=fposmod((iphi*frequency_values[optr])+phi0_values[optr],1.0)
		q=float(phi<ppl[i]-1.0 or (phi>=pps[i] and phi<ppl[i]))*ppulse_amplitude_values[optr]
		q-=float(phi<npl[i]-1.0 or (phi>=nps[i] and phi<npl[i]))*npulse_amplitude_values[optr]
		output[optr]=calculate_decay(q,decay_values[optr])*amplitude_values[optr]+dc_values[optr]
		iphi+=cycle
		optr=(optr+1)&size_mask
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as PulseNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"ppulse_start","ppulse_length","ppulse_amplitude","npulse_start","npulse_length","npulse_amplitude",
		"frequency","amplitude","phi0","decay","dc"
	])

func duplicate(container:Reference)->WaveNodeComponent:
	var nc:PulseNodeComponent=.duplicate(container) as PulseNodeComponent
	nc.ppulse_start=ppulse_start
	nc.ppulse_length=ppulse_length
	nc.ppulse_amplitude=ppulse_amplitude
	nc.npulse_start=npulse_start
	nc.npulse_length=npulse_length
	nc.npulse_amplitude=npulse_amplitude
	nc.frequency=frequency
	nc.amplitude=amplitude
	nc.phi0=phi0
	nc.decay=decay
	nc.dc=dc
	return nc
