extends WaveComponentIO
class_name SawWaveWriter


func _init(wc:Array).(wc)->void:
	pass


func serialize(out:ChunkedFile,w:SawWave)->FileResult:
	_serialize_start(out,w,SAW_ID,SAW_VERSION)
	out.store_float(w.freq_mult)
	out.store_float(w.phi0)
	out.store_8(w.quarters[0])
	out.store_8(w.quarters[1])
	out.store_8(w.quarters[2])
	out.store_8(w.quarters[3])
	out.store_float(w.cycles)
	out.store_float(w.pos0)
	out.store_float(w.pm)
	out.store_float(w.power)
	out.store_float(w.decay)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()
