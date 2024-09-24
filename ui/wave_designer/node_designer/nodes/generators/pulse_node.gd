extends NodeController


func _init()->void:
	node=PulseNodeComponent.new()


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$Freq.set_value(node.frequency)
	$Amplitude.set_value(node.amplitude)
	$Phi0.set_value(node.phi0)
	$Decay.set_value(node.decay)
	$DCOffset.set_value(node.dc)
	$PositiveStart.set_value(node.ppulse_start)
	$PositiveLength.set_value(node.ppulse_length)
	$PositiveAmplitude.set_value(node.ppulse_amplitude)
	$NegativeStart.set_value(node.npulse_start)
	$NegativeLength.set_value(node.npulse_length)
	$NegativeAmplitude.set_value(node.npulse_amplitude)
	$RangeFrom.set_value(node.range_from)
	$RangeLength.set_value(node.range_length)


func _on_Freq_value_changed(value:float)->void:
	node.frequency=value
	emit_signal("params_changed",self)


func _on_Amplitude_value_changed(value:float)->void:
	node.amplitude=value
	emit_signal("params_changed",self)


func _on_Phi0_value_changed(value:float)->void:
	node.phi0=value
	emit_signal("params_changed",self)


func _on_Decay_value_changed(value:float)->void:
	node.decay=value
	emit_signal("params_changed",self)


func _on_DCOffset_value_changed(value:float)->void:
	node.dc=value
	emit_signal("params_changed",self)


func _on_PositiveStart_value_changed(value:float)->void:
	node.ppulse_start=value
	emit_signal("params_changed",self)


func _on_PositiveLength_value_changed(value:float)->void:
	node.ppulse_length=value
	emit_signal("params_changed",self)


func _on_PositiveAmplitude_value_changed(value:float)->void:
	node.ppulse_amplitude=value
	emit_signal("params_changed",self)


func _on_NegativeStart_value_changed(value:float)->void:
	node.npulse_start=value
	emit_signal("params_changed",self)


func _on_NegativeLength_value_changed(value:float)->void:
	node.npulse_length=value
	emit_signal("params_changed",self)


func _on_NegativeAmplitude_value_changed(value:float)->void:
	node.npulse_amplitude=value
	emit_signal("params_changed",self)


func _on_RangeFrom_value_changed(value:float)->void:
	node.range_from=value
	emit_signal("params_changed",self)


func _on_RangeLength_value_changed(value:float)->void:
	node.range_length=value
	emit_signal("params_changed",self)
