extends PatternIO
class_name PatternReader


const ATTRS=Pattern.ATTRS


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
		for i in ATTRS.MAX:
			if mask&(1<<i):
				row[convert_col_number(i,version)]=inf.get_8()
		if row[ATTRS.NOTE]==255:
			row[ATTRS.NOTE]=-1
		elif row[ATTRS.NOTE]==254:
			row[ATTRS.NOTE]=-2
		if version==0:
			convert_from_v0(row)
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new(OK,pat)


func convert_col_number(col:int,version:int)->int:
	if version==0:
		if col>=ATTRS.INVL:
			return col+2
	return col


func convert_from_v0(row:Array)->void:
	if row[ATTRS.PAN]==null:
		return
	var pan:int=int(range_lerp(row[ATTRS.PAN]&0x3F,0,63,0,255))
	var chi:int=row[ATTRS.PAN]>>6
	row[ATTRS.PAN]=pan
	row[ATTRS.INVL]=chi&1
	row[ATTRS.INVR]=chi&2
