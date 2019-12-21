extends Tabs

func _ready():
	sync_with_config($HBC/Audio/SampleRate,CONFIG.AUDIO_SAMPLERATE)
	sync_with_config($HBC/Audio/BufferSize,CONFIG.AUDIO_BUFFERLENGTH)
	sync_with_config($HBC/Export/SampleRate,CONFIG.RECORD_SAMPLERATE)
	sync_with_config($HBC/Export/FPSamples,CONFIG.RECORD_FPSAMPLES)
	sync_with_config($HBC/Export/SaveMuted,CONFIG.RECORD_SAVEMUTED)

func sync_with_config(ctrl:Control,key:Array)->void:
	ctrl.set_block_signals(true)
	if ctrl is LabelSpinBox:
		ctrl.value=CONFIG.get_value(key)
	elif ctrl is Button:
		ctrl.pressed=CONFIG.get_value(key)
	ctrl.set_block_signals(false)

#

func _on_AudioSampleRate_value_changed(value:float)->void:
	CONFIG.set_value(CONFIG.AUDIO_SAMPLERATE,int(value))
	AUDIO.set_mix_rate(value)

func _on_BufferSize_value_changed(value:float)->void:
	CONFIG.set_value(CONFIG.AUDIO_BUFFERLENGTH,value)
	AUDIO.set_buffer_length(value)

func _on_SampleRate_value_changed(value:float)->void:
	CONFIG.set_value(CONFIG.RECORD_SAMPLERATE,int(value))

func _on_FPSamples_toggled(pressed:float)->void:
	CONFIG.set_value(CONFIG.RECORD_FPSAMPLES,pressed)

func _on_SaveMuted_toggled(pressed:float)->void:
	CONFIG.set_value(CONFIG.RECORD_SAVEMUTED,pressed)
