extends WaveComponentIO
class_name RectangleWaveReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->WaveComponent:
	if not inf.is_chunk_valid(header,RECTANGLE_ID,RECTANGLE_VERSION):
		return null
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var w:RectangleWave=RectangleWave.new()
	_deserialize_start(inf,w,version)
	w.freq_mult=inf.get_float()
	w.phi0=inf.get_float()
	w.z_start=inf.get_float()
	w.n_start=inf.get_float()
	w.cycles=inf.get_float()
	w.pos0=inf.get_float()
	w.pm=inf.get_float()
	return w
