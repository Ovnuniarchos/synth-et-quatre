extends VBoxContainer

signal wave_calculated(wave_ix)
signal name_changed(wave_ix,text)

var sam_freq:SpinBar
var sam_note:OptionButton
var sam_octave:OptionButton
var sam_detune:NumberEdit
var curr_wave_ix:int=-1

func _init()->void:
	theme=THEME.get("theme")

func _ready()->void:
	sam_freq=$Designer/SC/VBC/GC/HBC/SamFreq
	sam_detune=$Designer/SC/VBC/GC/HBC/SamDetune
	sam_note=$Designer/SC/VBC/GC/HBC/SamNote
	for i in 12:
		sam_note.add_item("WAVED_SAM_SFREQ_STONE%d"%[i],i)
	sam_octave=$Designer/SC/VBC/GC/HBC/SamOctave
	for i in range(-5,14):
		sam_octave.add_item(str(i),i+5)
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

func set_size_samples(size:int)->void:
	if size>0:
		$Info/HBC/LabelSizeSamples.text=tr("WAVED_SIZE_SAMPLES").format({"i_samples":size})
	else:
		$Info/HBC/LabelSizeSamples.text=tr("WAVED_SIZE_NONE")


func _on_wave_selected(wave:int)->void:
	curr_wave_ix=wave
	var w:SampleWave=GLOBALS.song.get_wave(curr_wave_ix) as SampleWave
	if w==null:
		$Info/HBC/Name.editable=false
		$Info/HBC/Name.text=""
		set_size_samples(-1)
		$Designer/SC.visible=false
	else:
		$Info/HBC/Name.editable=true
		$Info/HBC/Name.text=w.name
		set_size_samples(w.size)
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
		SYNCER.send_wave(wave)
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
	$Designer/SC/VBC/GC/HBC/SamFreq.set_block_signals(true)
	$Designer/SC/VBC/GC/Start.set_block_signals(true)
	$Designer/SC/VBC/GC/End.set_block_signals(true)
	sam_note.set_block_signals(true)
	sam_octave.set_block_signals(true)
	$Designer/SC/VBC/GC/RecFreq.set_value(w.record_freq)
	var n:Dictionary=calc_note(w.sample_freq)
	sam_freq.set_value(w.sample_freq)
	sam_note.select(n["note"])
	sam_octave.select(n["v_octave"])
	sam_detune.set_value_no_signal(n["detune"])
	$Designer/SC/VBC/GC/Start.max_value=w.data.size()-1
	$Designer/SC/VBC/GC/Start.set_value(w.loop_start)
	$Designer/SC/VBC/GC/End.max_value=w.data.size()-1
	$Designer/SC/VBC/GC/End.set_value(w.loop_end)
	$Designer/SC/VBC/GC/RecFreq.set_block_signals(false)
	sam_freq.set_block_signals(false)
	$Designer/SC/VBC/GC/Start.set_block_signals(false)
	$Designer/SC/VBC/GC/End.set_block_signals(false)
	sam_note.set_block_signals(false)
	sam_octave.set_block_signals(false)
	set_size_samples(w.size)


func _on_FileDialog_popup_hide()->void:
	$Designer/SC/VBC/Load.notification(NOTIFICATION_MOUSE_EXIT)
	$Designer/SC/VBC/Load.notification(NOTIFICATION_FOCUS_EXIT)


func _on_values_changed(_value:float)->void:
	var w:SampleWave=GLOBALS.song.get_wave(curr_wave_ix) as SampleWave
	if w==null:
		return
	w.record_freq=$Designer/SC/VBC/GC/RecFreq.value
	w.loop_start=$Designer/SC/VBC/GC/Start.value
	w.loop_end=$Designer/SC/VBC/GC/End.value
	SYNCER.send_wave(w)
	emit_signal("wave_calculated",curr_wave_ix)


func calc_note(freq:float)->Dictionary:
	var note:float=(12.0*(log(freq/440.0)/log(2.0)))+117.0
	var octave:float=floor(note/12.0)-5.0
	var oct_note:float=fmod(note,12.0)
	return {
		"note":oct_note,
		"octave":octave,
		"v_octave":octave+5,
		"detune":(note-floor(note))*1000.0
	}


func _on_SamFreq_changed(value:float)->void:
	var w:SampleWave=GLOBALS.song.get_wave(curr_wave_ix) as SampleWave
	if w==null:
		return
	w.sample_freq=value
	var n:Dictionary=calc_note(value)
	sam_note.set_block_signals(true)
	sam_octave.set_block_signals(true)
	sam_note.select(n["note"])
	sam_octave.select(n["v_octave"])
	sam_detune.set_value_no_signal(n["detune"])
	sam_note.set_block_signals(false)
	sam_octave.set_block_signals(false)
	SYNCER.send_wave(w)


func calc_freq(note:int,octave:int,millis:int)->float:
	octave-=4
	var n:float=note+(octave*12.0)+(millis*0.001)
	return pow(2.0,(n-69.0)/12.0)*440.0


func _on_Note_changed(_v)->void:
	var w:SampleWave=GLOBALS.song.get_wave(curr_wave_ix) as SampleWave
	if w==null:
		return
	var freq:float=calc_freq(sam_note.get_selected_id(),sam_octave.get_selected_id(),sam_detune.get_value())
	sam_freq.set_value_no_signal(freq)
	w.sample_freq=freq
