extends WaveComponentIO
class_name QuantizeFilterWriter


func _init(wc:Array).(wc)->void:
	pass


func serialize(out:ChunkedFile,f:QuantizeFilter)->FileResult:
	_serialize_start(out,f,QUANTIZE_ID,QUANTIZE_VERSION)
	out.store_8(f.steps)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()
