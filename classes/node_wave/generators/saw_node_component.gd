extends WaveNodeComponent
class_name SawNodeComponent


const NODE_TYPE:String="Saw"


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
var range_from:float=0.0
var range_length:float=1.0
var quarter_slots:Array=[[],[],[],[]]
var quarter_values:Array=[[],[],[],[]]
var quarters:Array=[0,1,2,3]


func _init()->void:
	._init()
	inputs=[
		frequency_slot,amplitude_slot,phi0_slot,power_slot,decay_slot,dc_slot,
		quarter_slots[0],quarter_slots[1],quarter_slots[2],quarter_slots[3]
	]


func calculate()->Array:
	if output_valid:
		return output
	calculate_slot(frequency_values,frequency_slot,frequency)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(phi0_values,phi0_slot,phi0)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay) # TODO Calculate
	calculate_slot(dc_values,dc_slot,dc)
	for i in 4:
		calculate_option_slot(
			quarter_values[i],quarter_slots[i],
			[0,1,2,3,4,5,6,7,8,9,10,11,12],
			quarters[i]
		)
	clear_array(output,size)
	var sz:int=max(1.0,size*range_length)
	var cycle:float=1.0/sz
	var phi:float
	var iphi:float=0.0
	var q:float
	var optr:int=fposmod(range_from*size,size)
	var qts:Array=[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0,0.5,0.0,-0.5,-1.0]
	var out0:float=-amplitude
	var dec:float=1.0
	for i in sz:
		phi=(iphi*frequency_values[i])+phi0_values[i]
		q=fposmod(phi,0.25)*2.0
		qts[0]=q-1.0
		qts[1]=q-0.5
		qts[2]=q
		qts[3]=q+0.5
		qts[4]=1.0-q
		qts[5]=0.5-q
		qts[6]=-q
		qts[7]=-0.5-q
		q=qts[quarter_values[fposmod(phi,1.0)*4.0][i]]
		output[optr]=dc_values[i]+pow(abs(q),power_values[i])*sign(q)*amplitude_values[i]
		q=output[optr]-out0
		if abs(q)>0.0001 and sign(q)!=sign(output[optr]):
			dec=max(0.0,dec-(pow(decay_values[i],1.0)*128.0/sz))
		else:
			dec=1.0
		out0=output[optr]
		output[optr]*=dec
		iphi+=cycle
		optr=(optr+1)&(size-1)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as SawNodeComponent)==null:
		return false
	return is_equal_approx(other.frequency,frequency) and is_equal_approx(other.amplitude,amplitude)\
		and is_equal_approx(other.phi0,phi0) and is_equal_approx(other.power,power)\
		and is_equal_approx(other.decay,decay) and is_equal_approx(dc,other.dc)\
		and quarters[0]==other.quarters[0] and quarters[1]==other.quarters[1]\
		and quarters[2]==other.quarters[2] and quarters[3]==other.quarters[3]
