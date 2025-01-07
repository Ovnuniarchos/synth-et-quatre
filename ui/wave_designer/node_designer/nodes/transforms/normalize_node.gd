tool extends NodeController


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$KeepZero.set_value(node.keep_0)
	$UseFull.set_value(node.use_full)
	$Mix.set_value(node.mix)
	$ClampMix.set_value(node.clamp_mix)
	$Amplitude.set_value(node.amplitude)
	$Power.set_value(node.power)
	$Decay.set_value(node.decay)
	$Isolate.set_pressed_no_signal(node.isolate)
	$RangeFrom.set_value(node.range_from)
	$RangeLength.set_value(node.range_length)


func _on_RangeFrom_value_changed(value:float)->void:
	node.range_from=value
	emit_signal("params_changed",self)


func _on_RangeLength_value_changed(value:float)->void:
	node.range_length=value
	emit_signal("params_changed",self)


func _on_KeepZero_value_changed(value:float)->void:
	node.keep_0=value
	emit_signal("params_changed",self)


func _on_Mix_value_changed(value:float)->void:
	node.mix=value
	emit_signal("params_changed",self)


func _on_ClampMix_value_changed(value:float)->void:
	node.clamp_mix=value
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


func _on_Isolate_toggled(pressed:bool)->void:
	node.decay=float(pressed)
	emit_signal("params_changed",self)


func _on_UseFull_value_changed(value:float)->void:
	node.use_full=value
	emit_signal("params_changed",self)
