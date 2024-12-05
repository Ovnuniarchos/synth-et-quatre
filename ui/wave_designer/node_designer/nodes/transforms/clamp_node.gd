tool extends NodeController

# TODO: LABELS LABELS LABELS
func _init()->void:
	node=ClampNodeComponent.new()


func _ready()->void:
	var ops:Array=[]
	for i in ClampNodeConstants.CLAMP_END:
		ops.append({"label":ClampNodeConstants.STRINGS[i],"id":i})
	$ModeHi.set_options(ops)
	$ModeLo.set_options(ops)


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$LevelHi.set_value(node.level_hi_value)
	$ClampHi.set_value(node.clamp_hi_value)
	$ModeHi.select(node.mode_hi)
	$LevelLo.set_value(node.level_lo_value)
	$ClampLo.set_value(node.clamp_lo_value)
	$ModeLo.select(node.mode_lo)
	$Mix.set_value(node.mix_value)
	$ClampMix.set_value(node.clamp_mix_value)
	$Isolate.set_pressed_no_signal(node.isolate>=0.5)
	$Amplitude.set_value(node.amplitude)
	$Power.set_value(node.power)
	$Decay.set_value(node.decay)
	$DCOffset.set_value(node.dc)
	$RangeFrom.set_value(node.range_from)
	$RangeLength.set_value(node.range_length)


func _on_LevelHi_value_changed(value:float)->void:
	node.level_hi_value=value
	emit_signal("params_changed",self)


func _on_ClampHi_value_changed(value:float)->void:
	node.clamp_hi_value=value
	emit_signal("params_changed",self)


func _on_LevelLo_value_changed(value:float)->void:
	node.level_lo_value=value
	emit_signal("params_changed",self)


func _on_ClampLo_value_changed(value:float)->void:
	node.clamp_lo_value=value
	emit_signal("params_changed",self)


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
	node.clamp_mix=value
	emit_signal("params_changed",self)


func _on_Isolate_toggled(pressed:bool)->void:
	node.isolate=float(pressed)
	emit_signal("params_changed",self)


func _on_ModeHi_item_selected(index:int)->void:
	node.mode_hi=index
	emit_signal("params_changed",self)


func _on_ModeLo_item_selected(index:int)->void:
	node.mode_lo=index
	emit_signal("params_changed",self)
