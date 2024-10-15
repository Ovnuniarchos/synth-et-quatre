extends NodeController


func _init()->void:
	node=MapRangeNodeComponent.new()


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$MinIn.set_value(node.min_in_value)
	$MaxIn.set_value(node.max_in_value)
	$MinOut.set_value(node.min_out_value)
	$MaxOut.set_value(node.max_out_value)
	$Mix.set_value(node.mix_value)
	$ClampMix.set_value(node.clamp_mix_value)
	$Amplitude.set_value(node.amplitude)
	$Power.set_value(node.power)
	$Decay.set_value(node.decay)
	$DCOffset.set_value(node.dc)
	$RangeFrom.set_value(node.range_from)
	$RangeLength.set_value(node.range_length)


func _on_Amplitude_value_changed(value:float)->void:
	node.amplitude=value
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


func _on_MinIn_value_changed(value:float)->void:
	node.min_in_value=value
	emit_signal("params_changed",self)


func _on_MaxIn_value_changed(value:float)->void:
	node.max_in_value=value
	emit_signal("params_changed",self)


func _on_MinOut_value_changed(value:float)->void:
	node.min_out_value=value
	emit_signal("params_changed",self)


func _on_MaxOut_value_changed(value:float)->void:
	node.max_out_value=value
	emit_signal("params_changed",self)


func _on_Mix_value_changed(value:float)->void:
	node.mix_value=value
	emit_signal("params_changed",self)


func _on_ClampMix_value_changed(value:float)->void:
	node.clamp_mix_value=value
	emit_signal("params_changed",self)
