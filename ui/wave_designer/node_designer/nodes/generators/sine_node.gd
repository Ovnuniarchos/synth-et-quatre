extends NodeController


func _init()->void:
	node=SineNodeComponent.new()


func set_parameters()->void:
	$Freq/SpinBar.set_value_no_signal(node.frequency)
	$Amplitude/SpinBar.set_value_no_signal(node.amplitude)
	$Phi0/SpinBar.set_value_no_signal(node.phi0)
	$Power/SpinBar.set_value_no_signal(node.power)
	$Decay/SpinBar.set_value_no_signal(node.decay)
	$DCOffset/SpinBar.set_value_no_signal(node.dc)


func _on_Freq_value_changed(value:float)->void:
	node.frequency=value
	emit_signal("params_changed",self)


func _on_Amplitude_value_changed(value:float)->void:
	node.amplitude=value
	emit_signal("params_changed",self)


func _on_Phi0_value_changed(value:float)->void:
	node.phi0=value
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
