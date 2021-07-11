extends Tabs


onready var tabs:TabContainer=$HS/VS/Tabs
onready var synth:VBoxContainer=$HS/VS/Tabs/SynthDesigner
onready var sample:VBoxContainer=$HS/VS/Tabs/SampleDesigner
var delayed_wave_ix:int


func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	_on_wave_selected(delayed_wave_ix)


func _on_song_changed()->void:
	synth._on_wave_selected(-1)
	sample._on_wave_selected(-1)


func _on_wave_deleted(wave_ix:int)->void:
	var w:Waveform=GLOBALS.song.get_wave(wave_ix)
	if w is SynthWave:
		synth._on_wave_deleted(wave_ix)
	elif w is SampleWave:
		sample._on_wave_deleted(wave_ix)


func _on_wave_selected(wave_ix:int)->void:
	delayed_wave_ix=wave_ix
	if tabs==null:
		return
	var w:Waveform=GLOBALS.song.get_wave(wave_ix)
	synth._on_wave_selected(wave_ix)
	sample._on_wave_selected(wave_ix)
	if w is SynthWave:
		tabs.current_tab=0
	elif w is SampleWave:
		tabs.current_tab=1
