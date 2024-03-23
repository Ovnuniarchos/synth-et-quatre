extends WaveComponentIO
class_name NoiseWaveReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,NOISE_ID,NOISE_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:NOISE_ID,
			FileResult.ERRV_EXP_VERSION:NOISE_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var w:NoiseWave=NoiseWave.new()
	_deserialize_start(inf,w,version)
	w.rng_seed=inf.get_32()
	w.tone=inf.get_float()
	w.pos0=inf.get_float()
	w.length=inf.get_float()
	if version>=1:
		w.power=inf.get_float()
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new(OK,w)
