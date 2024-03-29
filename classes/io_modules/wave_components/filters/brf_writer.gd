extends WaveComponentIO
class_name BRFFilterWriter


func _init(wc:Array).(wc)->void:
	pass


func serialize(out:ChunkedFile,f:BrfFilter)->FileResult:
	_serialize_start(out,f,BRF_ID,BRF_VERSION)
	out.store_float(f.cutoff_lo)
	out.store_float(f.cutoff_hi)
	out.store_16(f.taps)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()
