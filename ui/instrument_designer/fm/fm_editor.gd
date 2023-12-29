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
		$"Tabs/Macros OP1/Macro",
		$"Tabs/Macros OP2/Macro",
		$"Tabs/Macros OP3/Macro",
		$"Tabs/Macros OP4/Macro"
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
	for opm in ops_macro:
		opm.update_macros(ci)
	gen_macro.get_node("Tone").set_macro(ci.freq_macro)
	gen_macro.get_node("Volume").set_macro(ci.volume_macro)
	gen_macro.get_node("Pan").set_macro(ci.pan_macro)
	gen_macro.get_node("KeyOn").set_macro(ci.key_macro)
	gen_macro.get_node("OpEnable").set_macro(ci.op_enable_macro)
	gen_macro.get_node("ChInvert").set_macro(ci.chanl_invert_macro)
	gen_macro.get_node("Clip").set_macro(ci.clip_macro)
	param_dict={
		"G_TONE":ci.freq_macro,
		"G_VOLUME":ci.volume_macro,
		"G_PAN":ci.pan_macro,
		"G_KEY":ci.key_macro,
		"G_OPEN":ci.op_enable_macro,
		"G_CHNINVERT":ci.chanl_invert_macro,
		"G_CLIP":ci.clip_macro
	}
	for i in range(1,5):
		param_dict["%d_TONE"%[i]]=ci.op_freq_macro[i-1]
		param_dict["%d_KEY"%[i]]=ci.op_key_macro[i-1]
		param_dict["%d_DUTY"%[i]]=ci.duty_macros[i-1]
		param_dict["%d_WAVE"%[i]]=ci.wave_macros[i-1]
		param_dict["%d_ATTACK"%[i]]=ci.attack_macros[i-1]
		param_dict["%d_DECAY"%[i]]=ci.decay_macros[i-1]
		param_dict["%d_SUSLEV"%[i]]=ci.sus_level_macros[i-1]
		param_dict["%d_SUSTAIN"%[i]]=ci.sus_rate_macros[i-1]
		param_dict["%d_RELEASE"%[i]]=ci.release_macros[i-1]
		param_dict["%d_REPEAT"%[i]]=ci.release_macros[i-1]
		param_dict["%d_AMS"%[i]]=ci.ami_macros[i-1]
		param_dict["%d_KSR"%[i]]=ci.ksr_macros[i-1]
		param_dict["%d_MUL"%[i]]=ci.multiplier_macros[i-1]
		param_dict["%d_DIV"%[i]]=ci.divider_macros[i-1]
		param_dict["%d_DETUNE"%[i]]=ci.detune_macros[i-1]
		param_dict["%d_FMS"%[i]]=ci.fmi_macros[i-1]
		param_dict["%d_AMLFO"%[i]]=ci.am_lfo_macros[i-1]
		param_dict["%d_FMLFO"%[i]]=ci.fm_lfo_macros[i-1]
		param_dict["%d_PHI"%[i]]=ci.phase_macros[i-1]
		param_dict["%d_OP1"%[i]]=ci.op_macros[i-1][0]
		param_dict["%d_OP2"%[i]]=ci.op_macros[i-1][1]
		param_dict["%d_OP3"%[i]]=ci.op_macros[i-1][2]
		param_dict["%d_OP4"%[i]]=ci.op_macros[i-1][3]
		param_dict["%d_OUT"%[i]]=ci.out_macros[i-1]


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


func _on_voice_macro_changed(parameter:String,values:Array,steps:int,loop_start:int,loop_end:int,release_loop_start:int,relative:bool,tick_div:int,delay:int)->void:
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


func _on_op_macro_changed(parameter, operator, values, steps, loop_start, loop_end, release_loop_start, relative, tick_div, delay):
	parameter="%d_%s"%[operator+1,parameter]
	var pm:ParamMacro=param_dict.get(parameter) as ParamMacro
	pm.values=values
	pm.steps=steps
	pm.loop_start=loop_start
	pm.loop_end=loop_end
	pm.release_loop_start=release_loop_start
	pm.relative=relative
	pm.tick_div=tick_div
	pm.delay=delay
