tool extends Button
class_name AccentButton


var real_theme:Theme


func _init()->void:
	toggle_mode=true


func _ready()->void:
	real_theme=THEME.get("theme")
	ThemeHelper.apply_styles(real_theme,"AccentButton",self)
