extends WaveComponentIO
class_name QuantizeFilterReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,QUANTIZE_ID,QUANTIZE_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			"chunk":inf.get_chunk_id(header),
			"version":inf.get_chunk_version(header),
			"ex_chunk":QUANTIZE_ID,
			"ex_version":QUANTIZE_VERSION,
			"file":inf.get_path()
		})
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var f:QuantizeFilter=QuantizeFilter.new()
	_deserialize_start(inf,f,version)
	f.steps=bool(inf.get_8())
	if inf.get_error():
		return FileResult.new(inf.get_error(),{"file":inf.get_path()})
	return FileResult.new(OK,f)
