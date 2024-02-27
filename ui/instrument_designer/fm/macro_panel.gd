extends ScrollContainer


signal macro_changed(parameter,operator,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)


export (int) var operator:int=0


func _ready()->void:
	var c:Control
	for i in range(1,5):
		c=get_node("VBC/OP%d"%[i])
		if (i-1)==operator:
			c.title=tr("FMED_MO_OPXX")
			c.title_tooltip=tr("FMED_MO_OPXX_TTIP").format({"i_op":i})
		else:
			c.title=tr("FMED_MO_OPXY").format({"i_op_org":operator+1,"i_op_dst":i})
			c.title_tooltip=tr("FMED_MO_OPXY_TTIP").format({"i_op_org":operator+1,"i_op_dst":i})


func _on_macro_changed(parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)->void:
	emit_signal("macro_changed",parameter,operator,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)


func update_macros(ci:FmInstrument)->void:
	get_node("VBC/Tone").set_macro(ci.op_freq_macro[operator])
	get_node("VBC/KeyOn").set_macro(ci.op_key_macro[operator])
	get_node("VBC/Duty").set_macro(ci.duty_macros[operator])
	get_node("VBC/Wave").set_macro(ci.wave_macros[operator])
	get_node("VBC/Attack").set_macro(ci.attack_macros[operator])
	get_node("VBC/Decay").set_macro(ci.decay_macros[operator])
	get_node("VBC/SusLev").set_macro(ci.sus_level_macros[operator])
	get_node("VBC/SusRate").set_macro(ci.sus_rate_macros[operator])
	get_node("VBC/Release").set_macro(ci.release_macros[operator])
	get_node("VBC/Repeat").set_macro(ci.repeat_macros[operator])
	get_node("VBC/AMIntensity").set_macro(ci.ami_macros[operator])
	get_node("VBC/KeyScaling").set_macro(ci.ksr_macros[operator])
	get_node("VBC/Multiplier").set_macro(ci.multiplier_macros[operator])
	get_node("VBC/Divider").set_macro(ci.divider_macros[operator])
	get_node("VBC/Detune").set_macro(ci.detune_macros[operator])
	get_node("VBC/FMIntensity").set_macro(ci.fmi_macros[operator])
	get_node("VBC/AMLFO").set_macro(ci.am_lfo_macros[operator])
	get_node("VBC/FMLFO").set_macro(ci.fm_lfo_macros[operator])
	get_node("VBC/Phase").set_macro(ci.phase_macros[operator])
	get_node("VBC/OP1").set_macro(ci.op_macros[operator][0])
	get_node("VBC/OP2").set_macro(ci.op_macros[operator][1])
	get_node("VBC/OP3").set_macro(ci.op_macros[operator][2])
	get_node("VBC/OP4").set_macro(ci.op_macros[operator][3])
	get_node("VBC/Output").set_macro(ci.out_macros[operator])
