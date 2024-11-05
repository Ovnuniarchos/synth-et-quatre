extends WaveNodeComponent
class_name OutputNodeComponent


const NODE_TYPE:String="Output"


var input_slot:Array=[]
var clip:float=1.0


func _init()->void:
	._init()
	inputs=[input_slot]


func calculate()->Array:
	if output_valid:
		return output
	calculate_slot(output,input_slot,0.0)
	for i in size:
		output[i]=clamp(output[i],-clip,clip)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as OutputNodeComponent)==null:
		return false
	return .equals(other) and is_equal_approx(clip,other.clip)
