extends WaveNodeComponent
class_name SineNodeComponent


const NODE_TYPE:String="Sine"


var frequency_slot:Array=[]
var frequency_values:Array=[]
var frequency:float=1.0
var amplitude_slot:Array=[]
var amplitude_values:Array=[]
var amplitude:float=1.0
var phi0_slot:Array=[]
var phi0_values:Array=[]
var phi0:float=0.0
var power_slot:Array=[]
var power_values:Array=[]
var power:float=1.0
var decay_slot:Array=[]
var decay_values:Array=[]
var decay:float=0.0
var dc_slot:Array=[]
var dc_values:Array=[]
var dc:float=0.0


func _init()->void:
	._init()
	inputs=[frequency_slot,amplitude_slot,phi0_slot,power_slot,decay_slot,dc_slot]


func calculate()->Array:
	if output_valid:
		return output
	calculate_slot(frequency_values,frequency_slot,frequency)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(phi0_values,phi0_slot,phi0)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	clear_array(output,size)
	var cycle:float=1.0/size
	for i in size:
		output[i]=dc_values[i]+sin(((i*cycle*frequency_values[i])+phi0_values[i])*TAU)*amplitude_values[i]
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as SineNodeComponent)==null:
		return false
	return is_equal_approx(other.frequency,frequency) and is_equal_approx(other.amplitude,amplitude)\
		and is_equal_approx(other.phi0,phi0) and is_equal_approx(other.power,power)\
		and is_equal_approx(other.decay,decay)
