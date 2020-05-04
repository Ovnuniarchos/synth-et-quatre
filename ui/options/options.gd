extends Tabs

func _on_AudioSampleRate_value_changed(value:float)->void:
	AUDIO.set_mix_rate(value)

func _on_AudioBufferSize_value_changed(value:float)->void:
	AUDIO.set_buffer_length(value)

func _on_HorizFXEdit_toggled(pressed:bool)->void:
	$SC/VBC/HBC2/Editor/FXCRLF.disabled=!pressed
