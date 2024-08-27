extends Tabs


onready var tabs:TabContainer=$HS/VS/Tabs
onready var synth:VBoxContainer=$HS/VS/Tabs/SynthDesigner
onready var node:VBoxContainer=$HS/VS/Tabs/NodeDesigner
onready var sample:VBoxContainer=$HS/VS/Tabs/SampleDesigner


func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	_on_wave_selected(-1)


func _on_song_changed()->void:
	synth._on_wave_selected(-1)
	sample._on_wave_selected(-1)
	node._on_wave_selected(-1)


func _on_wave_deleted(wave_ix:int)->void:
	print(wave_ix)
	var w:Waveform=GLOBALS.song.get_wave(wave_ix)
	if w is SynthWave:
		synth._on_wave_deleted(wave_ix)
	elif w is SampleWave:
		sample._on_wave_deleted(wave_ix)
	elif w is NodeWave:
		node._on_wave_deleted(wave_ix)


func _on_wave_selected(wave_ix:int)->void:
	if not is_node_ready():
		yield(self,"ready")
	if wave_ix==-1:
		_on_song_changed()
		return
	var w:Waveform=GLOBALS.song.get_wave(wave_ix)
	if w is SynthWave:
		tabs.current_tab=0
		synth._on_wave_selected(wave_ix)
	elif w is SampleWave:
		tabs.current_tab=1
		sample._on_wave_selected(wave_ix)
	elif w is NodeWave:
		tabs.current_tab=2
		node._on_wave_selected(wave_ix)
