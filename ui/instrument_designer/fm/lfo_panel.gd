extends PanelContainer

export (int) var lfo:int=0 setget set_lfo

func _ready()->void:
	GLOBALS.connect("song_changed",self,"update_values")
	set_lfo(lfo)
	update_values()

func set_lfo(ix:int)->void:
	lfo=ix&3
	$VBC/Title.text=tr("FMED_LFOX_TITLE").format({"i_lfo":lfo+1})

func update_values()->void:
	$VBC/HBC/DUCSlider.value=GLOBALS.song.lfo_duty_cycles[lfo]
	SYNCER.set_lfo_duty_cycle(lfo,GLOBALS.song.lfo_duty_cycles[lfo])
	$VBC/HBC/WAVButton.select(GLOBALS.song.lfo_waves[lfo])
	SYNCER.set_lfo_wave(lfo,GLOBALS.song.lfo_waves[lfo])
	$VBC/HBC2/FRQSlider.value=GLOBALS.song.lfo_frequencies[lfo]
	SYNCER.set_lfo_frequency(lfo,GLOBALS.song.lfo_frequencies[lfo])


func _on_DUCSlider_value_changed(value:float)->void:
	var iv:int=int(value)
	var lfo_duty_cycles:Array=GLOBALS.song.lfo_duty_cycles
	lfo_duty_cycles[lfo]=iv
	SYNCER.set_lfo_duty_cycle(lfo,iv)


func _on_WAVButton_item_selected(idx:int)->void:
	var lfo_waves:Array=GLOBALS.song.lfo_waves
	lfo_waves[lfo]=idx
	SYNCER.set_lfo_wave(lfo,idx)


func _on_FRQSlider_value_changed(value:float)->void:
	var lfo_frequencies:Array=GLOBALS.song.lfo_frequencies
	lfo_frequencies[lfo]=value
	SYNCER.set_lfo_frequency(lfo,value)
