extends Control


func _ready()->void:
	theme=ThemeHelper.get_theme()
	ThemeHelper.apply_styles_to_group(theme,"LabelTitle","Title")
	ThemeHelper.apply_styles_to_group(theme,"LabelControl","Label")
	ThemeHelper.apply_styles_to_group(theme,"BarEditorLabel","BarEditorLabel")
	GLOBALS.connect("tab_changed",self,"_on_tab_changed")


func _on_tab_changed(tab:int)->void:
	$Main/Tabs.current_tab=tab
	var t:Tabs=$Main/Tabs.get_tab_control(tab)
	if t.has_method("update_ui"):
		t.update_ui()
