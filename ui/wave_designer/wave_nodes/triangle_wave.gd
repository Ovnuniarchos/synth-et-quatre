extends WaveController

enum HALF{H0,H1,HZ,HH,HL}

func _ready()->void:
	from_node=$VBC/Params/From
	title_node=$VBC/Title
	title_node.index=self.get_index()-1
	title_node.connect("delete_requested",designer,"_on_delete_requested")
	title_node.connect("move_requested",designer,"_on_move_requested")
	setup()

func setup()->void:
	set_block_signals(true)
	$VBC/Params/Mul.value=component.freq_mult
	$VBC/Params/Ofs.value=component.phi0*100.0
	$VBC/Params/Vol.value=component.vol*100.0
	$VBC/Params/Half1.selected=component.halves[0]
	$VBC/Params/Half2.selected=component.halves[1]
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

func _on_Half1_item_selected(id:int)->void:
	component.halves[0]=id
	emit_signal("params_changed")

func _on_Half2_item_selected(id:int)->void:
	component.halves[1]=id
	emit_signal("params_changed")

func _on_Cycles_value_changed(value:float)->void:
	component.cycles=value
	emit_signal("params_changed")

func _on_Position_value_changed(value:float)->void:
	component.pos0=value/100.0
	emit_signal("params_changed")

