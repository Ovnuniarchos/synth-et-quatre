extends WaveNodeComponent
class_name ClipNodeComponent

const NODE_TYPE:String="Clip"


var input_slot:Array=[]
var input_values:Array=[]


func _init()->void:
	._init()
	inputs=[
		{SLOT_ID:SlotIds.SLOT_INPUT,SLOT_IN:input_slot}
	]


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	calculate_slot(input_values,input_slot,NAN)
	var sz:int=max(1.0,size*range_length)
	var optr:int=fposmod(range_from*size,size)
	var t:float
	var mix:float
	for i in sz:
		output[optr]=input_values[optr]
		optr=(optr+1)&size_mask
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as ClampNodeComponent)==null:
		return false
	return .equals(other)
