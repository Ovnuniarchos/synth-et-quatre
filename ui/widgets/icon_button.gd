extends Button
class_name IconButton

export (String) var icon_name:String="" setget set_icon_name

var real_theme:Theme

func _ready():
	real_theme=THEME.theme
	set_icon_name(icon_name)

func set_icon_name(n:String)->void:
	icon_name=n
	if real_theme!=null:
		icon=real_theme.get_icon(icon_name,"Icons")
