tool extends NodeController


func _init()->void:
	node=RampNodeComponent.new()


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$From.set_value(node.ramp_from)
	$To.set_value(node.ramp_to)
	$Curve.set_value(node.curve)
	$RangeFrom.set_value(node.range_from)
	$RangeLength.set_value(node.range_length)


func _on_RangeFrom_value_changed(value:float)->void:
	node.range_from=value
	emit_signal("params_changed",self)


func _on_RangeLength_value_changed(value:float)->void:
	node.range_length=value
	emit_signal("params_changed",self)


func _on_From_value_changed(value:float)->void:
	node.ramp_from=value
	emit_signal("params_changed",self)


func _on_To_value_changed(value:float)->void:
	node.ramp_to=value
	emit_signal("params_changed",self)


func _on_Curve_value_changed(value:float)->void:
	node.curve=value
	emit_signal("params_changed",self)
