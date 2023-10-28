extends Control

"""
FIXME
	Check opmask in tracker (opmask-1???)
	First play skips row 0
TODO:
	X Automation
		X Full arpeggio command
		File support
	CycleButtons themable
	MIDI on/off indicator
	Reset per channel parameters (as a command|button)
	MIDI input
		Flag?: MIDI Pitch bend
		Flag?: MIDI modulation
		Range?: MIDI modulation

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
