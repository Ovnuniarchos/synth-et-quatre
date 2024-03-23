extends WaveComponentIO
class_name ClampFilterReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,CLAMP_ID,CLAMP_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:CLAMP_ID,
			FileResult.ERRV_EXP_VERSION:CLAMP_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var f:ClampFilter=ClampFilter.new()
	_deserialize_start(inf,f,version)
	f.u_clamp_on=bool(inf.get_8())
	f.l_clamp_on=bool(inf.get_8())
	f.u_clamp=inf.get_float()
	f.l_clamp=inf.get_float()
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new(OK,f)
