extends WaveComponentIO
class_name RectangleWaveReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,RECTANGLE_ID,RECTANGLE_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:RECTANGLE_ID,
			FileResult.ERRV_EXP_VERSION:RECTANGLE_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var w:RectangleWave=RectangleWave.new()
	_deserialize_start(inf,w,version)
	w.freq_mult=inf.get_float()
	w.phi0=inf.get_float()
	w.z_start=inf.get_float()
	w.n_start=inf.get_float()
	w.cycles=inf.get_float()
	w.pos0=inf.get_float()
	w.pm=inf.get_float()
	if version>=1:
		w.decay=inf.get_float()
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new(OK,w)
