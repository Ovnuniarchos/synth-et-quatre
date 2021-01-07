extends Tabs

func _ready()->void:
	$SC/GC/MarginContainer/ThemeFile.text=CONFIG.get_value(CONFIG.THEME_FILE)

func _on_AudioSampleRate_value_changed(value:float)->void:
	AUDIO.set_mix_rate(value)

func _on_AudioBufferSize_value_changed(value:float)->void:
	AUDIO.set_buffer_length(value)

func _on_HorizFXEdit_toggled(pressed:bool)->void:
	$SC/GC/Editor/Editor/FXCRLF.disabled=!pressed

func _on_ThemeFile_pressed()->void:
	$FileDialog.popup_centered_ratio()

func _on_FileDialog_file_selected(path:String)->void:
	CONFIG.set_value(CONFIG.THEME_FILE,path)
	$SC/GC/ThemeTitle.text=path
	ALERT.alert("Changes will show after restarting.")
