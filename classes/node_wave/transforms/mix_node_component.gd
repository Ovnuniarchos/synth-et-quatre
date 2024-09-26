extends WaveNodeComponent
class_name MixNodeComponent

const NODE_TYPE:String="Mix"


var a_slot:Array=[]
var a_values:Array=[]
var a_value:float=0.0
var b_slot:Array=[]
var b_values:Array=[]
var b_value:float=0.0
var clamp_in_slot:Array=[]
var clamp_in_values:Array=[]
var clamp_in_value:float=0.0
var op_slot:Array=[]
var op_values:Array=[]
var op_value:float=0.0
var mix_slot:Array=[]
var mix_values:Array=[]
var mix_value:float=MixNodeConstants.MIX_MIX
var power_slot:Array=[]
var power_values:Array=[]
var power:float=1.0
var decay_slot:Array=[]
var decay_values:Array=[]
var decay:float=0.0
var dc_slot:Array=[]
var dc_values:Array=[]
var dc:float=0.0


func _init()->void:
	._init()
	inputs=[
		a_slot,b_slot,mix_slot,clamp_in_slot,op_slot,power_slot,decay_slot,dc_slot
	]


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	calculate_slot(a_values,a_slot,a_value)
	calculate_slot(b_values,b_slot,b_value)
	calculate_slot(mix_values,mix_slot,mix_value)
	calculate_boolean_slot(clamp_in_values,clamp_in_slot,clamp_in_value)
	calculate_option_slot(op_values,op_slot,MixNodeConstants.AS_ARRAY,op_value)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	var t:float
	var mix:float
	var bidi_lerp:bool
	reset_decay()
	for i in sz:
		mix=lerp(mix_values[optr],clamp(mix_values[optr],0.0,1.0),clamp_in_values[optr])
		if op_values[optr]==MixNodeConstants.MIX_MIX:
			t=lerp(a_values[optr],b_values[optr],(mix+1.0)*0.5)
			bidi_lerp=false
		elif op_values[optr]==MixNodeConstants.MIX_ADD:
			t=a_values[optr]+b_values[optr]
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_SUB:
			t=a_values[optr]-b_values[optr]
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_MUL:
			t=a_values[optr]*b_values[optr]
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_DIV:
			t=a_values[optr]/b_values[optr] if b_values[optr]!=0.0 else 0.0
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_MOD:
			t=fmod(a_values[optr],b_values[optr]) if b_values[optr]!=0.0 else 0.0
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_FMOD:
			t=fposmod(a_values[optr],b_values[optr]) if b_values[optr]!=0.0 else 0.0
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_POWER:
			t=pow(abs(a_values[optr]),b_values[optr])*sign(a_values[optr])
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_MAX:
			t=max(a_values[optr],b_values[optr])
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_MIN:
			t=min(a_values[optr],b_values[optr])
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_GT:
			t=float(b_values[optr]>a_values[optr])
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_GE:
			t=float(b_values[optr]>=a_values[optr])
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_LT:
			t=float(b_values[optr]<a_values[optr])
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_LE:
			t=float(b_values[optr]<=a_values[optr])
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_CMP:
			t=sign(b_values[optr]-a_values[optr])
			bidi_lerp=true
		elif op_values[optr]==MixNodeConstants.MIX_SIGN_CP:
			t=abs(a_values[optr]) if b_values[optr]>0.0 else -abs(a_values[optr]) if b_values[optr]<0.0 else 0.0
			bidi_lerp=true
		if bidi_lerp:
			t=lerp(t,b_values[optr],mix) if mix>0.0 else lerp(t,a_values[optr],-mix)
		output[optr]=calculate_decay(pow(abs(t),power_values[optr])*sign(t),decay_values[optr],sz)+dc_values[optr]
		optr=(optr+1)&(size-1)
	output_valid=true
	return output
