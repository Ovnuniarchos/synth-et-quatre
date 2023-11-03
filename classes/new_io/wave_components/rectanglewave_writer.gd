extends WaveComponentIO
class_name RectangleWaveWriter


func _init(wc:Array).(wc)->void:
	pass


func serialize(out:ChunkedFile,w:RectangleWave)->FileResult:
	_serialize_start(out,w,RECTANGLE_ID,RECTANGLE_VERSION)
	out.store_float(w.freq_mult)
	out.store_float(w.phi0)
	out.store_float(w.z_start)
	out.store_float(w.n_start)
	out.store_float(w.cycles)
	out.store_float(w.pos0)
	out.store_float(w.pm)
	out.end_chunk()
	return FileResult.new(out.get_error())
