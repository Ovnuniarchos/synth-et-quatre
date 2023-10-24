extends WaveComponentIO
class_name NoiseWaveReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->WaveComponent:
	if not inf.is_chunk_valid(header,NOISE_ID,NOISE_VERSION):
		return null
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var w:NoiseWave=NoiseWave.new()
	_deserialize_start(inf,w,version)
	w.rng_seed=inf.get_32()
	w.tone=inf.get_float()
	w.pos0=inf.get_float()
	w.length=inf.get_float()
	return w
