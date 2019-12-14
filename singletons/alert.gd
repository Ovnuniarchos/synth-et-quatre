extends CanvasLayer

onready var fader:Panel=$Fader
onready var dlg:AcceptDialog=$Fader/Alert

var active:bool=false

func _ready()->void:
	fader.visible=false
	dlg.get_label().valign=Label.VALIGN_CENTER
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	_on_song_changed()

func _on_song_changed()->void:
	GLOBALS.song.connect("error",self,"alert")

func alert(message:String)->void:
	GLOBALS.dialog_opened(self)
	active=true
	fader.visible=true
	dlg.dialog_text=message
	dlg.popup_centered_clamped(Vector2(512.0,128.0),0.75)

func _on_popup_hide()->void:
	GLOBALS.dialog_closed(self)
	active=false
	fader.visible=false
