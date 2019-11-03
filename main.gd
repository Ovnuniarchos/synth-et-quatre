extends Control

"""
TODO:	Instrument cleanup
		Pattern cleanup: Bad deletion order after 1st remove/channel
		Double click needed on order list
		Bad highlight on order list
		Note commands
		Envelope commands
		Synth commands
		Waveform deletion tests
		Waves cleanup
		Jump commands
		Global commands
		Full play controls
		Beautify file menu
		Disk writer+WAV format saver
"""

func _ready()->void:
	AUDIO.connect("buffer_sent",$Main/Oscilloscope,"plot_stereo_buffer")

func _on_tab_changed(tab:int)->void:
	var t:Tabs=$Main/Tabs.get_tab_control(tab)
	if t.has_method("update_ui"):
		t.update_ui()

func _on_PlayButton_toggled(button_pressed:bool)->void:
	if button_pressed:
		AUDIO.tracker.play(GLOBALS.curr_order)
	else:
		AUDIO.tracker.stop()
