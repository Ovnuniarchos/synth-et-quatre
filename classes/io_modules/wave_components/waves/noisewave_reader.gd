extends WaveComponentIO
class_name NoiseWaveReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,NOISE_ID,NOISE_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			"chunk":inf.get_chunk_id(header),
			"version":inf.get_chunk_version(header),
			"ex_chunk":NOISE_ID,
			"ex_version":NOISE_VERSION,
			"file":inf.get_path()
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
		return FileResult.new(inf.get_error(),{"file":inf.get_path()})
	return FileResult.new(OK,w)
