extends WaveComponent
class_name NoiseWave

const CHUNK_ID:String="nOIW"
const CHUNK_VERSION:int=0

var rng0:RandomNumberGenerator
var rng_seed:int
var tone:float
var pos0:float
var length:float
var pm:float

func _init().()->void:
	rng0=RandomNumberGenerator.new()
	rng_seed=randi()-0x80000000
	tone=1.0
	length=1.0
	pos0=0.0

func duplicate()->WaveComponent:
	var nc:NoiseWave=.duplicate() as NoiseWave
	nc.rng0=rng0
	nc.rng_seed=rng_seed
	nc.tone=tone
	nc.length=length
	nc.pos0=pos0
	return nc

func equals(other:WaveComponent)->bool:
	if !.equals(other):
		return false
	if other.get("CHUNK_ID")!=CHUNK_ID:
		return false
	if rng_seed!=other.rng_seed\
			or !are_equal_approx([tone,other.tone,pos0,other.pos0,length,other.length,pm,other.pm]):
		return false
	return true

func calculate(size:int,input:Array,caller:WaveComponent)->Array:
	set_modulator(size,pm,input,caller)
	DSP.noise(input,generated,pos0,length,rng_seed,tone,vol,output_mode);
	return generate_output(size,input,caller)

#

func serialize(out:ChunkedFile,components:Array)->void:
	serialize_start(out,CHUNK_ID,CHUNK_VERSION,components)
	out.store_32(rng_seed)
	out.store_float(tone)
	out.store_float(pos0)
	out.store_float(length)
	out.end_chunk()

#

func deserialize(inf:ChunkedFile,c:NoiseWave,components:Array,version:int)->void:
	deserialize_start(inf,c,components,version)
	c.rng_seed=inf.get_32()
	c.tone=inf.get_float()
	c.pos0=inf.get_float()
	c.length=inf.get_float()
