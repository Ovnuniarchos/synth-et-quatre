extends Control

"""
TODO:	Song title/author editor
		Pattern cleanup
		Instrument cleanup
		Waves cleanup
		Note commands
		Envelope commands
		Global commands
		Full play controls
		Beautify file menu
		Disk writer
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
