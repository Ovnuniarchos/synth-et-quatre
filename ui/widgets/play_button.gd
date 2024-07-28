tool extends AccentButton
class_name PlayButton

export (String) var pressed_icon="stop" setget set_pressed_icon
export (String) var pressed_text="PLAY_TEXT_STOP"
export (String) var unpressed_icon="play" setget set_unpressed_icon
export (String) var unpressed_text="PLAY_TEXT_PLAY"

var icon_on:Texture
var icon_off:Texture

func _ready()->void:
	set_pressed_icon(pressed_icon)
	set_unpressed_icon(unpressed_icon)

func set_pressed_icon(v:String)->void:
	pressed_icon=v
	icon_on=ThemeHelper.get_icon(pressed_icon,"Glyphs")
	_toggled(pressed)

func set_unpressed_icon(v:String)->void:
	unpressed_icon=v
	icon_off=ThemeHelper.get_icon(unpressed_icon,"Glyphs")
	_toggled(pressed)

func _toggled(p:bool)->void:
	if p:
		icon=icon_on
		text=pressed_text if icon_on==null else ""
	else:
		icon=icon_off
		text=unpressed_text if icon_off==null else ""
