extends VBoxContainer

signal instrument_name_changed(index,text)
signal instrument_changed

var params:Node

func _ready()->void:
	params=$Tabs/Parameters/Params/VBC
	update_instrument()

func update_instrument()->void:
	if params==null:
		return
	var ci:Instrument=GLOBALS.get_instrument()
	if ci==null:
		return
	$Info/HBC/Name.text=ci.name
	for i in range(1,5):
		params.get_node("OPS/OP%d"%[i]).set_sliders(ci)
	params.get_node("Routing").set_sliders(ci)

func _on_Name_changed(text:String)->void:
	var ci:Instrument=GLOBALS.get_instrument()
	if ci==null:
		return
	ci.name=text
	emit_signal("instrument_name_changed",GLOBALS.curr_instrument,text)

func _on_instrument_selected(_idx:int)->void:
	update_instrument()

func _on_instrument_changed()->void:
	emit_signal("instrument_changed")

func _on_operator_changed(op:int)->void:
	var ci:Instrument=GLOBALS.get_instrument()
	if ci==null:
		return
	params.get_node("OPS/OP%d"%[op+1]).set_sliders(ci)
	params.get_node("Routing").set_sliders(ci)
