extends WaveNodeComponent
class_name MixNodeComponent

const NODE_TYPE:String="Mix"


var a_slot:Array=[]
var a_values:Array=[]
var a_value:float=0.0 setget set_a_value
var b_slot:Array=[]
var b_values:Array=[]
var b_value:float=0.0 setget set_b_value
var mix_slot:Array=[]
var mix_values:Array=[]
var mix_value:float=0.0 setget set_mix_value
var clamp_mix_slot:Array=[]
var clamp_mix_values:Array=[]
var clamp_mix_value:float=0.0 setget set_clamp_mix_value
var op_slot:Array=[]
var op_values:Array=[]
var op_value:int=MixNodeConstants.MIX_MIX setget set_op_value
var isolate_slot:Array=[]
var isolate_values:Array=[]
var isolate:float=0.0 setget set_isolate
var power_slot:Array=[]
var power_values:Array=[]
var power:float=1.0 setget set_power
var decay_slot:Array=[]
var decay_values:Array=[]
var decay:float=0.0 setget set_decay
var dc_slot:Array=[]
var dc_values:Array=[]
var dc:float=0.0 setget set_dc


func _init()->void:
	inputs=[
		{SLOT_ID:SlotIds.SLOT_IN_A,SLOT_IN:a_slot},
		{SLOT_ID:SlotIds.SLOT_IN_B,SLOT_IN:b_slot},
		{SLOT_ID:SlotIds.SLOT_MIX,SLOT_IN:mix_slot},
		{SLOT_ID:SlotIds.SLOT_CLAMP_MIX,SLOT_IN:clamp_mix_slot},
		{SLOT_ID:SlotIds.SLOT_OP,SLOT_IN:op_slot},
		{SLOT_ID:SlotIds.SLOT_POWER,SLOT_IN:power_slot},
		{SLOT_ID:SlotIds.SLOT_DECAY,SLOT_IN:decay_slot},
		{SLOT_ID:SlotIds.SLOT_DC,SLOT_IN:dc_slot},
		{SLOT_ID:SlotIds.SLOT_ISOLATE,SLOT_IN:isolate_slot}
	]


func set_a_value(value:float)->void:
	a_value=value
	a_values.resize(0)


func set_b_value(value:float)->void:
	b_value=value
	b_values.resize(0)


func set_mix_value(value:float)->void:
	mix_value=value
	mix_values.resize(0)


func set_clamp_mix_value(value:float)->void:
	clamp_mix_value=value
	clamp_mix_values.resize(0)


func set_op_value(value:int)->void:
	op_value=value
	op_values.resize(0)


func set_isolate(value:float)->void:
	isolate=value
	isolate_values.resize(0)


func set_power(value:float)->void:
	power=value
	power_values.resize(0)


func set_decay(value:float)->void:
	decay=value
	decay_values.resize(0)


func set_dc(value:float)->void:
	dc=value
	dc_values.resize(0)


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
	reset_decay(sz)
	for i in sz:
		mix=lerp(mix_values[optr],clamp(mix_values[optr],-1.0,1.0),clamp_mix_values[optr])
		a_in=b_values[optr] if is_nan(a_values[optr]) else a_values[optr]
		b_in=a_values[optr] if is_nan(b_values[optr]) else b_values[optr]
		if op_values[optr]==MixNodeConstants.MIX_MIX:
			t=(a_in+b_in)*0.5
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
		t=lerp(t,b_in,mix) if mix>0.0 else lerp(t,a_in,-mix)
		output[optr]=calculate_decay(pow(abs(t),power_values[optr])*sign(t),decay_values[optr])+dc_values[optr]
		optr=(optr+1)&size_mask
	fill_out_of_region(sz,optr,a_values,isolate_values)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as MixNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"a_value","b_value","mix_value","clamp_mix_value","op_value","isolate","power","decay","dc"
	])


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:MixNodeComponent=.duplicate(container) as MixNodeComponent
	nc.a_value=a_value
	nc.b_value=b_value
	nc.mix_value=mix_value
	nc.clamp_mix_value=clamp_mix_value
	nc.op_value=op_value
	nc.isolate=isolate
	nc.power=power
	nc.decay=decay
	nc.dc=dc
	return nc
