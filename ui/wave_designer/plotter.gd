extends Container

var sam:Array=Array()

func _ready():
	_on_wave_calculated(-1)

func change_sample(buf:Array)->void:
	send_sample(buf,$Control/Frequency.value)
	$Oscilloscope.plot_mono_buffer(buf)

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
	$Control/Play.pressed=false
	_on_Play_toggled(false)

#

func send_sample(sample:Array,freq:float)->void:
	var std:AudioStreamSample=$Player.stream as AudioStreamSample
	sam.resize(sample.size())
	for i in range(0,sample.size()):
		sam[i]=sample[i]*127.0
	std.data=PoolByteArray(sam)
	std.loop_end=sample.size()-1
	change_frequency(freq)

func change_frequency(freq:float)->void:
	var std:AudioStreamSample=$Player.stream as AudioStreamSample
	if std.data.size()==0:
		return
	std.mix_rate=std.data.size()*freq

#

func _on_wave_calculated(wave_ix:int)->void:
	if wave_ix==-1:
		change_sample([0.0])
	else:
		change_sample(GLOBALS.song.wave_list[wave_ix].data)
