extends WaveComponent
class_name TriangleWave

const COMPONENT_ID:String="Triangle"

enum QUARTER{Q0,Q1,Q2,Q3,QH,QZ,QL}

var freq_mult:float
var phi0:float
var quarters:Array
var cycles:float
var pos0:float
var pm:float
var power:float
var decay:float

func _init().()->void:
	freq_mult=1.0
	quarters=[QUARTER.Q0,QUARTER.Q1,QUARTER.Q2,QUARTER.Q3]
	phi0=0.0
	cycles=0.0
	pos0=0.0
	pm=0.0
	power=1.0
	decay=0.0

func duplicate()->WaveComponent:
	var nc:TriangleWave=.duplicate() as TriangleWave
	nc.quarters=quarters.duplicate()
	nc.freq_mult=freq_mult
	nc.phi0=phi0
	nc.cycles=cycles
	nc.pos0=pos0
	nc.pm=pm
	nc.power=power
	nc.decay=decay
	return nc

func equals(other:WaveComponent)->bool:
	if !.equals(other):
		return false
	if quarters[0]!=other.quarters[0] or quarters[1]!=other.quarters[1]\
		or quarters[2]!=other.quarters[2] or quarters[3]!=other.quarters[3]:
		return false
	if !are_equal_approx([
		freq_mult,other.freq_mult,phi0,other.phi0,cycles,other.cycles,
		pos0,other.pos0,pm,other.pm,power,other.power,decay,other.decay
	]):
		return false
	return true

func calculate(size:int,input:Array,caller:WaveComponent)->Array:
	set_modulator(size,pm,input,caller)
	DSP.triangle(
		input,generated,modulator,pos0,phi0,freq_mult,cycles,pm,power,decay,
		vol,output_mode,quarters[0],quarters[1],quarters[2],quarters[3]
	)
	return generate_output(size,input,caller)
