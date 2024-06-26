tool extends AccentButton
class_name PlayButton

export (String) var pressed_icon="Stop" setget set_pressed_icon
export (String) var unpressed_icon="Play" setget set_unpressed_icon

var icon_on:Texture
var icon_off:Texture

func _ready()->void:
	real_theme=THEME.get("theme")
	if real_theme!=null:
		icon_on=real_theme.get_icon(pressed_icon,"Glyphs")
		icon_off=real_theme.get_icon(unpressed_icon,"Glyphs")
	_toggled(pressed)

func set_pressed_icon(v:String)->void:
	pressed_icon=v
	if real_theme!=null:
		icon_on=real_theme.get_icon(pressed_icon,"Glyphs")

func set_unpressed_icon(v:String)->void:
	unpressed_icon=v
	if real_theme!=null:
		icon_off=real_theme.get_icon(unpressed_icon,"Glyphs")

func _toggled(p:bool)->void:
	if p:
		icon=icon_on
		text="PLAY_TEXT_STOP" if icon_on==null else ""
	else:
		icon=icon_off
		text="PLAY_TEXT_PLAY" if icon_off==null else ""
