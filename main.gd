extends Control

"""
TODO:	Envelope commands
		Synth commands
		Waveform deletion tests
		Waves cleanup
		Jump commands
		Global commands
		Full play controls
		Beautify file menu
		File selectors
		Sound format selector
		Export format selector
		WAV writer error messages
		File save/load errors
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
