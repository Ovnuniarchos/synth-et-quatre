extends WaveController

func _ready()->void:
	from_node=$VBC/Params/From
	title_node=$VBC/Title
	title_node.index=self.get_index()-1
	title_node.connect("delete_requested",designer,"_on_delete_requested")
	title_node.connect("move_requested",designer,"_on_move_requested")
	setup()

func setup()->void:
	set_block_signals(true)
	$VBC/Params/Cutoff.value=component.cutoff
	$VBC/Params/Taps.value=component.taps
	$VBC/Params/Vol.value=component.vol*100.0
	$VBC/Params/Output.selected=component.output_mode
	from_node.value=get_component_index(component.input_comp)
	from_node.max_value=wave.components.size()-1
	$VBC/Params/AM.value=component.am*100.0
	$VBC/Params/XM.value=component.xm*100.0
	adjust_max_node_from()
	set_block_signals(false)

func adjust_max_node_from()->void:
	from_node.max_value=wave.components.size()-2

#

func _on_Cutoff_value_changed(value:float)->void:
	component.cutoff=clamp(value,1.0,1000.0)
	emit_signal("params_changed")

func _on_Taps_value_changed(value:float)->void:
	component.taps=clamp(value,1.0,128.0)
	emit_signal("params_changed")

func _on_From_value_changed(from:int)->void:
	component.input_comp=wave.get_component(from)
	emit_signal("params_changed")

func _on_Output_item_selected(id:int)->void:
	component.output_mode=id
	emit_signal("params_changed")

func _on_Vol_value_changed(value:float)->void:
	component.vol=clamp(value/100.0,-100.0,100.0)
	emit_signal("params_changed")

func _on_AM_value_changed(value:float)->void:
	component.am=clamp(value/100.0,-1.0,1.0)
	emit_signal("params_changed")

func _on_XM_value_changed(value:float)->void:
	component.xm=clamp(value/100.0,-1.0,1.0)
	emit_signal("params_changed")
