extends WaveComponentIO
class_name NoiseWaveWriter


func _init(wc:Array).(wc)->void:
	pass


func serialize(out:ChunkedFile,w:NoiseWave)->FileResult:
	_serialize_start(out,w,NOISE_ID,NOISE_VERSION)
	out.store_32(w.rng_seed)
	out.store_float(w.tone)
	out.store_float(w.pos0)
	out.store_float(w.length)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	return FileResult.new()
