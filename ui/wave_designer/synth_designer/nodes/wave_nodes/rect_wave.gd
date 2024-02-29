extends WaveController

func _ready()->void:
	from_node=$VBC/Params/From
	title_node=$VBC/Title
	setup()

func setup()->void:
	.setup()
	set_block_signals(true)
	$VBC/Params/Mul.value=component.freq_mult
	$VBC/Params/Ofs.value=component.phi0*100.0
	$VBC/Params/Vol.value=component.vol*100.0
	$VBC/Params/ZStart.value=component.z_start*100.0
	$VBC/Params/NStart.value=component.n_start*100.0
	$VBC/Params/Decay.value=component.decay
	$VBC/Params/Cycles.value=component.cycles
	$VBC/Params/Position.value=component.pos0*100.0
	$VBC/Params/Output.selected=component.output_mode
	from_node.value=get_component_index(component.input_comp)
	from_node.max_value=wave.components.size()-1
	$VBC/Params/PM.value=component.pm*100.0
	$VBC/Params/AM.value=component.am*100.0
	$VBC/Params/XM.value=component.xm*100.0
	set_block_signals(false)

#

func _on_Mul_value_changed(value:float)->void:
	component.freq_mult=clamp(value,0.0,32.0)
	emit_signal("params_changed")

func _on_Ofs_value_changed(value:float)->void:
	component.phi0=clamp(value/100.0,-1.0,1.0)
	emit_signal("params_changed")

func _on_Vol_value_changed(value:float)->void:
	component.vol=clamp(value/100.0,-100.0,100.0)
	emit_signal("params_changed")

func _on_PM_value_changed(value:float)->void:
	component.pm=clamp(value/100.0,-1.0,1.0)
	emit_signal("params_changed")

func _on_AM_value_changed(value:float)->void:
	component.am=clamp(value/100.0,-1.0,1.0)
	emit_signal("params_changed")

func _on_XM_value_changed(value:float)->void:
	component.xm=clamp(value/100.0,-1.0,1.0)
	emit_signal("params_changed")

func _on_From_value_changed(from:int)->void:
	component.input_comp=wave.get_component(from)
	emit_signal("params_changed")

func _on_Output_item_selected(id:int)->void:
	component.output_mode=id
	emit_signal("params_changed")

func _on_Cycles_value_changed(value:float)->void:
	component.cycles=value
	emit_signal("params_changed")

func _on_Position_value_changed(value:float)->void:
	component.pos0=value/100.0
	emit_signal("params_changed")

func _on_ZStart_value_changed(value:float)->void:
	component.z_start=value/100.0
	emit_signal("params_changed")

func _on_NStart_value_changed(value:float)->void:
	component.n_start=value/100.0
	emit_signal("params_changed")


func _on_Decay_value_changed(value:float)->void:
	component.decay=value
	emit_signal("params_changed")
