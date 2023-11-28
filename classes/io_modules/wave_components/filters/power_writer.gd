extends WaveComponentIO
class_name PowerFilterWriter


func _init(wc:Array).(wc)->void:
	pass


func serialize(out:ChunkedFile,f:PowerFilter)->FileResult:
	_serialize_start(out,f,POWER_ID,POWER_VERSION)
	out.store_float(f.power)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	return FileResult.new()
