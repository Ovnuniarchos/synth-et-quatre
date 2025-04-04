tool extends NodeController


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$Levels.set_value(node.levels_value)
	$Dither.set_value(node.dither_value)
	$UseFull.set_value(node.use_full_value)
	$FullAmp.set_value(node.full_amplitude_value)
	$Mix.set_value(node.mix_value)
	$ClampMix.set_value(node.clamp_mix_value)
	$Isolate.set_pressed_no_signal(node.isolate>=0.5)
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


func _on_Mix_value_changed(value:float)->void:
	node.mix_value=value
	emit_signal("params_changed",self)


func _on_ClampMix_value_changed(value:float)->void:
	node.clamp_mix_value=value
	emit_signal("params_changed",self)


func _on_Isolate_toggled(pressed:bool)->void:
	node.isolate=float(pressed)
	emit_signal("params_changed",self)


func _on_Levels_value_changed(value:float)->void:
	node.levels_value=value
	emit_signal("params_changed",self)


func _on_UseFull_value_changed(value:float)->void:
	node.use_full_value=value
	emit_signal("params_changed",self)


func _on_FullAmp_value_changed(value:float)->void:
	node.full_amplitude_value=value
	emit_signal("params_changed",self)


func _on_Dither_value_changed(value:float)->void:
	node.dither_value=value
	emit_signal("params_changed",self)
