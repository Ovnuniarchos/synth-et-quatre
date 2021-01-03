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
		update_values(w)
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
	$FileDialog.current_dir=CONFIG.get_value(CONFIG.CURR_SAMPLE_DIR)
	$FileDialog.popup_centered_ratio()

func _on_file_selected(path:String)->void:
	CONFIG.set_value(CONFIG.CURR_SAMPLE_DIR,path.get_base_dir())
	var w:SampleWave=GLOBALS.song.get_wave(curr_wave_ix) as SampleWave
	w.load_wave(path)
	calculate()
	update_values(w)

func update_values(w:SampleWave)->void:
	$Designer/SC/VBC/GC/RecFreq.set_block_signals(true)
	$Designer/SC/VBC/GC/SamFreq.set_block_signals(true)
	$Designer/SC/VBC/GC/Start.set_block_signals(true)
	$Designer/SC/VBC/GC/End.set_block_signals(true)
	$Designer/SC/VBC/GC/RecFreq.set_value(w.record_freq)
	$Designer/SC/VBC/GC/SamFreq.set_value(w.sample_freq)
	$Designer/SC/VBC/GC/Start.max_value=w.data.size()-1
	$Designer/SC/VBC/GC/Start.set_value(w.loop_start)
	$Designer/SC/VBC/GC/End.max_value=w.data.size()-1
	$Designer/SC/VBC/GC/End.set_value(w.loop_end)
	$Designer/SC/VBC/GC/RecFreq.set_block_signals(false)
	$Designer/SC/VBC/GC/SamFreq.set_block_signals(false)
	$Designer/SC/VBC/GC/Start.set_block_signals(false)
	$Designer/SC/VBC/GC/End.set_block_signals(false)
	$Info/HBC/LabelSizeSamples.text="%d samples"%w.size

func _on_values_changed(_value:float)->void:
	var w:SampleWave=GLOBALS.song.get_wave(curr_wave_ix) as SampleWave
	if w==null:
		return
	w.record_freq=$Designer/SC/VBC/GC/RecFreq.value
	w.sample_freq=$Designer/SC/VBC/GC/SamFreq.value
	w.loop_start=$Designer/SC/VBC/GC/Start.value
	w.loop_end=$Designer/SC/VBC/GC/End.value
	GLOBALS.song.send_wave(w,SYNTH)
	emit_signal("wave_calculated",curr_wave_ix)
