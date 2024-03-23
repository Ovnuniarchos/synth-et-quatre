extends WaveComponentIO
class_name ClampFilterWriter


func _init(wc:Array).(wc)->void:
	pass


func serialize(out:ChunkedFile,f:ClampFilter)->FileResult:
	_serialize_start(out,f,CLAMP_ID,CLAMP_VERSION)
	out.store_8(int(f.u_clamp_on))
	out.store_8(int(f.l_clamp_on))
	out.store_float(f.u_clamp)
	out.store_float(f.l_clamp)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()
