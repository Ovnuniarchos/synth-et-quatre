extends WaveComponentIO
class_name QuantizeFilterReader


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->WaveComponent:
	if not inf.is_chunk_valid(header,NORMALIZE_ID,NORMALIZE_VERSION):
		return null
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var f:QuantizeFilter=QuantizeFilter.new()
	_deserialize_start(inf,f,version)
	f.steps=bool(inf.get_8())
	return f
