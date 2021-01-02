tool extends Button
class_name AccentButton


var real_theme:Theme


func _init()->void:
	toggle_mode=true


func _ready()->void:
	real_theme=THEME.theme
	add_font_override("font",real_theme.get_font("font","AccentButton"))
	add_stylebox_override("normal",real_theme.get_stylebox("normal","AccentButton"))
	add_color_override("font_color",real_theme.get_color("font_color","AccentButton"))
	add_stylebox_override("focus",real_theme.get_stylebox("focus","AccentButton"))
	add_constant_override("hseparation",real_theme.get_constant("hseparation","AccentButton"))
	for st in ["disabled","hover","pressed"]:
		add_stylebox_override(st,real_theme.get_stylebox(st,"AccentButton"))
		add_color_override("font_color_"+st,real_theme.get_color("font_color_"+st,"AccentButton"))
