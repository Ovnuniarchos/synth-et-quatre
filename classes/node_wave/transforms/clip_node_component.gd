extends WaveNodeComponent
class_name ClipNodeComponent

const NODE_TYPE:String="Clip"


var input_slot:Array=[]
var input_values:Array=[]


func _init()->void:
	inputs=[
		{SLOT_ID:SlotIds.SLOT_INPUT,SLOT_IN:input_slot}
	]


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	calculate_slot(input_values,input_slot,NAN)
	NODES.clip(output,max(1.0,size*range_length),fposmod(range_from*size,size),input_values)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as ClipNodeComponent)==null:
		return false
	return .equals(other)


# Uses parent duplicate()
