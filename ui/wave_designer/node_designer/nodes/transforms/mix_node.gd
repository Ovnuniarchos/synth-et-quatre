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
	$A.set_value(node.a_value)
	$B.set_value(node.b_value)
	$Mix.set_value(node.mix_value)
	$ClampMix.set_value(node.clamp_mix_value)
	$Op.select(node.op_value)
	$Power.set_value(node.power)
	$Decay.set_value(node.decay)
	$DCOffset.set_value(node.dc)
	$RangeFrom.set_value(node.range_from)
	$RangeLength.set_value(node.range_length)


func _on_A_value_changed(value:float)->void:
	node.a_value=value
	emit_signal("params_changed",self)


func _on_B_value_changed(value:float)->void:
	node.b_value=value
	emit_signal("params_changed",self)


func _on_Mix_value_changed(value:float)->void:
	node.mix_value=value
	emit_signal("params_changed",self)


func _on_ClampMix_value_changed(value:float)->void:
	node.clamp_mix_value=value
	emit_signal("params_changed",self)


func _on_Op_item_selected(index:int)->void:
	node.op_value=index
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


