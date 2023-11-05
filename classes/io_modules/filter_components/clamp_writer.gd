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
	return FileResult.new(out.get_error())
