extends WaveComponentIO
class_name ClampFilterReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,CLAMP_ID,CLAMP_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			"chunk":inf.get_chunk_id(header),
			"version":inf.get_chunk_version(header),
			"ex_chunk":CLAMP_ID,
			"ex_version":CLAMP_VERSION,
			"file":inf.get_path()
		})
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var f:ClampFilter=ClampFilter.new()
	_deserialize_start(inf,f,version)
	f.u_clamp_on=bool(inf.get_8())
	f.l_clamp_on=bool(inf.get_8())
	f.u_clamp=inf.get_float()
	f.l_clamp=inf.get_float()
	if inf.get_error():
		return FileResult.new(inf.get_error(),{"file":inf.get_path()})
	return FileResult.new(OK,f)
