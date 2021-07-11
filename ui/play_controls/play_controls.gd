extends Control


onready var play:Button=$HBC/Play
onready var play_track:Button=$HBC/PlayTrack


func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")


func _on_song_changed()->void:
	play.pressed=false
	play_track.pressed=false


func _unhandled_input(ev:InputEvent)->void:
	if not(ev is InputEventKey):
		return
	if ev.scancode!=GKBD.PLAY_ALL and ev.scancode!=GKBD.PLAY_TRACK:
		return
	accept_event()
	if ev.pressed:
		return
	if ev.scancode==GKBD.PLAY_ALL:
		play.pressed=!play.pressed
	else:
		play_track.pressed=!play_track.pressed


func _on_Play_toggled(pressed:bool)->void:
	if pressed:
		play_track.pressed=false
		AUDIO.tracker.play(GLOBALS.curr_order)
	else:
		AUDIO.tracker.stop()


func _on_PlayTrack_toggled(pressed:bool)->void:
	if pressed:
		play.pressed=false
		AUDIO.tracker.play_track(GLOBALS.curr_order)
	else:
		AUDIO.tracker.stop()
