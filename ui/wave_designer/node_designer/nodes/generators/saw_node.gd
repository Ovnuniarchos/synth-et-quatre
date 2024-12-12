tool extends NodeController


func _init()->void:
	node=SawNodeComponent.new()


func _ready()->void:
	var ops:Array=[]
	for i in SawNodeConstants.SWQ_MAX:
		ops.append({"label":SawNodeConstants.STRINGS[i],"id":i})
	$Quarter0.set_options(ops)
	$Quarter1.set_options(ops)
	$Quarter2.set_options(ops)
	$Quarter3.set_options(ops)


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")
	$Freq.set_value(node.frequency)
	$Amplitude.set_value(node.amplitude)
	$Phi0.set_value(node.phi0)
	$Power.set_value(node.power)
	$Decay.set_value(node.decay)
	$DCOffset.set_value(node.dc)
	$Quarter0.select(node.quarters[0])
	$Quarter1.select(node.quarters[1])
	$Quarter2.select(node.quarters[2])
	$Quarter3.select(node.quarters[3])
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
	node.set_quarter(quarter,index)
	emit_signal("params_changed",self)


func _on_RangeFrom_value_changed(value:float)->void:
	node.range_from=value
	emit_signal("params_changed",self)


func _on_RangeLength_value_changed(value:float)->void:
	node.range_length=value
	emit_signal("params_changed",self)
