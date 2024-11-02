extends WaveNodeComponent
class_name NoiseNodeComponent


const NODE_TYPE:String="Noise"


var noiz:OpenSimplexNoise=OpenSimplexNoise.new()
var noise_seed:int=0
var amplitude_slot:Array=[]
var amplitude_values:Array=[]
var amplitude:float=1.0
var decay_slot:Array=[]
var decay_values:Array=[]
var decay:float=0.0
var power_slot:Array=[]
var power_values:Array=[]
var power:float=1.0
var dc_slot:Array=[]
var dc_values:Array=[]
var dc:float=0.0
var octaves_slot:Array=[]
var octaves_values:Array=[]
var octaves:int=9
var frequency_slot:Array=[]
var frequency_values:Array=[]
var frequency:float=32.0
var persistence_slot:Array=[]
var persistence_values:Array=[]
var persistence:float=0.5
var lacunarity_slot:Array=[]
var lacunarity_values:Array=[]
var lacunarity:float=2.0
var randomness_slot:Array=[]
var randomness_values:Array=[]
var randomness:float=1.0


func _init()->void:
	._init()
	inputs=[
		amplitude_slot,decay_slot,power_slot,dc_slot,octaves_slot,frequency_slot,
		persistence_slot,lacunarity_slot,randomness_slot
	]


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	calculate_slot(amplitude_values,amplitude_slot,amplitude)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(dc_values,dc_slot,dc)
	calculate_slot(octaves_values,octaves_slot,octaves)
	calculate_slot(frequency_values,frequency_slot,frequency)
	calculate_slot(persistence_values,persistence_slot,persistence)
	calculate_slot(lacunarity_values,lacunarity_slot,lacunarity)
	calculate_slot(randomness_values,randomness_slot,randomness)
	seed(noise_seed)
	noiz.seed=noise_seed
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	var cycle:float=1.0/sz
	var phi:float=0.0
	var mx:float=-INF
	var mn:float=INF
	var q:float
	for i in sz:
		noiz.persistence=persistence_values[optr]
		noiz.lacunarity=lacunarity_values[optr]
		noiz.period=1.0/frequency_values[optr] if abs(frequency_values[optr])>0.0001 else 0.0
		noiz.octaves=octaves_values[optr]
		q=lerp(noiz.get_noise_1d(phi),noiz.get_noise_1d(phi-1.0),phi)\
			+rand_range(-randomness_values[optr],randomness_values[optr])
		output[optr]=pow(abs(q),power_values[optr])*sign(q)
		mx=max(mx,output[optr])
		mn=min(mn,output[optr])
		optr=(optr+1)&size_mask
		phi+=cycle
	optr=fposmod(range_from*size,size)
	reset_decay()
	for i in sz:
		output[optr]=calculate_decay(
			range_lerp(output[optr],mn,mx,-amplitude_values[optr],amplitude_values[optr])+dc_values[optr],
			decay_values[optr],sz
		)
		optr=(optr+1)&size_mask
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as NoiseNodeComponent)==null:
		return false
	return .equals(other) and noise_seed==other.noise_seed and is_equal_approx(amplitude,other.amplitude)\
		and is_equal_approx(decay,other.decay) and is_equal_approx(dc,other.dc) and octaves==other.octaves\
		and is_equal_approx(frequency,other.frequency) and is_equal_approx(persistence,other.persistence)\
		and is_equal_approx(lacunarity,other.lacunarity) and is_equal_approx(randomness,other.randomness)
