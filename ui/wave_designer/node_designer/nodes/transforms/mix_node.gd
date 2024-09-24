extends NodeController


func _init()->void:
	node=MixNodeComponent.new()


func _ready()->void:
	var ops:Array=[]
	for i in MixNodeConstants.MIX_END:
		ops.append({"label":MixNodeConstants.STRINGS[i],"id":i})
	$Op.set_options(ops)


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$Clamp.set_pressed_no_signal(abs(node.clamp_in_value)<0.5)
	$Op.select(node.op_value)
	$Mix.set_value(node.mix_value)
	$Power.set_value(node.power)
	$Decay.set_value(node.decay)
	$DCOffset.set_value(node.dc)
	$RangeFrom.set_value(node.range_from)
	$RangeLength.set_value(node.range_length)


func _on_ClampIn_toggled(button_pressed:bool)->void:
	node.clamp_in_value=float(button_pressed)
	emit_signal("params_changed",self)


func _on_Op_item_selected(index:int)->void:
	node.op_value=index
	emit_signal("params_changed",self)


func _on_Mix_value_changed(value:float)->void:
	node.mix_value=value
	emit_signal("params_changed",self)


func _on_Power_value_changed(value:float)->void:
	node.power=value
	emit_signal("params_changed",self)


func _on_Decay_value_changed(value:float)->void:
	node.decay=value
	emit_signal("params_changed",self)


func _on_DCOffset_value_changed(value:float)->void:
	node.dc=value
	emit_signal("params_changed",self)


func _on_RangeFrom_value_changed(value:float)->void:
	node.range_from=value
	emit_signal("params_changed",self)


func _on_RangeLength_value_changed(value:float)->void:
	node.range_length=value
	emit_signal("params_changed",self)
