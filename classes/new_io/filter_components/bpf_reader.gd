extends WaveComponentIO
class_name BPFFilterReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->WaveComponent:
	if not inf.is_chunk_valid(header,BPF_ID,BPF_VERSION):
		return null
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var f:BpfFilter=BpfFilter.new()
	_deserialize_start(inf,f,version)
	f.cutoff_lo=inf.get_float()
	f.cutoff_hi=inf.get_float()
	f.taps=inf.get_16()
	return f
