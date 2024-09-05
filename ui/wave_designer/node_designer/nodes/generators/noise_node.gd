extends NodeController


func _init()->void:
	node=NoiseNodeComponent.new()


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$Seed/SpinBar.set_value_no_signal(node.noise_seed)
	$Amplitude/SpinBar.set_value_no_signal(node.amplitude)
	$DCOffset/SpinBar.set_value_no_signal(node.dc)
	$Octaves/SpinBar.set_value_no_signal(node.octaves)
	$Frequency/SpinBar.set_value_no_signal(node.frequency)
	$Persistence/SpinBar.set_value_no_signal(node.persistence)
	$Lacunarity/SpinBar.set_value_no_signal(node.lacunarity)
	$Randomness/SpinBar.set_value_no_signal(node.randomness)
	$RangeFrom/SpinBar.set_value_no_signal(node.range_from)
	$RangeLength/SpinBar.set_value_no_signal(node.range_length)


func _on_Amplitude_value_changed(value:float)->void:
	node.amplitude=value
	emit_signal("params_changed",self)


func _on_Seed_value_changed(value:float)->void:
	node.noise_seed=value
	emit_signal("params_changed",self)


func _on_Decay_value_changed(value: float) -> void:
	node.decay=value
	emit_signal("params_changed",self)


func _on_DCOffset_value_changed(value: float) -> void:
	node.dc=value
	emit_signal("params_changed",self)


func _on_Octaves_value_changed(value:float)->void:
	node.octaves=value
	emit_signal("params_changed",self)


func _on_Frequency_value_changed(value:float)->void:
	node.frequency=value
	emit_signal("params_changed",self)


func _on_Persistence_value_changed(value:float)->void:
	node.persistence=value
	emit_signal("params_changed",self)


func _on_Lacunarity_value_changed(value:float)->void:
	node.lacunarity=value
	emit_signal("params_changed",self)


func _on_Randomness_value_changed(value: float) -> void:
	node.randomness=value
	emit_signal("params_changed",self)


func _on_RangeFrom_value_changed(value:float)->void:
	node.range_from=value
	emit_signal("params_changed",self)


func _on_RangeLength_value_changed(value:float)->void:
	node.range_length=value
	emit_signal("params_changed",self)
