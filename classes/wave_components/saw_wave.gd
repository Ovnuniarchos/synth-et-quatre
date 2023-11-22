extends WaveComponent
class_name SawWave

const COMPONENT_ID:String="Saw"

enum HALF{H0,H1,H2,H3,HZ,HH,HL}

var freq_mult:float
var phi0:float
var halves:Array
var cycles:float
var pos0:float
var pm:float
var power:float
var decay:float

func _init().()->void:
	freq_mult=1.0
	halves=[HALF.H0,HALF.H1]
	phi0=0.0
	cycles=0.0
	pos0=0.0
	pm=0.0
	power=1.0
	decay=0.0

func duplicate()->WaveComponent:
	var nc:SawWave=.duplicate() as SawWave
	nc.halves=halves.duplicate()
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
	if halves[0]!=other.halves[0] or halves[1]!=other.halves[1]:
		return false
	if !are_equal_approx([
				freq_mult,other.freq_mult,phi0,other.phi0,cycles,other.cycles,
				pos0,other.pos0,pm,other.pm,power,other.power,decay,other.decay
			]):
		return false
	return true


func calculate(size:int,input:Array,caller:WaveComponent)->Array:
	set_modulator(size,pm,input,caller)
	DSP.saw(
		input,generated,modulator,pos0,phi0,freq_mult,cycles,pm,power,decay,
		halves[0],halves[1],vol,output_mode
	)
	return generate_output(size,input,caller)
