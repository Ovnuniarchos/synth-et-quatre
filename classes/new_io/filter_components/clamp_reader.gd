extends WaveComponentIO
class_name ClampFilterReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->WaveComponent:
	if not inf.is_chunk_valid(header,CLAMP_ID,CLAMP_VERSION):
		return null
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var f:ClampFilter=ClampFilter.new()
	_deserialize_start(inf,f,version)
	f.u_clamp_on=bool(inf.get_8())
	f.l_clamp_on=bool(inf.get_8())
	f.u_clamp=inf.get_float()
	f.l_clamp=inf.get_float()
	return f
