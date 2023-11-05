extends PatternIO
class_name PatternWriter


func _init(l:int).(l)->void:
	pass


func serialize(out:ChunkedFile,pat:Pattern,num_fx:int)->void:
	out.start_chunk(CHUNK_ID,CHUNK_VERSION)
	for j in _length:
		var n=pat.notes[j]
		var mask:int=0
		if n[Pattern.ATTRS.LG_MODE]!=null and n[Pattern.ATTRS.LG_MODE]!=Pattern.LEGATO_MODE.OFF:
			mask|=1
		for i in range(Pattern.ATTRS.NOTE,Pattern.ATTRS.FX0+(num_fx*3)):
			if i in [Pattern.ATTRS.FM0,Pattern.ATTRS.FM1,Pattern.ATTRS.FM2,Pattern.ATTRS.FM3]:
				if n[i]!=null and n[i]!=0:
					mask|=1<<i
			elif n[i]!=null:
				mask|=1<<i
		out.store_32(mask)
		for i in Pattern.ATTRS.MAX:
			if mask&(1<<i):
				out.store_8(n[i])
	out.end_chunk()
