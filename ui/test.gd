extends Control


func _ready():
	theme=THEME.theme
	"""
	var icn:AtlasTexture=ThemeParser.parse_image({
		"file":"editor.png",
		"rect":[0,92,12]
	},null)
	#
	rt.set_color("file_icon_modulate","FileDialog",Color.red)
	rt.set_color("files_disabled","FileDialog",Color.blue)
	rt.set_color("folder_icon_modulate","FileDialog",Color.green)
	rt.set_font("font","Tree",rt.get_font("default_font",""))
	#
	fnt=ThemeParser.parse_font({
		"font":{
			"file":"DejaVuSansMono-Bold.ttf",
			"size":10
		}},
		"font",null
	)
	rt.set_font("font","TooltipLabel",fnt)"""

func _on_Button_pressed():
	$AcceptDialog.popup_centered_ratio()


func _on_Button2_pressed():
	$FileDialog.popup_centered_ratio()
