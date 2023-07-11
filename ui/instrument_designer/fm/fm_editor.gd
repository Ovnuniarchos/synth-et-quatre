extends VBoxContainer

signal instrument_name_changed(index,text)
signal instrument_changed

var params:Node
var gen_macro:Node
var param_dict:Dictionary

func _ready()->void:
	params=$Tabs/Parameters/Params/VBC
	gen_macro=$Tabs/Macros/Macro/VBC
	update_instrument()

func update_instrument()->void:
	if params==null:
		return
	var ci:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if ci==null:
		return
	$Info/HBC/Name.text=ci.name
	for i in range(1,5):
		params.get_node("OPS/OP%d"%[i]).set_sliders(ci)
	params.get_node("Routing").set_sliders(ci)
	gen_macro.get_node("Tone").set_macro(ci.freq_macro)
	param_dict={
		"G_TONE":ci.freq_macro
	}

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

func _on_macro_changed(parameter:String,values:Array,steps:int,loop_start:int,loop_end:int,relative:bool,tick_div:int,delay:int)->void:
	if param_dict==null or not param_dict.has(parameter):
		return
	var pm:ParamMacro=param_dict.get(parameter) as ParamMacro
	pm.values=values
	pm.steps=steps
	pm.loop_start=loop_start
	pm.loop_end=loop_end
	pm.relative=relative
	pm.tick_div=tick_div
	pm.delay=delay
