extends NodeController


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$Clip/SpinBar.set_value_no_signal(node.clip)


func _on_Clip_value_changed(value:float)->void:
	node.clip=value
	emit_signal("params_changed",self)
