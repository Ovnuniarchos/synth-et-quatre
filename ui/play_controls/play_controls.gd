extends Control

signal play_all(on)
signal play_track(on)

func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")

func _on_song_changed()->void:
	$PC/HBC/Play.pressed=false
	$PC/HBC/PlayTrack.pressed=false

func _unhandled_input(ev:InputEvent)->void:
	if not(ev is InputEventKey):
		return
	if ev.scancode!=GKBD.PLAY_ALL and ev.scancode!=GKBD.PLAY_TRACK:
		return
	accept_event()
	if ev.pressed:
		return
	if ev.scancode==GKBD.PLAY_ALL:
		$PC/HBC/Play.pressed=!$PC/HBC/Play.pressed
	else:
		$PC/HBC/PlayTrack.pressed=!$PC/HBC/PlayTrack.pressed

func _on_Play_toggled(pressed:bool)->void:
	emit_signal("play_all",pressed)

func _on_PlayTrack_toggled(pressed:bool)->void:
	emit_signal("play_track",pressed)
