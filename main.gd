extends VBoxContainer

"""
TODO:
"""

func _ready()->void:
	AUDIO.connect("buffer_sent",$Oscilloscope,"plot_stereo_buffer")

func _on_tab_changed(tab:int)->void:
	var t:Tabs=$Tabs.get_tab_control(tab)
	if t.has_method("update_ui"):
		t.update_ui()

func _on_PlayButton_toggled(button_pressed:bool)->void:
	if button_pressed:
		AUDIO.tracker.play(GLOBALS.curr_order)
	else:
		AUDIO.tracker.stop()
