extends WaveNodeComponent
class_name OutputNodeComponent


const NODE_TYPE:String="Output"


var input_slot:Array=[]
var input_values:Array=[]
var clip:float=1.0


func _init()->void:
	inputs=[
		{SLOT_ID:SlotIds.SLOT_INPUT,SLOT_IN:input_slot}
	]


func calculate()->Array:
	if output_valid:
		return output
	var ti:int=OS.get_ticks_msec()
	calculate_slot(input_values,input_slot,0.0)
	for i in size:
		output[i]=clamp(input_values[i],-clip,clip)
	print(OS.get_ticks_msec()-ti)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as OutputNodeComponent)==null:
		return false
	return .equals(other) and is_equal_approx(clip,other.clip)


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:OutputNodeComponent=.duplicate(container) as OutputNodeComponent
	nc.clip=clip
	return nc
