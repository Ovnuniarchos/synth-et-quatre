extends WaveComponentIO
class_name HPFFilterWriter


func _init(wc:Array).(wc)->void:
	pass


func serialize(out:ChunkedFile,f:HpfFilter)->FileResult:
	_serialize_start(out,f,HPF_ID,HPF_VERSION)
	out.store_float(f.cutoff)
	out.store_16(f.taps)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	return FileResult.new()
