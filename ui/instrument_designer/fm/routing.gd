extends PanelContainer

signal instrument_changed

func _on_OP1Slider_value_changed(value:float,from:int)->void:
	GLOBALS.get_instrument().routings[from][0]=int(value)
	emit_signal("instrument_changed")

func _on_OP2Slider_value_changed(value:float,from:int)->void:
	GLOBALS.get_instrument().routings[from][1]=int(value)
	emit_signal("instrument_changed")

func _on_OP3Slider_value_changed(value:float,from:int)->void:
	GLOBALS.get_instrument().routings[from][2]=int(value)
	emit_signal("instrument_changed")

func _on_OP4Slider_value_changed(value:float,from:int)->void:
	GLOBALS.get_instrument().routings[from][3]=int(value)
	emit_signal("instrument_changed")

func _on_OutSlider_value_changed(value:float,op:int)->void:
	GLOBALS.get_instrument().routings[op][-1]=int(value)
	emit_signal("instrument_changed")

func _on_Clip_toggled(button_pressed:bool)->void:
	GLOBALS.get_instrument().clip=button_pressed
	emit_signal("instrument_changed")

func set_sliders(inst:FmInstrument)->void:
	var rts:Array=inst.routings
	for i in range(4):
		for j in range(4):
			var n="Routings/Params/OP%d/OP%dSlider"%[i+1,j+1]
			get_node(n).value=float(rts[i][j])
		get_node("Routings/Params/OP%d/OutSlider"%(i+1)).value=float(rts[i][-1])
	$Routings/Clip.pressed=inst.clip
