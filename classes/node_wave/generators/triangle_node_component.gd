extends WaveNodeComponent
class_name TriangleNodeComponent


const NODE_TYPE:String="Triangle"


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
var quarter_slots:Array=[[],[],[],[]]
var quarter_values:Array=[[],[],[],[]]
var quarters:Array=TriangleNodeConstants.get_defaults()


func _init()->void:
	._init()
	inputs=[
		frequency_slot,amplitude_slot,phi0_slot,power_slot,decay_slot,dc_slot,
		quarter_slots[0],quarter_slots[1],quarter_slots[2],quarter_slots[3]
	]


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
			range(7),
			quarters[i]
		)
	var sz:int=max(1.0,size*range_length)
	var cycle:float=1.0/sz
	var phi:float
	var iphi:float=0.0
	var q:float
	var optr:int=fposmod(range_from*size,size)
	var qts:Array=TriangleNodeConstants.get_calc_array()
	reset_decay()
	for i in sz:
		phi=(iphi*frequency_values[optr])+phi0_values[optr]
		q=fposmod(phi,0.25)*4.0
		qts[0]=q
		qts[1]=1.0-q
		qts[2]=-q
		qts[3]=q-1.0
		q=qts[quarter_values[fposmod(phi,1.0)*4.0][optr]]
		q=dc_values[optr]+pow(abs(q),power_values[optr])*sign(q)*amplitude_values[optr]
		output[optr]=calculate_decay(q,decay_values[optr],sz)
		iphi+=cycle
		optr=(optr+1)&size_mask
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as TriangleNodeComponent)==null:
		return false
	return .equals(other) and is_equal_approx(other.frequency,frequency) and is_equal_approx(other.amplitude,amplitude)\
		and is_equal_approx(other.phi0,phi0) and is_equal_approx(other.power,power)\
		and is_equal_approx(other.decay,decay) and is_equal_approx(dc,other.dc)\
		and quarters[0]==other.quarters[0] and quarters[1]==other.quarters[1]\
		and quarters[2]==other.quarters[2] and quarters[3]==other.quarters[3]
