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
	$VBC/Params/Power.value=component.power
	$VBC/Params/Decay.value=component.decay
	$VBC/Params/Quad1.selected=component.quarters[0]
	$VBC/Params/Quad2.selected=component.quarters[1]
	$VBC/Params/Quad3.selected=component.quarters[2]
	$VBC/Params/Quad4.selected=component.quarters[3]
	$VBC/Params/Cycles.value=component.cycles
	$VBC/Params/Position.value=component.pos0*100.0
	from_node.value=get_component_index(component.input_comp)
	from_node.max_value=wave.components.size()-1
	$VBC/Params/Output.selected=component.output_mode
	$VBC/Params/PM.value=component.pm*100.0
	$VBC/Params/AM.value=component.am*100.0
	$VBC/Params/XM.value=component.xm*100.0
	set_block_signals(false)

#

func _on_Mul_value_changed(value:float)->void:
	component.freq_mult=value
	emit_signal("params_changed")

func _on_Ofs_value_changed(value:float)->void:
	component.phi0=value/100.0
	emit_signal("params_changed")

func _on_Vol_value_changed(value:float)->void:
	component.vol=value/100.0
	emit_signal("params_changed")

func _on_Quad1_item_selected(id:int)->void:
	component.quarters[0]=id
	emit_signal("params_changed")

func _on_Quad2_item_selected(id:int)->void:
	component.quarters[1]=id
	emit_signal("params_changed")

func _on_Quad3_item_selected(id:int)->void:
	component.quarters[2]=id
	emit_signal("params_changed")

func _on_Quad4_item_selected(id:int)->void:
	component.quarters[3]=id
	emit_signal("params_changed")

func _on_PM_value_changed(value:float)->void:
	component.pm=value/100.0
	emit_signal("params_changed")

func _on_AM_value_changed(value:float)->void:
	component.am=value/100.0
	emit_signal("params_changed")

func _on_XM_value_changed(value:float)->void:
	component.xm=value/100.0
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

func _on_Power_value_changed(value:float)->void:
	component.power=value
	emit_signal("params_changed")


func _on_Decay_value_changed(value:float)->void:
	component.decay=value
	emit_signal("params_changed")
