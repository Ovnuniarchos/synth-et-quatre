extends WaveComponent
class_name SineWave

const CHUNK_ID:String="sINW"

enum QUARTER{Q0,Q1,Q2,Q3,QZ,QH,QL}

var quarters:Array=[QUARTER.Q0,QUARTER.Q1,QUARTER.Q2,QUARTER.Q3]
var freq_mult:float=1.0
var phi0:float=0.0
var cycles:float=0.0
var pos0:float=0.0
var pm:float=0.0

func _init().()->void:
	quarters=[QUARTER.Q0,QUARTER.Q1,QUARTER.Q2,QUARTER.Q3]
	freq_mult=1.0
	phi0=0.0
	cycles=0.0
	pos0=0.0
	pm=0.0

func duplicate()->WaveComponent:
	var nc:SineWave=.duplicate() as SineWave
	nc.quarters=quarters.duplicate()
	nc.freq_mult=freq_mult
	nc.phi0=phi0
	nc.cycles=cycles
	nc.pos0=pos0
	nc.pm=pm
	return nc

func calculate(size:int,input:Array,caller:WaveComponent)->Array:
	set_modulator(size,pm,input,caller)
	var dphi:float=1.0/size
	var phi:float=-dphi
	for i in range(0,size):
		phi+=dphi
		var cphi:float=fmod(phi-pos0+1.0,1.0)
		if (cycles>0 and (cphi*freq_mult)>=cycles) or cphi<0.0:
			generated[i]=0.0
			continue
		var rphi:float=fmod((cphi*freq_mult)+phi0+(modulator[i]*pm)+1.0,1.0)
		var qphi:float=fmod(rphi,0.25)
		var q:int
		if rphi<0.25:
			q=quarters[0]
		elif rphi<0.5:
			q=quarters[1]
		elif rphi<0.75:
			q=quarters[2]
		else:
			q=quarters[3]
		if q==QUARTER.Q0:
			generated[i]=sin(qphi*TAU)
		elif q==QUARTER.Q1:
			generated[i]=sin((0.25-qphi)*TAU)
		elif q==QUARTER.Q2:
			generated[i]=-sin(qphi*TAU)
		elif q==QUARTER.Q3:
			generated[i]=-sin((0.25-qphi)*TAU)
		elif q==QUARTER.QZ:
			generated[i]=0.0
		elif q==QUARTER.QH:
			generated[i]=1.0
		else:
			generated[i]=-1.0
	return generate_output(size,input,caller)

#

func serialize(out:ChunkedFile,components:Array)->void:
	serialize_start(out,CHUNK_ID,components)
	out.store_float(freq_mult)
	out.store_float(phi0)
	out.store_8(quarters[0])
	out.store_8(quarters[1])
	out.store_8(quarters[2])
	out.store_8(quarters[3])
	out.store_float(cycles)
	out.store_float(pos0)
	out.store_float(pm)
	out.end_chunk()

#

func deserialize(inf:ChunkedFile,c:SineWave,components:Array)->void:
	deserialize_start(inf,c,components)
	c.freq_mult=inf.get_float()
	c.phi0=inf.get_float()
	c.quarters[0]=inf.get_8()
	c.quarters[1]=inf.get_8()
	c.quarters[2]=inf.get_8()
	c.quarters[3]=inf.get_8()
	c.cycles=inf.get_float()
	c.pos0=inf.get_float()
	c.pm=inf.get_float()
