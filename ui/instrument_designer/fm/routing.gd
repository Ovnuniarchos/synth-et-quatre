extends PanelContainer


signal instrument_changed


func _on_Clip_toggled(button_pressed:bool)->void:
	GLOBALS.get_instrument().clip=button_pressed
	IM_SYNTH.set_clip(button_pressed)
	emit_signal("instrument_changed")


func set_sliders(inst:FmInstrument)->void:
	var rts:Array=inst.routings
	for i in range(rts.size()):
		var n:Node=get_node("Routings/Params/OP"+String(i+1))
		for j in range(rts[i].size()):
			n.set_routing(j,rts[i][j])
	$Routings/Clip.pressed=inst.clip


func _on_routing_changed(value:float,from_op:int,to_op:int)->void:
	if to_op>=0 and to_op<4:
		GLOBALS.get_instrument().routings[from_op][to_op]=int(value)
		IM_SYNTH.set_pm_factor(from_op,to_op,int(value))
	else:
		GLOBALS.get_instrument().routings[from_op][-1]=int(value)
		IM_SYNTH.set_output(from_op,int(value))
	emit_signal("instrument_changed")
