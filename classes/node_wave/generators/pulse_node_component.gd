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
var range_from:float=0.0
var range_length:float=1.0


func _init()->void:
	._init()
	inputs=[
		frequency_slot,amplitude_slot,phi0_slot,decay_slot,dc_slot,
		ppulse_start_slot,ppulse_length_slot,ppulse_amplitude_slot,
		npulse_start_slot,npulse_length_slot,npulse_amplitude_slot
	]


func calculate()->Array:
	if output_valid:
		return output
	calculate_slot(ppulse_start_values,ppulse_start_slot,ppulse_start)
	calculate_slot(ppulse_length_values,ppulse_length_slot,ppulse_length)
	calculate_slot(ppulse_amplitude_values,ppulse_amplitude_slot,ppulse_amplitude)
	calculate_slot(npulse_start_values,npulse_start_slot,npulse_start)
	calculate_slot(npulse_length_values,npulse_length_slot,npulse_length)
	calculate_slot(npulse_amplitude_values,npulse_amplitude_slot,npulse_amplitude)
	for i in size:
		ppulse_start_values[i]=fposmod(ppulse_start_values[i],1.0)
		ppulse_length_values[i]=clamp(ppulse_length_values[i],0.0,1.0)+ppulse_start_values[i]
		npulse_start_values[i]=fposmod(npulse_start_values[i],1.0)
		npulse_length_values[i]=clamp(npulse_length_values[i],0.0,1.0)+npulse_start_values[i]
	calculate_slot(frequency_values,frequency_slot,frequency)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(phi0_values,phi0_slot,phi0)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	clear_array(output,size)
	var sz:int=max(1.0,size*range_length)
	var cycle:float=1.0/sz
	var phi:float
	var iphi:float=0.0
	var optr:int=fposmod(range_from*size,size)
	var q:float
	reset_decay()
	for i in sz:
		phi=fposmod((iphi*frequency_values[i])+phi0_values[i],1.0)
		q=float(phi<ppulse_length_values[i]-1.0 or (phi>=ppulse_start_values[i] and phi<ppulse_length_values[i]))*ppulse_amplitude_values[i]
		q-=float(phi<npulse_length_values[i]-1.0 or (phi>=npulse_start_values[i] and phi<npulse_length_values[i]))*npulse_amplitude_values[i]
		q=dc_values[i]+q*amplitude_values[i]
		output[optr]=calculate_decay(q,decay_values[i],sz)
		iphi+=cycle
		optr=(optr+1)&(size-1)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as PulseNodeComponent)==null:
		return false
	return is_equal_approx(other.ppulse_start,ppulse_start) and is_equal_approx(other.ppulse_length,ppulse_length)\
		and is_equal_approx(other.ppulse_amplitude,ppulse_amplitude) and is_equal_approx(other.npulse_start,npulse_start)\
		and is_equal_approx(other.npulse_length,npulse_length) and is_equal_approx(other.npulse_amplitude,npulse_amplitude)\
		and is_equal_approx(other.frequency,frequency) and is_equal_approx(other.amplitude,amplitude)\
		and is_equal_approx(other.phi0,phi0) and is_equal_approx(other.decay,decay)\
		and is_equal_approx(dc,other.dc)