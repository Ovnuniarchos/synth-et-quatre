extends NodeController


func _init()->void:
	node=PulseNodeComponent.new()


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$Freq/SpinBar.set_value_no_signal(node.frequency)
	$Amplitude/SpinBar.set_value_no_signal(node.amplitude)
	$Phi0/SpinBar.set_value_no_signal(node.phi0)
	$Decay/SpinBar.set_value_no_signal(node.decay)
	$DCOffset/SpinBar.set_value_no_signal(node.dc)
	$PositiveStart/SpinBar.set_value_no_signal(node.ppulse_start)
	$PositiveLength/SpinBar.set_value_no_signal(node.ppulse_length)
	$PositiveAmplitude/SpinBar.set_value_no_signal(node.ppulse_amplitude)
	$NegativeStart/SpinBar.set_value_no_signal(node.npulse_start)
	$NegativeLength/SpinBar.set_value_no_signal(node.npulse_length)
	$NegativeAmplitude/SpinBar.set_value_no_signal(node.npulse_amplitude)


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


func _on_RangeFrom_value_changed(value:float)->void:
	node.range_from=value
	emit_signal("params_changed",self)


func _on_RangeLength_value_changed(value:float)->void:
	node.range_length=value
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

