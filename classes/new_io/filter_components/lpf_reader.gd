extends WaveComponentIO
class_name LPFFilterReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->WaveComponent:
	if not inf.is_chunk_valid(header,LPF_ID,LPF_VERSION):
		return null
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var f:LpfFilter=LpfFilter.new()
	_deserialize_start(inf,f,version)
	f.cutoff=inf.get_float()
	f.taps=inf.get_16()
	return f
