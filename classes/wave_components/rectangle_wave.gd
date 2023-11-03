extends WaveComponent
class_name RectangleWave

const COMPONENT_ID:String="Rectangle"
const CHUNK_ID:String="rECW"
const CHUNK_VERSION:int=0

var freq_mult:float=1.0
var phi0:float=0.0
var z_start:float=0.5
var n_start:float=0.5
var cycles:float=0.0
var pos0:float=0.0
var pm:float=0.0

func _init().()->void:
	freq_mult=1.0
	phi0=0.0
	z_start=0.5
	n_start=0.5
	cycles=0.0
	pos0=0.0
	pm=0.0

func duplicate()->WaveComponent:
	var nc:RectangleWave=.duplicate() as RectangleWave
	nc.freq_mult=freq_mult
	nc.phi0=phi0
	nc.z_start=z_start
	nc.n_start=n_start
	nc.cycles=cycles
	nc.pos0=pos0
	nc.pm=pm
	return nc

func equals(other:WaveComponent)->bool:
	if !.equals(other):
		return false
	if !are_equal_approx([
				freq_mult,other.freq_mult,phi0,other.phi0,z_start,other.z_start,
				n_start,other.n_start,cycles,other.cycles,pos0,other.pos0,pm,other.pm
			]):
		return false
	return true

func calculate(size:int,input:Array,caller:WaveComponent)->Array:
	set_modulator(size,pm,input,caller)
	DSP.rectangle(input,generated,modulator,pos0,phi0,freq_mult,cycles,pm,z_start,n_start,vol,output_mode)
	return generate_output(size,input,caller)

#

func serialize(out:ChunkedFile,components:Array)->void:
	serialize_start(out,CHUNK_ID,CHUNK_VERSION,components)
	out.store_float(freq_mult)
	out.store_float(phi0)
	out.store_float(z_start)
	out.store_float(n_start)
	out.store_float(cycles)
	out.store_float(pos0)
	out.store_float(pm)
	out.end_chunk()

#

func deserialize(inf:ChunkedFile,c:RectangleWave,components:Array,version:int)->void:
	deserialize_start(inf,c,components,version)
	c.freq_mult=inf.get_float()
	c.phi0=inf.get_float()
	c.z_start=inf.get_float()
	c.n_start=inf.get_float()
	c.cycles=inf.get_float()
	c.pos0=inf.get_float()
	c.pm=inf.get_float()
