tool extends NodeController


var input_ports:Array=[]
var _input_slot:PackedScene=preload("res://ui/widgets/slider_slot.tscn")


func _ready()->void:
	var ops:Array=[]
	for i in MuxNodeConstants.MUX_END:
		ops.append({"label":MuxNodeConstants.MUX_STRINGS[i],"id":i})
	$Clip.set_options(ops)


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$InputCount.set_value(node.get_inputs_size())
	for i in node.input.size():
		input_ports[i].set_value(node.input[i])
	$Selector.set_value(node.selector)
	$Clip.select(node.clip)
	$RangeFrom.set_value(node.range_from)
	$RangeLength.set_value(node.range_length)


func _on_RangeFrom_value_changed(value:float)->void:
	node.range_from=value
	emit_signal("params_changed",self)


func _on_RangeLength_value_changed(value:float)->void:
	node.range_length=value
	emit_signal("params_changed",self)


func _on_Selector_value_changed(value:float)->void:
	node.selector=value
	emit_signal("params_changed",self)


func _on_Clip_item_selected(index:int)->void:
	node.clip=index
	emit_signal("params_changed",self)


func _on_InputCount_value_changed(value:int)->void:
	update_input_slots(value)
	if node!=null:
		node.resize_inputs(value)
	emit_signal("slots_changed")


func set_node(n:WaveNodeComponent)->void:
	.set_node(n)
	if n!=null:
		update_input_slots(n.get_inputs_size())


func update_input_slots(value:int)->void:
	if Engine.editor_hint:
		return
	var count:int=input_ports.size()
	var label:Node
	if value>count:
		for i in value-count:
			label=_input_slot.instance(PackedScene.GEN_EDIT_STATE_INSTANCE)
			label.label="NODE_MULTIINPUT_PORT"
			label.tooltip="NODE_MULTIINPUT_PORT_TTIP"
			label.clamp_lo=false
			label.clamp_hi=false
			label.nullable=true
			label.connect("value_changed",self,"_on_Input_value_changed",[input_ports.size()])
			var last:Node=$Clip if input_ports.empty() else input_ports[-1]
			add_child_below_node(last,label)
			set_slot(last.get_index()+1,true,SLOT_VALUE,SLOT_COLORS[0],false,0,Color.white)
			input_ports.append(label)
	elif value<count:
		for i in count-value:
			label=input_ports[-1]
			set_slot_enabled_left(label.get_index(),false)
			remove_child(label)
			label.queue_free()
			input_ports.resize(input_ports.size()-1)


func _on_Input_value_changed(value:float,input_ix:int)->void:
	node.set_input(value,input_ix)
	emit_signal("params_changed",self)
