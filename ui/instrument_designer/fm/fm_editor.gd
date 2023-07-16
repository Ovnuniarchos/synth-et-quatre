extends VBoxContainer

signal instrument_name_changed(index,text)
signal instrument_changed

var params:Node
var gen_macro:Node
var ops_macro:Array
var param_dict:Dictionary

func _ready()->void:
	params=$Tabs/Parameters/Params/VBC
	gen_macro=$Tabs/Macros/Macro/VBC
	ops_macro=[
		$"Tabs/Macros OP1/Macro/VBC",
	]
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
	gen_macro.get_node("Volume").set_macro(ci.volume_macro)
	gen_macro.get_node("Pan").set_macro(ci.pan_macro)
	gen_macro.get_node("ChInvert").set_macro(ci.chanl_invert_macro)
	gen_macro.get_node("Clip").set_macro(ci.clip_macro)
	for op in 1:
		ops_macro[op].get_node("Duty").set_macro(ci.duty_macros[op])
		ops_macro[op].get_node("Wave").set_macro(ci.wave_macros[op])
	param_dict={
		"G_TONE":ci.freq_macro,
		"G_VOLUME":ci.volume_macro,
		"G_PAN":ci.pan_macro,
		"G_CHNINVERT":ci.chanl_invert_macro,
		"G_CLIP":ci.clip_macro,
		"O1_DUTY":ci.duty_macros[0],
		"O2_DUTY":ci.duty_macros[1],
		"O3_DUTY":ci.duty_macros[2],
		"O4_DUTY":ci.duty_macros[3],
		"O1_WAVE":ci.wave_macros[0],
		"O2_WAVE":ci.wave_macros[1],
		"O3_WAVE":ci.wave_macros[2],
		"O4_WAVE":ci.wave_macros[3],
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

func _on_macro_changed(parameter:String,values:Array,steps:int,loop_start:int,loop_end:int,release_loop_start:int,relative:bool,tick_div:int,delay:int)->void:
	if param_dict==null or not param_dict.has(parameter):
		return
	var pm:ParamMacro=param_dict.get(parameter) as ParamMacro
	pm.values=values
	pm.steps=steps
	pm.loop_start=loop_start
	pm.loop_end=loop_end
	pm.release_loop_start=release_loop_start
	pm.relative=relative
	pm.tick_div=tick_div
	pm.delay=delay
