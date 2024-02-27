extends PanelContainer

signal instrument_changed
signal operator_changed(op)

export (int) var operator:int=0 setget set_op

var op_mask:int

func _ready()->void:
	set_op(operator)
	var ops:Array=[(operator+1)&3,(operator+2)&3,(operator+3)&3]
	ops.sort()
	for i in 3:
		var b:Button=get_node("Params/Switches/Copy%d"%[i+1])
		b.text=tr("FMED_COPY_TO_OPX").format({"i_op":ops[i]+1})
		b.hint_tooltip=tr("FMED_COPY_TO_OPX_TTIP").format({"i_op":ops[i]+1})
		b.connect("pressed",self,"_on_channel_copy",[operator,ops[i]])

func set_op(v:int)->void:
	operator=v&3
	$Params/Switches/Switch.text=tr("FMED_OPX").format({"i_op":operator+1})
	$Params/Switches/Switch.hint_tooltip=tr("FMED_OPX_TTIP").format({"i_op":operator+1})
	op_mask=1<<operator

func _on_channel_copy(from:int,to:int)->void:
	GLOBALS.get_instrument().copy_op(from,to)
	emit_signal("operator_changed",to)

func _on_DUCSlider_value_changed(value:float)->void:
	GLOBALS.get_instrument().duty_cycles[operator]=int(value)
	IM_SYNTH.set_duty_cycle(operator,int(value))
	emit_signal("instrument_changed")

func _on_WAVButton_item_selected(idx:int)->void:
	GLOBALS.get_instrument().waveforms[operator]=idx
	IM_SYNTH.set_wave(operator,idx)
	emit_signal("instrument_changed")

func _on_ARSlider_value_changed(value:float)->void:
	GLOBALS.get_instrument().attacks[operator]=int(value)
	IM_SYNTH.set_attack_rate(operator,int(value))
	emit_signal("instrument_changed")

func _on_DRSlider_value_changed(value:float)->void:
	GLOBALS.get_instrument().decays[operator]=int(value)
	IM_SYNTH.set_decay_rate(operator,int(value))
	emit_signal("instrument_changed")

func _on_SLSlider_value_changed(value:float)->void:
	GLOBALS.get_instrument().sustain_levels[operator]=int(value)
	IM_SYNTH.set_sustain_level(operator,int(value))
	emit_signal("instrument_changed")

func _on_SRSlider_value_changed(value:float)->void:
	GLOBALS.get_instrument().sustains[operator]=int(value)
	IM_SYNTH.set_sustain_rate(operator,int(value))
	emit_signal("instrument_changed")

func _on_RRSlider_value_changed(value:float)->void:
	GLOBALS.get_instrument().releases[operator]=int(value)
	IM_SYNTH.set_release_rate(operator,int(value))
	emit_signal("instrument_changed")

func _on_Repeat_item_selected(idx:int)->void:
	idx=$Params/ADSR/Repeat.get_item_id(idx)
	GLOBALS.get_instrument().repeats[operator]=idx
	IM_SYNTH.set_repeat(operator,idx)
	emit_signal("instrument_changed")

func _on_AMSSlider_value_changed(value:float)->void:
	GLOBALS.get_instrument().am_intensity[operator]=int(value)
	IM_SYNTH.set_am_intensity(operator,int(value))
	emit_signal("instrument_changed")

func _on_AmpLFO_item_selected(idx:int)->void:
	GLOBALS.get_instrument().am_lfo[operator]=idx
	IM_SYNTH.set_am_lfo(operator,idx)
	emit_signal("instrument_changed")

func _on_KSRSlider_value_changed(value:float)->void:
	GLOBALS.get_instrument().key_scalers[operator]=int(value)
	IM_SYNTH.set_ksr(operator,int(value))
	emit_signal("instrument_changed")

func _on_FMSSlider_value_changed(value:float)->void:
	GLOBALS.get_instrument().fm_intensity[operator]=int(value)
	IM_SYNTH.set_fm_intensity(operator,int(value))
	emit_signal("instrument_changed")

func _on_FreqLFO_item_selected(idx:int)->void:
	GLOBALS.get_instrument().fm_lfo[operator]=idx
	IM_SYNTH.set_fm_lfo(operator,idx)
	emit_signal("instrument_changed")

func _on_MULSlider_value_changed(value:float)->void:
	GLOBALS.get_instrument().multipliers[operator]=int(value)
	IM_SYNTH.set_freq_mul(operator,int(value))
	if int(value)>0:
		$Params/Detune/DETLabel.text=tr("FMED_DETUNE")
		$Params/Detune/DETLabel.hint_tooltip=tr("FMED_DETUNE_TTIP")
		$Params/Detune/DETSlider.hint_tooltip=tr("FMED_DETUNE_TTIP")
	else:
		$Params/Detune/DETLabel.text=tr("FMED_FIXED_FREQUENCY")
		$Params/Detune/DETLabel.hint_tooltip=tr("FMED_FIXED_FREQUENCY_TTIP")
		$Params/Detune/DETSlider.hint_tooltip=tr("FMED_FIXED_FREQUENCY_TTIP")
	emit_signal("instrument_changed")

func _on_DIVSlider_value_changed(value:float)->void:
	GLOBALS.get_instrument().dividers[operator]=int(value)-1
	IM_SYNTH.set_freq_div(operator,int(value)-1)
	emit_signal("instrument_changed")

func _on_DETSlider_value_changed(value):
	GLOBALS.get_instrument().detunes[operator]=int(value)
	IM_SYNTH.set_detune(operator,int(value))
	emit_signal("instrument_changed")

func _on_Switch_toggled(on:bool)->void:
	var opm:int=GLOBALS.get_instrument().op_mask
	opm&=-1^op_mask
	opm|=int(on)<<operator
	GLOBALS.get_instrument().op_mask=opm
	IM_SYNTH.set_enable(opm)
	emit_signal("instrument_changed")

func set_sliders(inst:FmInstrument)->void:
	set_block_signals(true)
	$Params/Switches/Switch.pressed=bool(inst.op_mask&op_mask)
	$Params/ADSR/ARSlider.value=inst.attacks[operator]
	$Params/ADSR/DRSlider.value=inst.decays[operator]
	$Params/ADSR/SLSlider.value=inst.sustain_levels[operator]
	$Params/ADSR/SRSlider.value=inst.sustains[operator]
	$Params/ADSR/RRSlider.value=inst.releases[operator]
	$Params/ADSR/Repeat.select($Params/ADSR/Repeat.get_item_index(inst.repeats[operator]))
	$Params/Frequency/MULSlider.value=inst.multipliers[operator]
	$Params/Frequency/DIVSlider.value=inst.dividers[operator]+1
	$Params/Detune/DETSlider.value=inst.detunes[operator]
	$Params/Wave/DUCSlider.value=inst.duty_cycles[operator]
	$Params/Wave/WAVButton.select(inst.waveforms[operator])
	$Params/ADSR/AMSSlider.value=inst.am_intensity[operator]
	$Params/LFOs/AmpLFO.select($Params/LFOs/AmpLFO.get_item_index(inst.am_lfo[operator]))
	$Params/ADSR/KSRSlider.value=inst.key_scalers[operator]
	$Params/FMS/FMSSlider.value=inst.fm_intensity[operator]
	$Params/LFOs/FreqLFO.select($Params/LFOs/FreqLFO.get_item_index(inst.fm_lfo[operator]))
	if inst.multipliers[operator]>0:
		$Params/Detune/DETLabel.text=tr("FMED_DETUNE")
		$Params/Detune/DETLabel.hint_tooltip=tr("FMED_DETUNE_TTIP")
		$Params/Detune/DETSlider.hint_tooltip=tr("FMED_DETUNE_TTIP")
	else:
		$Params/Detune/DETLabel.text=tr("FMED_FIXED_FREQUENCY")
		$Params/Detune/DETLabel.hint_tooltip=tr("FMED_FIXED_FREQUENCY_TTIP")
		$Params/Detune/DETSlider.hint_tooltip=tr("FMED_FIXED_FREQUENCY_TTIP")
	set_block_signals(false)
	emit_signal("instrument_changed")


