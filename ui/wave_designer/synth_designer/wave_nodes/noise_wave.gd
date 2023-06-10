extends WaveController

func _ready()->void:
	from_node=$VBC/Params/From
	title_node=$VBC/Title
	setup()

func setup()->void:
	.setup()
	set_block_signals(true)
	$VBC/Params/Seed.value=component.rng_seed
	$VBC/Params/Tone.value=component.tone*100.0
	$VBC/Params/Position.value=component.pos0*100.0
	$VBC/Params/Len.value=component.length*100.0
	$VBC/Params/Vol.value=component.vol*100.0
	from_node.value=get_component_index(component.input_comp)
	from_node.max_value=wave.components.size()-1
	$VBC/Params/Output.selected=component.output_mode
	$VBC/Params/AM.value=component.am*100.0
	$VBC/Params/XM.value=component.xm*100.0
	set_block_signals(false)

#

func _on_Seed_value_changed(value:int)->void:
	component.rng_seed=value
	emit_signal("params_changed")

func _on_Tone_value_changed(value:float)->void:
	component.tone=value/100.0
	emit_signal("params_changed")

func _on_Position_value_changed(value:float)->void:
	component.pos0=value/100.0
	emit_signal("params_changed")

func _on_Len_value_changed(value:float)->void:
	component.length=value/100.0
	emit_signal("params_changed")

func _on_Vol_value_changed(value:float)->void:
	component.vol=value/100.0
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
