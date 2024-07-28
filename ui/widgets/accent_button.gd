tool extends Button
class_name AccentButton


func _init()->void:
	toggle_mode=true


func _ready()->void:
	ThemeHelper.apply_styles(ThemeHelper.get_theme(),"AccentButton",self)
