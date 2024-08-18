extends WaveComponent
class_name NoiseWave

const COMPONENT_ID:String="Noise"

var rng0:RandomNumberGenerator
var rng_seed:int
var tone:float
var pos0:float
var length:float
var pm:float
var power:float

func _init().()->void:
	rng0=RandomNumberGenerator.new()
	rng_seed=randi()-0x80000000
	tone=1.0
	length=1.0
	pos0=0.0
	power=1.0

func duplicate()->WaveComponent:
	var nc:NoiseWave=.duplicate() as NoiseWave
	nc.rng0=rng0
	nc.rng_seed=rng_seed
	nc.tone=tone
	nc.length=length
	nc.pos0=pos0
	nc.power=power
	return nc

func equals(other:WaveComponent)->bool:
	if !.equals(other):
		return false
	if rng_seed!=other.rng_seed\
		or !are_equal_approx([
			tone,other.tone,pos0,other.pos0,length,other.length,pm,other.pm,
			power,other.power
		]):
		return false
	return true

func calculate(size:int,input:Array,caller:WaveComponent)->Array:
	set_modulator(size,pm,input,caller)
	DSP.noise(input,generated,pos0,length,rng_seed,tone,power,vol,output_mode)
	return generate_output(size,input,caller)
