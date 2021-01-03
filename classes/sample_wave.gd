extends Waveform
class_name SampleWave

const CHUNK_ID:String="sAMW"
const CHUNK_VERSION:int=0
const DIVISORS:Dictionary={8:128.0,16:32768.0,24:8388608.0,32:1.0}

var original_data:Array=[]
var bits_sample:int=16
var loop_start:int=0
var loop_end:int=0
var record_freq:float=48000.0
var sample_freq:float=440.0

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
	if !.equals(other):
		return false
	if other.get("CHUNK_ID")!=CHUNK_ID:
		return false
	return true

#

func serialize(out:ChunkedFile)->void:
	out.start_chunk(CHUNK_ID,CHUNK_VERSION)
	out.store_32(original_data.size())
	out.store_8(bits_sample)
	out.store_32(loop_start)
	out.store_32(loop_end)
	out.store_float(record_freq)
	out.store_float(sample_freq)
	out.store_pascal_string(name)
	for sam in original_data:
		if bits_sample==8:
			out.store_8(sam+0x80)
		elif bits_sample==16:
			out.store_16(sam+0x8000)
		elif bits_sample==32:
			out.store_float(sam)
		else:
			sam+=0x800000
			out.store_8(sam>>16)
			out.store_16(sam&0xffff)
	out.end_chunk()

#

func deserialize(inf:ChunkedFile,w:SampleWave,_version:int)->void:
	w.size=inf.get_32()
	w.original_data.resize(w.size)
	w.bits_sample=inf.get_8()
	w.loop_start=inf.get_32()
	w.loop_end=inf.get_32()
	w.record_freq=inf.get_float()
	w.sample_freq=inf.get_float()
	w.name=inf.get_pascal_string()
	for i in range(w.size):
		if bits_sample==8:
			w.original_data[i]=inf.get_8()-0x80
		elif bits_sample==16:
			w.original_data[i]=inf.get_16()-0x8000
		elif bits_sample==32:
			w.original_data[i]=inf.get_float()
		else:
			w.original_data[i]=((inf.get_8()<<16)|inf.get_16())-0x800000
	w.calculate()

func load_wave(path:String)->void:
	var file:WaveFile=WaveFile.new()
	var wave:Dictionary=file.obj_load(path)
	if wave.error==OK:
		original_data=wave.data
		bits_sample=wave.bits
		loop_start=0
		loop_end=0
		record_freq=wave.freq
		sample_freq=440.0
		calculate()
