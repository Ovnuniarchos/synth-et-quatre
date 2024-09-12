extends WaveNodeComponent
class_name MixNodeComponent

const NODE_TYPE:String="Mix"


var a_slot:Array=[]
var a_values:Array=[]
var b_slot:Array=[]
var b_values:Array=[]
var clamp_slot:Array=[]
var clamp_values:Array=[]
var clamp_value:float=0.0
var op_slot:Array=[]
var op_values:Array=[]
var op_value:float=0.0
var mix_slot:Array=[]
var mix_values:Array=[]
var mix_value:float=0.0


func _init()->void:
	._init()
	inputs=[
		a_slot,b_slot,clamp_slot,op_slot,mix_slot
	]


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size)
	calculate_slot(a_values,a_slot,0.0)
	calculate_slot(b_values,b_slot,0.0)
	calculate_slot(clamp_values,clamp_slot,clamp_value)
	calculate_option_slot(op_values,op_slot,range(12),0.0)
	calculate_slot(mix_values,mix_slot,0.0)
	return output
