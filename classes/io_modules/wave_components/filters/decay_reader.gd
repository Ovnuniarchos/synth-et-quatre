extends WaveComponentIO
class_name DecayFilterReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,DECAY_ID,DECAY_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			"chunk":inf.get_chunk_id(header),
			"version":inf.get_chunk_version(header),
			"ex_chunk":DECAY_ID,
			"ex_version":DECAY_VERSION,
			"file":inf.get_path()
		})
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var f:DecayFilter=DecayFilter.new()
	_deserialize_start(inf,f,version)
	f.decay=inf.get_float()
	if inf.get_error():
		return FileResult.new(inf.get_error(),{"file":inf.get_path()})
	return FileResult.new(OK,f)
