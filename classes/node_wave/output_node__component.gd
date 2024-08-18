extends WaveNodeComponent
class_name OutputNodeComponent


const NODE_TYPE:String="Output"


var input_slot:Array=[]


func _init()->void:
	._init()
	inputs=[input_slot]


func calculate()->Array:
	if output_valid:
		return output
	calculate_slot(output,input_slot)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as OutputNodeComponent)==null:
		return false
	if not .equals(other):
		return false
	return true
