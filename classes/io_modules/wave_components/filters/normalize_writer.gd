extends WaveComponentIO
class_name NormalizeFilterWriter


func _init(wc:Array).(wc)->void:
	pass


func serialize(out:ChunkedFile,f:NormalizeFilter)->FileResult:
	_serialize_start(out,f,NORMALIZE_ID,NORMALIZE_VERSION)
	out.store_8(int(f.keep_center))
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	return FileResult.new()
