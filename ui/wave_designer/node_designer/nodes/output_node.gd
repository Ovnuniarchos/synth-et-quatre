extends NodeController


func _init()->void:
	node=OutputNodeComponent.new()


func set_parameters()->void:
	$Clip/SpinBar.set_value_no_signal(node.clip)


func _on_Clip_value_changed(value:float)->void:
	node.clip=value
	emit_signal("params_changed",self)
