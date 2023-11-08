extends WaveComponent
class_name BpfFilter

const COMPONENT_ID:String="BandPass"

var cutoff_lo:float=1.0 setget set_cutoff_lo
var cutoff_hi:float=1.0 setget set_cutoff_hi
var coeffs:Array=[]
var taps:int=16 setget set_taps
var wave_size:int=-1

func _init().()->void:
	output_mode=OUT_MODE.REPLACE
	input_comp=null
	cutoff_lo=1.0
	taps=16

func duplicate()->WaveComponent:
	var nc:BpfFilter=.duplicate() as BpfFilter
	nc.set_taps(taps)
	nc.set_cutoff_lo(cutoff_lo)
	nc.set_cutoff_hi(cutoff_hi)
	return nc

func equals(other:WaveComponent)->bool:
	if !.equals(other):
		return false
	if taps!=other.taps or !are_equal_approx([cutoff_lo,other.cutoff_lo,cutoff_hi,other.cutoff_hi]):
		return false
	return true

func calculate(size:int,input:Array,caller:WaveComponent)->Array:
	if size!=wave_size:
		wave_size=size
		set_coeffs()
	if caller==null:
		GLOBALS.array_fill(generated,0.0,size)
		is_generated=false
	if input_comp!=null:
		if !input_comp.is_generated and caller==null:
			input_comp.calculate(size,input,self)
		modulator=input_comp.generated
	else:
		modulator=input
	DSP.convolution_filter(modulator,generated,coeffs)
	return generate_output(size,input,caller)

func set_taps(t:int)->void:
	taps=t
	set_coeffs()

func set_cutoff_lo(c:float)->void:
	cutoff_lo=c
	set_coeffs()

func set_cutoff_hi(c:float)->void:
	cutoff_hi=c
	set_coeffs()

func set_coeffs()->void:
	if wave_size<1:
		return
	coeffs.resize((taps*2)+1)
	var fl:float=cutoff_lo/wave_size
	var fh:float=cutoff_hi/wave_size
	var ol:float=TAU*fl
	var oh:float=TAU*fh
	var sum:float=0.0
	for i in range(-taps,taps+1):
		var t:float
		if i==0:
			t=2.0*(fh-fl)
		else:
			t=(sin(oh*i)-sin(ol*i))/(PI*i)
		coeffs[i+taps]=t
		sum+=abs(t)
	if sum>0.0:
		for i in range(coeffs.size()):
			coeffs[i]/=sum
