extends CanvasLayer

onready var dlg:AcceptDialog=$Alert

func _ready()->void:
	dlg.theme=THEME.theme
	dlg.get_label().valign=Label.VALIGN_CENTER
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	_on_song_changed()

func _on_song_changed()->void:
	GLOBALS.song.connect("error",self,"alert")

func alert(message:String)->void:
	FADER.show(self)
	dlg.dialog_text=message
	dlg.popup_centered_clamped(Vector2(512.0,128.0),0.75)

func _on_popup_hide()->void:
	FADER.hide(self)
