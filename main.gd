extends Control

"""
FIXME
	Export sometimes crashes. (Buffer freed before final write?)
TODO:
	Implement version numbers for files/chunks
	MIDI on/off indicator
	Reset per channel parameters (as a command|button)
	MIDI input
		Flag?: MIDI Pitch bend
		Flag?: MIDI modulation
		Range?: MIDI modulation
	Make arpeggio last until new note?
	Immediate note play skips notes (skips muted channels)
	Automation
	Reduce pops on volume changes.

FUTURE:
	Translations
	Themability
"""

func _ready()->void:
	AUDIO.connect("buffer_sent",$Main/Oscilloscope,"draw_music")

func _on_tab_changed(tab:int)->void:
	var t:Tabs=$Main/Tabs.get_tab_control(tab)
	if t.has_method("update_ui"):
		t.update_ui()

func _on_PlayControls_play_all(on:bool)->void:
	if on:
		$PlayControls/PC/HBC/PlayTrack.pressed=false
		AUDIO.tracker.play(GLOBALS.curr_order)
	else:
		AUDIO.tracker.stop()

func _on_PlayControls_play_track(on:bool)->void:
	if on:
		$PlayControls/PC/HBC/Play.pressed=false
		AUDIO.tracker.play_track(GLOBALS.curr_order)
	else:
		AUDIO.tracker.stop()
