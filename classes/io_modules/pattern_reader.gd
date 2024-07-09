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
	var version:int=inf.get_chunk_version(header)
	var pat:Pattern=Pattern.new()
	for j in _length:
		var row:Array=pat.notes[j]
		var mask:int=inf.get_32()
		for i in Pattern.ATTRS.MAX:
			if mask&(1<<i):
				row[i]=inf.get_8()
		if row[Pattern.ATTRS.NOTE]==255:
			row[Pattern.ATTRS.NOTE]=-1
		elif row[Pattern.ATTRS.NOTE]==254:
			row[Pattern.ATTRS.NOTE]=-2
		if version==0:
			convert_from_v0(row)
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new(OK,pat)


func convert_from_v0(row:Array)->void:
	if row[Pattern.ATTRS.PAN]==null:
		return
	var pan:int=int(range_lerp(row[Pattern.ATTRS.PAN]&0x1F,0,63,0,255))
	var chi:int=row[Pattern.ATTRS.PAN]>>6
	row[Pattern.ATTRS.PAN]=pan
	row[Pattern.ATTRS.INVL]=chi&1
	row[Pattern.ATTRS.INVR]=chi&2
