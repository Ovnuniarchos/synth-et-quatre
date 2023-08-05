extends Container

enum {WT_NONE,WT_SYNTH,WT_SAMPLE}

var sam:Array=Array()
var wave:WeakRef=null

func _ready()->void:
	_on_wave_calculated(-1)

func _on_mouse_entered()->void:
	$Control.modulate.a=1.0

func _on_mouse_exited()->void:
	$Control.grab_focus()
	$Control.modulate.a=0.2

func _on_Frequency_value_changed(value:float)->void:
	change_frequency(value)

func _on_Play_toggled(pressed:bool)->void:
	if pressed:
		$Player.play()
	else:
		$Player.stop()

func _on_wave_deleted(_wave:WeakRef)->void:
	wave=null
	$Control/Play.pressed=false
	_on_Play_toggled(false)

#

func get_wave()->Waveform:
	return null if wave==null else wave.get_ref()

func change_sample(w:Waveform)->void:
	var d:Array
	if w==null:
		d=[0.0]
		wave=null
	else:
		d=w.data
		wave=weakref(w)
	send_sample(d,$Control/Frequency.value)
	$Plot.draw_waveform(d)

func send_sample(sample:Array,freq:float)->void:
	var std:AudioStreamSample=$Player.stream as AudioStreamSample
	sam.resize(sample.size())
	for i in range(sample.size()):
		sam[i]=sample[i]*127.0
	std.data=PoolByteArray(sam)
	var w:Waveform=get_wave()
	if w is SynthWave:
		std.loop_begin=0
		std.loop_end=std.data.size()-1
		std.loop_mode=AudioStreamSample.LOOP_FORWARD
	elif w is SampleWave:
		std.loop_mode=AudioStreamSample.LOOP_FORWARD
		if w.loop_start>w.loop_end:
			std.loop_begin=w.loop_end
			std.loop_end=w.loop_start
		elif w.loop_start<w.loop_end:
			std.loop_begin=w.loop_start
			std.loop_end=w.loop_end
		else:
			std.loop_begin=0
			std.loop_end=std.data.size()-1
			std.loop_mode=AudioStreamSample.LOOP_DISABLED
	change_frequency(freq)

func change_frequency(freq:float)->void:
	var std:AudioStreamSample=$Player.stream as AudioStreamSample
	if std.data.size()==0:
		return
	var w:Waveform=get_wave()
	if w is SynthWave:
		std.mix_rate=std.data.size()*freq
	elif w is SampleWave:
		std.mix_rate=w.record_freq*(freq/w.sample_freq)

#

func _on_wave_calculated(wave_ix:int)->void:
	change_sample(GLOBALS.song.get_wave(wave_ix))
