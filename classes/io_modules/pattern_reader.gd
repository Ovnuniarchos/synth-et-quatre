extends PatternIO
class_name PatternReader


func _init(l:int).(l)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->Pattern:
	if not inf.is_chunk_valid(header,CHUNK_ID,CHUNK_VERSION):
		return null
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
	return pat
