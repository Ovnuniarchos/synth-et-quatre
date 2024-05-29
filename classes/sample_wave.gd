extends Waveform
class_name SampleWave

const WAVE_TYPE:String="Sample"
const DIVISORS:Dictionary={8:128.0,16:32768.0,24:8388608.0,32:1.0}

var original_data:Array=[]
var bits_sample:int=16
var loop_start:int=0
var loop_end:int=0
var record_freq:float=48000.0
var sample_freq:float=440.0

func _init()->void:
	name=tr("DEFN_SAMPLE_WAVE")

func calculate()->void:
	var buf_size:int=original_data.size()
	data.resize(buf_size)
	size=buf_size
	var div:float=DIVISORS[bits_sample]
	for i in range(buf_size):
		data[i]=original_data[i]/div

func duplicate()->Waveform:
	var nw:SampleWave=.duplicate() as SampleWave
	nw.loop_start=loop_start
	nw.loop_end=loop_end
	nw.record_freq=record_freq
	nw.sample_freq=sample_freq
	nw.original_data=original_data.duplicate()
	nw.bits_sample=bits_sample
	return nw

func equals(other:Waveform)->bool:
	return .equals(other)

func load_wave(path:String)->void:
	var file:WAVFile=WAVFile.new()
	var wave:Dictionary=file.obj_load(path)
	if wave.error==OK:
		original_data=wave.data
		bits_sample=wave.bits
		loop_start=0
		loop_end=0
		record_freq=wave.freq
		sample_freq=440.0
		calculate()
