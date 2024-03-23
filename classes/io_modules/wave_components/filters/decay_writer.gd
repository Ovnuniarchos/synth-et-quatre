extends WaveComponentIO
class_name DecayFilterWriter


func _init(wc:Array).(wc)->void:
	pass


func serialize(out:ChunkedFile,f:DecayFilter)->FileResult:
	_serialize_start(out,f,DECAY_ID,DECAY_VERSION)
	out.store_float(f.decay)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()
