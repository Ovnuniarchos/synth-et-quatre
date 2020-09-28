extends VBoxContainer

signal wave_calculated(wave_ix)
signal name_changed(wave_ix,text)

var curr_wave_ix:int=-1

func _ready()->void:
	update_ui()

func update_ui()->void:
	_on_wave_selected(curr_wave_ix)

#

func _on_Name_changed(text:String)->void:
	var w:Waveform=GLOBALS.song.get_wave(curr_wave_ix)
	if w!=null:
		w.name=text
		emit_signal("name_changed",curr_wave_ix,text)

#

func set_size_bytes(size:int)->void:
	if size>0:
		$Info/HBC/LabelSizeSamples.text="%d samples"%[size]
	else:
		$Info/HBC/LabelSizeSamples.text="-- samples"

func _on_wave_selected(wave:int)->void:
	curr_wave_ix=wave
	var w:SampleWave=GLOBALS.song.get_wave(curr_wave_ix) as SampleWave
	if w==null:
		$Info/HBC/Name.editable=false
		$Info/HBC/Name.text=""
		set_size_bytes(-1)
		$Designer/SC.visible=false
	else:
		$Info/HBC/Name.editable=true
		$Info/HBC/Name.text=w.name
		set_size_bytes(w.size)
		$Designer/SC.visible=true
	calculate()

func _on_wave_deleted(_wave:int)->void:
	curr_wave_ix=-1
	calculate()

#

func calculate()->void:
	var wave:Waveform=GLOBALS.song.get_wave(curr_wave_ix)
	if wave!=null:
		wave.calculate()
		GLOBALS.song.send_wave(wave,SYNTH)
	emit_signal("wave_calculated",curr_wave_ix)

#

func _on_Load_pressed()->void:
	$FileDialog.popup_centered_ratio()

func _on_file_selected(path:String)->void:
	var w:SampleWave=GLOBALS.song.get_wave(curr_wave_ix) as SampleWave
	w.load_wave(path)
	calculate()
	$Designer/SC/VBC/RecFreq.set_block_signals(true)
	$Designer/SC/VBC/SamFreq.set_block_signals(true)
	$Designer/SC/VBC/Start.set_block_signals(true)
	$Designer/SC/VBC/End.set_block_signals(true)
	$Designer/SC/VBC/RecFreq.set_value(w.record_freq)
	$Designer/SC/VBC/SamFreq.set_value(w.sample_freq)
	$Designer/SC/VBC/Start.max_value=w.data.size()-1
	$Designer/SC/VBC/Start.set_value(w.loop_start)
	$Designer/SC/VBC/End.max_value=w.data.size()-1
	$Designer/SC/VBC/End.set_value(w.loop_end)
	$Designer/SC/VBC/RecFreq.set_block_signals(false)
	$Designer/SC/VBC/SamFreq.set_block_signals(false)
	$Designer/SC/VBC/Start.set_block_signals(false)
	$Designer/SC/VBC/End.set_block_signals(false)

func _on_values_changed(_value:float)->void:
	var w:SampleWave=GLOBALS.song.get_wave(curr_wave_ix) as SampleWave
	if w==null:
		return
	w.record_freq=$Designer/SC/VBC/RecFreq.value
	w.sample_freq=$Designer/SC/VBC/SamFreq.value
	w.loop_start=$Designer/SC/VBC/Start.value
	w.loop_end=$Designer/SC/VBC/End.value
	GLOBALS.song.send_wave(w,SYNTH)
	emit_signal("wave_calculated",curr_wave_ix)