extends Control

"""
FIXME
	Export sometimes crashes. (Buffer freed before final write?)
TODO:
	Independent config values for every save/loadable item.
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
	AUDIO.connect("buffer_sent",$Main/Oscilloscope,"plot_stereo_buffer")

func _on_tab_changed(tab:int)->void:
	var t:Tabs=$Main/Tabs.get_tab_control(tab)
	if t.has_method("update_ui"):
		t.update_ui()

func _on_Play_toggled(button_pressed:bool)->void:
	if button_pressed:
		$PlayControls/PC/HBC/PlayTrack.pressed=false
		AUDIO.tracker.play(GLOBALS.curr_order)
	else:
		AUDIO.tracker.stop()

func _on_PlayTrack_toggled(button_pressed):
	if button_pressed:
		$PlayControls/PC/HBC/Play.pressed=false
		AUDIO.tracker.play_track(GLOBALS.curr_order)
	else:
		AUDIO.tracker.stop()
