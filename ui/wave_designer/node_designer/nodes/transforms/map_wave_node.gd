tool extends NodeController


func _ready()->void:
	var ops:Array=[]
	for i in MapWaveNodeConstants.LERP_END:
		ops.append({"label":MapWaveNodeConstants.LERP_STRINGS[i],"id":i})
	$Lerp.set_options(ops)
	ops.clear()
	for i in MapWaveNodeConstants.XERP_END:
		ops.append({"label":MapWaveNodeConstants.XERP_STRINGS[i],"id":i})
	$Extrapolation.set_options(ops)


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$Lerp.select(node.lerp_value)
	$Extrapolation.select(node.extrapolate)
	$Mix.set_value(node.mix_value)
	$ClampMix.set_value(node.clamp_mix_value)
	$Isolate.set_pressed_no_signal(node.isolate>=0.5)
	$MapToEmpty.set_pressed_no_signal(node.map_empty>=0.5)
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


func _on_Lerp_item_selected(index:int)->void:
	node.lerp_value=index
	emit_signal("params_changed",self)


func _on_Isolate_toggled(pressed:bool)->void:
	node.isolate=float(pressed)
	emit_signal("params_changed",self)


func _on_Extrapolation_item_selected(index:int)->void:
	node.extrapolate=index
	emit_signal("params_changed",self)


func _on_MapToEmpty_toggled(pressed:bool)->void:
	node.map_empty=float(pressed)
	emit_signal("params_changed",self)