extends WaveComponentIO
class_name LPFFilterReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,LPF_ID,LPF_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:LPF_ID,
			FileResult.ERRV_EXP_VERSION:LPF_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var f:LpfFilter=LpfFilter.new()
	_deserialize_start(inf,f,version)
	f.cutoff=inf.get_float()
	f.taps=inf.get_16()
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new(OK,f)
