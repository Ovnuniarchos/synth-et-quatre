extends VBoxContainer

signal instrument_name_changed(index,text)
signal instrument_changed

func update_instrument()->void:
	var ci:Instrument=GLOBALS.get_instrument()
	if ci==null:
		return
	$Info/HBC/Name.text=ci.name
	$Params/VBC/OPS/OP1.set_sliders(ci)
	$Params/VBC/OPS/OP2.set_sliders(ci)
	$Params/VBC/OPS/OP3.set_sliders(ci)
	$Params/VBC/OPS/OP4.set_sliders(ci)
	$Params/VBC/Routing.set_sliders(ci.routings)

func _on_Name_changed(text:String)->void:
	var ci:Instrument=GLOBALS.get_instrument()
	if ci==null:
		return
	ci.name=text
	emit_signal("instrument_name_changed",GLOBALS.curr_instrument,text)

func _on_instrument_selected(_idx:int)->void:
	update_instrument()

func _on_instrument_changed():
	emit_signal("instrument_changed")
