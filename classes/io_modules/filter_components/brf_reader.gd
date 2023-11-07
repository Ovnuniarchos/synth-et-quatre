extends WaveComponentIO
class_name BRFFilterReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,BRF_ID,BRF_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			"chunk":inf.get_chunk_id(header),
			"version":inf.get_chunk_version(header),
			"ex_chunk":BRF_ID,
			"ex_version":BRF_VERSION,
			"file":inf.get_path()
		})
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var f:BrfFilter=BrfFilter.new()
	_deserialize_start(inf,f,version)
	f.cutoff_lo=inf.get_float()
	f.cutoff_hi=inf.get_float()
	f.taps=inf.get_16()
	if inf.get_error():
		return FileResult.new(inf.get_error(),{"file":inf.get_path()})
	return FileResult.new(OK,f)
