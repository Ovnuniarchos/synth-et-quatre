extends Control

"""
FIXME
TODO:
	Move note playing to IM_SYNTH
	Mono/poly mode for IM_SYNTH
	DSP library for wave synthesis
	MIDI on/off indicator
	Reset per channel parameters (as a command|button)
	MIDI input
		Flag?: MIDI Pitch bend
		Flag?: MIDI modulation
		Range?: MIDI modulation
	Automation
	Reduce pops on volume changes.
		¿Smooth volume changes for n samples?

FUTURE:
	Translations
"""


func _ready()->void:
	theme=THEME.get("theme")
	ThemeHelper.apply_styles_group(theme,"LabelTitle","Title")
	ThemeHelper.apply_styles_group(theme,"LabelControl","Label")


func _on_tab_changed(tab:int)->void:
	var t:Tabs=$Main/Tabs.get_tab_control(tab)
	if t.has_method("update_ui"):
		t.update_ui()
