extends WaveNodeComponent
class_name MuxNodeComponent

const NODE_TYPE:String="Mux"


var input_slots:Array=[[],[]]
var input_values:Array=[[],[]]
var input:Array=[NAN,NAN]
var selector_slot:Array=[]
var selector_values:Array=[]
var selector:float=0.0 setget set_selector
var clip_values:Array=[]
var clip_slot:Array=[]
var clip:int=0 setget set_clip


func _init()->void:
	inputs=[
		{SLOT_ID:SlotIds.SLOT_SELECTOR,SLOT_IN:selector_slot},
		{SLOT_ID:SlotIds.SLOT_CLIP,SLOT_IN:clip_slot},
		# Dynamic
		{SLOT_ID:SlotIds.SLOT_MULTIINPUT%[0],SLOT_IN:input_slots[0]},
		{SLOT_ID:SlotIds.SLOT_MULTIINPUT%[1],SLOT_IN:input_slots[1]}
	]


func set_selector(value:float)->void:
	selector=value
	selector_values.resize(0)


func set_clip(value:int)->void:
	clip=value
	clip_values.resize(0)


func set_input(value:float,index:int)->void:
	input[index]=value
	input_values[index].resize(0)


func resize_inputs(new_size:int)->void:
	var input_count:int=get_inputs_size()
	if input_count<new_size:
		for _i in new_size-input_count:
			input_values.append([])
			input_slots.append([])
			input.append(NAN)
			inputs.append({SLOT_ID:SlotIds.SLOT_MULTIINPUT%[get_inputs_size()],SLOT_IN:input_slots[-1]})
	elif input_count>new_size:
		inputs.resize(new_size+2)
		input_values.resize(new_size)
		input_slots.resize(new_size)
		input.resize(new_size)


func get_inputs_size()->int:
	return inputs.size()-2


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	if input_slots.empty():
		output_valid=true
		return output
	calculate_slot(selector_values,selector_slot,selector)
	calculate_option_slot(clip_values,clip_slot,MuxNodeConstants.MUX_END,clip)
	for i in input_slots.size():
		calculate_slot(input_values[i],input_slots[i],input[i])
	NODES.mux(output,max(1.0,size*range_length),fposmod(range_from*size,size),
		input_values,selector_values,clip_values
	)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as ClipNodeComponent)==null:
		return false
	if not (.equals(other) and are_equal_approx(other,[
		"selector","clip","input_values"
	])):
		return false
	# TODO Check input ports
	return true


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:MuxNodeComponent=.duplicate(container) as MuxNodeComponent
	nc.selector=selector
	nc.clip=clip
	nc.input_values=input_values.duplicate()
	return nc

