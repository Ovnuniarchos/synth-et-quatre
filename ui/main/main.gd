extends Control

"""
FIXME
TODO:
	Parser for macro editors
	I/O for waves
	I/O for arpeggios
	Copy/Paste buttons for instrument/wave editors
	MIDI on/off indicator
	Reset per channel parameters (as a command|button)
	MIDI input
		Flag?: MIDI Pitch bend
		Flag?: MIDI modulation
		Range?: MIDI modulation

FUTURE:
"""


func _ready()->void:
	theme=THEME.get("theme")
	ThemeHelper.apply_styles_to_group(theme,"LabelTitle","Title")
	ThemeHelper.apply_styles_to_group(theme,"LabelControl","Label")
	ThemeHelper.apply_styles_to_group(theme,"BarEditorLabel","BarEditorLabel")
	GLOBALS.connect("tab_changed",self,"_on_tab_changed")
	"""
	var parser:BarEditorLanguage=BarEditorLanguage.new()
	var pr:LanguageResult=parser.parse("line 1,200,10,400,1 alpha 1,0,0.5 line 1,10,200")
	if pr.has_error():
		print(pr.get_message())
	else:
		print(pr.data)
	get_tree().quit()
	"""

func _on_tab_changed(tab:int)->void:
	$Main/Tabs.current_tab=tab
	var t:Tabs=$Main/Tabs.get_tab_control(tab)
	if t.has_method("update_ui"):
		t.update_ui()
