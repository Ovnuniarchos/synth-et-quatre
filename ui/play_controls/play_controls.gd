extends Control


onready var play:Button=$HBC/Play
onready var play_track:Button=$HBC/PlayTrack
onready var poly_mode:Button=$HBC/PolyMode

var dragging:bool
var drag_pos:Vector2


func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	MIDI.connect("midi_on",self,"_on_midi_on")
	poly_mode.set_status(IM_SYNTH.poly)
	dragging=false


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


func _on_PolyMode_cycled(status:int)->void:
	IM_SYNTH.poly=status


func _on_PC_sort_children()->void:
	rect_size.x=0


func _on_VSeparator_gui_input(ev:InputEvent)->void:
	if ev is InputEventMouseButton:
		if ev.button_index==1:
			dragging=ev.pressed
			if dragging:
				drag_pos=ev.global_position
	if dragging and ev is InputEventMouseMotion:
		var vsz:Vector2=get_viewport().size
		rect_position+=ev.relative
		rect_position.x=min(max(0.0,rect_position.x),vsz.x-rect_size.x)
		rect_position.y=min(max(0.0,rect_position.y),vsz.y-rect_size.y)


func _on_midi_on(on:bool)->void:
	$HBC/Midi.pressed=on
