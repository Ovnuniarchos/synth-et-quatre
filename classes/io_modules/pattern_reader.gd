extends PatternIO
class_name PatternReader


func _init(l:int).(l)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,CHUNK_ID,CHUNK_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:CHUNK_ID,
			FileResult.ERRV_EXP_VERSION:CHUNK_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var pat:Pattern=Pattern.new()
	for j in _length:
		var n:Array=pat.notes[j]
		var mask:int=inf.get_32()
		for i in Pattern.ATTRS.MAX:
			if mask&(1<<i):
				n[i]=inf.get_8()
		if n[Pattern.ATTRS.NOTE]==255:
			n[Pattern.ATTRS.NOTE]=-1
		elif n[Pattern.ATTRS.NOTE]==254:
			n[Pattern.ATTRS.NOTE]=-2
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new(OK,pat)
