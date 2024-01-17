extends Control

"""
FIXME
TODO:
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
	ThemeHelper.apply_styles_to_group(theme,"LabelTitle","Title")
	ThemeHelper.apply_styles_to_group(theme,"LabelControl","Label")
	ThemeHelper.apply_styles_to_group(theme,"BarEditorLabel","BarEditorLabel")
	var parser:BarEditorLanguage=BarEditorLanguage.new()
	var pr:LanguageResult=parser.parse("line 1, 2 , 3 ,4 step 10 line 1,2,3")
	if pr.has_error():
		print(pr.get_message())
	else:
		print(pr.data)




func _on_tab_changed(tab:int)->void:
	var t:Tabs=$Main/Tabs.get_tab_control(tab)
	if t.has_method("update_ui"):
		t.update_ui()
