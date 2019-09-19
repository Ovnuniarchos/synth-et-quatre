tool extends Button
class_name AccentButton

export (Color) var accent_color:Color=Color.white

func _init()->void:
	toggle_mode=true

func _ready()->void:
	_toggled(pressed)

func _toggled(p:bool)->void:
	modulate=accent_color if p else Color.white
