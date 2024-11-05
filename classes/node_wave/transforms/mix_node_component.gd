extends WaveNodeComponent
class_name MixNodeComponent

const NODE_TYPE:String="Mix"


var a_slot:Array=[]
var a_values:Array=[]
var a_value:float=0.0
var b_slot:Array=[]
var b_values:Array=[]
var b_value:float=0.0
var mix_slot:Array=[]
var mix_values:Array=[]
var mix_value:float=1.0
var clamp_mix_slot:Array=[]
var clamp_mix_values:Array=[]
var clamp_mix_value:float=0.0
var op_slot:Array=[]
var op_values:Array=[]
var op_value:int=MixNodeConstants.MIX_MIX
var isolate_slot:Array=[]
var isolate_values:Array=[]
var isolate:float=0.0
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
		a_slot,b_slot,mix_slot,clamp_mix_slot,op_slot,power_slot,decay_slot,dc_slot,isolate_slot
	]


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	calculate_slot(a_values,a_slot,a_value)
	calculate_slot(b_values,b_slot,b_value)
	calculate_slot(mix_values,mix_slot,mix_value)
	calculate_diffuse_boolean_slot(clamp_mix_values,clamp_mix_slot,clamp_mix_value)
	calculate_option_slot(op_values,op_slot,MixNodeConstants.AS_ARRAY,op_value)
	calculate_diffuse_boolean_slot(isolate_values,isolate_slot,isolate)
	calculate_slot(power_values,power_slot,power)
	calculate_slot(decay_values,decay_slot,decay)
	calculate_slot(dc_values,dc_slot,dc)
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	var t:float
	var mix:float
	var a_in:float
	var b_in:float
	var bidi_lerp:bool
	reset_decay()
	for i in size:
		mix=lerp(mix_values[optr],clamp(mix_values[optr],0.0,1.0),clamp_mix_values[optr])
		a_in=b_values[optr] if is_nan(a_values[optr]) else a_values[optr]
		b_in=a_values[optr] if is_nan(b_values[optr]) else b_values[optr]
		bidi_lerp=true
		if op_values[optr]==MixNodeConstants.MIX_MIX:
			t=lerp(a_in,b_in,(mix+1.0)*0.5)
			bidi_lerp=false
		elif op_values[optr]==MixNodeConstants.MIX_ADD:
			t=a_in+b_in
		elif op_values[optr]==MixNodeConstants.MIX_SUB:
			t=a_in-b_in
		elif op_values[optr]==MixNodeConstants.MIX_MUL:
			t=a_in*b_in
		elif op_values[optr]==MixNodeConstants.MIX_DIV:
			t=a_in/b_in if b_in!=0.0 else 0.0
		elif op_values[optr]==MixNodeConstants.MIX_MOD:
			t=fmod(a_in,b_in) if b_in!=0.0 else 0.0
		elif op_values[optr]==MixNodeConstants.MIX_FMOD:
			t=fposmod(a_in,b_in) if b_in!=0.0 else 0.0
		elif op_values[optr]==MixNodeConstants.MIX_POWER:
			t=pow(abs(a_in),b_in)*sign(a_in)
		elif op_values[optr]==MixNodeConstants.MIX_MAX:
			t=max(a_in,b_in)
		elif op_values[optr]==MixNodeConstants.MIX_MIN:
			t=min(a_in,b_in)
		elif op_values[optr]==MixNodeConstants.MIX_GT:
			t=float(b_in>a_in)
		elif op_values[optr]==MixNodeConstants.MIX_GE:
			t=float(b_in>=a_in)
		elif op_values[optr]==MixNodeConstants.MIX_LT:
			t=float(b_in<a_in)
		elif op_values[optr]==MixNodeConstants.MIX_LE:
			t=float(b_in<=a_in)
		elif op_values[optr]==MixNodeConstants.MIX_CMP:
			t=sign(b_in-a_in)
		elif op_values[optr]==MixNodeConstants.MIX_SIGN_CP:
			t=abs(a_in) if b_in>0.0 else -abs(a_in) if b_in<0.0 else 0.0
		elif op_values[optr]==MixNodeConstants.MIX_OVER:
			t=a_in if is_nan(a_in) else b_in
		elif op_values[optr]==MixNodeConstants.MIX_UNDER:
			t=b_in if is_nan(a_in) else a_in
		if bidi_lerp:
			t=lerp(t,b_in,mix) if mix>0.0 else lerp(t,a_in,-mix)
		t=calculate_decay(pow(abs(t),power_values[optr])*sign(t),decay_values[optr],sz)+dc_values[optr]
		if i<sz and isolate_values[optr]<0.5:
			output[optr]=t
		optr=(optr+1)&size_mask
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as MixNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"a_value","b_value","mix_value","clamp_mix_value","op_value","isolate","power","decay","dc"
	])
