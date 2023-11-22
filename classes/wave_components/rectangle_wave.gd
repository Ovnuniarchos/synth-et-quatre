extends WaveComponent
class_name RectangleWave

const COMPONENT_ID:String="Rectangle"

var freq_mult:float
var phi0:float
var z_start:float
var n_start:float
var cycles:float
var pos0:float
var pm:float
var decay:float

func _init().()->void:
	freq_mult=1.0
	phi0=0.0
	z_start=0.5
	n_start=0.5
	cycles=0.0
	pos0=0.0
	pm=0.0
	decay=0.0

func duplicate()->WaveComponent:
	var nc:RectangleWave=.duplicate() as RectangleWave
	nc.freq_mult=freq_mult
	nc.phi0=phi0
	nc.z_start=z_start
	nc.n_start=n_start
	nc.cycles=cycles
	nc.pos0=pos0
	nc.pm=pm
	nc.decay=decay
	return nc

func equals(other:WaveComponent)->bool:
	if !.equals(other):
		return false
	if !are_equal_approx([
		freq_mult,other.freq_mult,phi0,other.phi0,z_start,other.z_start,
		n_start,other.n_start,cycles,other.cycles,pos0,other.pos0,pm,other.pm,
		decay,other.decay
	]):
		return false
	return true

func calculate(size:int,input:Array,caller:WaveComponent)->Array:
	set_modulator(size,pm,input,caller)
	DSP.rectangle(
		input,generated,modulator,pos0,phi0,freq_mult,cycles,pm,decay,
		z_start,n_start,vol,output_mode
	)
	return generate_output(size,input,caller)
