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
	rng0.seed=rng_seed
	var i_min:int=pos0*size
	var i_max:int=length*size
	var dsample:float=0.0
	var j:int
	var v0:float=rng0.randf_range(-1.0,1.0)
	var v1:float=rng0.randf_range(-1.0,1.0)
	var v_min:float=2.0
	var v_max:float=-2.0
	for i in range(0,size):
		j=(i+i_min)%size
		if i<i_max:
			dsample+=tone
			if dsample>=1.0:
				dsample-=1.0
				v0=v1
				v1=rng0.randf_range(-1.0,1.0)
			generated[j]=lerp(v0,v1,ease(dsample,-2.0))
			v_min=min(v_min,generated[j])
			v_max=max(v_max,generated[j])
		else:
			generated[j]=0.0
	for i in range(0,size):
		j=(i+i_min)%size
		if i<i_max:
			generated[j]=range_lerp(generated[j],v_min,v_max,-1.0,1.0)
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

func deserialize(inf:ChunkedFile,c:NoiseWave,components:Array)->void:
	deserialize_start(inf,c,components)
	c.rng_seed=inf.get_32()
	c.tone=inf.get_float()
	c.pos0=inf.get_float()
	c.length=inf.get_float()
