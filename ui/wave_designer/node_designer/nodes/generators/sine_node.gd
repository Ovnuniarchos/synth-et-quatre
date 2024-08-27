extends NodeController


func _init()->void:
	node=SineNodeComponent.new()


func _ready()->void:
	for i in 7:
		$Quarter0/OptionButton.add_item("NODE_SINE_Q%d"%[i],i)
		$Quarter1/OptionButton.add_item("NODE_SINE_Q%d"%[i],i)
		$Quarter2/OptionButton.add_item("NODE_SINE_Q%d"%[i],i)
		$Quarter3/OptionButton.add_item("NODE_SINE_Q%d"%[i],i)


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$Freq/SpinBar.set_value_no_signal(node.frequency)
	$Amplitude/SpinBar.set_value_no_signal(node.amplitude)
	$Phi0/SpinBar.set_value_no_signal(node.phi0)
	$Power/SpinBar.set_value_no_signal(node.power)
	$Decay/SpinBar.set_value_no_signal(node.decay)
	$DCOffset/SpinBar.set_value_no_signal(node.dc)
	for i in 4:
		get_node("Quarter%d/OptionButton"%[i]).select(node.quarters[i])


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


func _on_Quarter_item_selected(index:int,quarter:int)->void:
	node.quarters[quarter]=index
	emit_signal("params_changed",self)


func _on_RangeFrom_value_changed(value:float)->void:
	node.range_from=value
	emit_signal("params_changed",self)


func _on_RangeLength_value_changed(value:float)->void:
	node.range_length=value
	emit_signal("params_changed",self)
