extends WaveNodeComponent
class_name TriangleNodeComponent


const NODE_TYPE:String="Triangle"


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
var quarters:Array=TriangleNodeConstants.get_defaults()


func _init()->void:
	._init()
	inputs=[
		frequency_slot,amplitude_slot,phi0_slot,power_slot,decay_slot,dc_slot,
		quarter_slots[0],quarter_slots[1],quarter_slots[2],quarter_slots[3]
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
			TriangleNodeConstants.AS_ARRAY,
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
	return .equals(other) and are_equal_approx(other,[
		"frequency","amplitude","phi0","power","decay","dc","quarters"
	])
