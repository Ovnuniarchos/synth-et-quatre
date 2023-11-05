extends WaveComponentIO
class_name TriangleWaveReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->WaveComponent:
	if not inf.is_chunk_valid(header,TRIANGLE_ID,TRIANGLE_VERSION):
		return null
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var w:TriangleWave=TriangleWave.new()
	_deserialize_start(inf,w,version)
	w.freq_mult=inf.get_float()
	w.phi0=inf.get_float()
	w.halves[0]=inf.get_8()
	w.halves[1]=inf.get_8()
	w.cycles=inf.get_float()
	w.pos0=inf.get_float()
	w.pm=inf.get_float()
	return w
