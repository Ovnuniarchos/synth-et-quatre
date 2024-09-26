extends NodeController


func _init()->void:
	node=ClampNodeComponent.new()


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$LevelHi.set_value(node.level_hi_value)
	$ClampHi.set_value(node.clamp_hi_value)
	$LevelLo.set_value(node.level_lo_value)
	$ClampLo.set_value(node.clamp_lo_value)
	$Amplitude.set_value(node.amplitude)
	$Power.set_value(node.power)
	$Decay.set_value(node.decay)
	$DCOffset.set_value(node.dc)
	$RangeFrom.set_value(node.range_from)
	$RangeLength.set_value(node.range_length)


func _on_LevelHi_value_changed(value:float)->void:
	node.level_hi_value=value
	emit_signal("params_changed",self)


func _on_ClampHi_value_changed(value:float)->void:
	node.clamp_hi_value=value
	emit_signal("params_changed",self)


func _on_LevelLo_value_changed(value:float)->void:
	node.level_lo_value=value
	emit_signal("params_changed",self)


func _on_ClampLo_value_changed(value:float)->void:
	node.clamp_lo_value=value
	emit_signal("params_changed",self)


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
