extends Reference
class_name Pattern

enum LEGATO_MODE{OFF,LEGATO,STACCATO}
enum ATTRS{LG_MODE,NOTE,INSTR,VOL,PAN,FX0,FM0,FV0,FX1,FM1,FV1,FX2,FM2,FV2,FX3,FM3,FV3}
const MIN_FX_COL:int=ATTRS.FX0
const MAX_ATTR:int=ATTRS.FV3
const MIN_FX:int=0
const MAX_FX:int=4
const LEGATO_MIN:int=LEGATO_MODE.OFF
const LEGATO_MAX:int=LEGATO_MODE.STACCATO
const CHUNK_ID:String="PATR"

var notes:Array=[]

func _init(length:int)->void:
	notes.resize(length)
	for i in range(length):
		notes[i]=[]
		notes[i].resize(MAX_ATTR+1)

func duplicate()->Pattern:
	var np:Pattern=get_script().new(notes.size())
	for i in range(notes.size()):
		np.notes[i]=notes[i].duplicate(true)
	return np

func is_note_empty(ix:int,num_fx:int)->bool:
	var n:Array=notes[ix]
	var lgm=n[ATTRS.LG_MODE]
	if lgm!=null and lgm!=LEGATO_MODE.OFF:
		return false
	for i in range(ATTRS.NOTE,MIN_FX_COL+(num_fx*2)):
		if n[i]!=null:
			return false
	return true
	
func remove_row(row:int)->void:
	if row<0 or row>=notes.size():
		return
	notes.remove(row)
	var a:Array=[]
	a.resize(MAX_ATTR+1)
	notes.append(a)

func insert_row(row:int)->void:
	if row<0 or row>=notes.size():
		return
	var a:Array=[]
	a.resize(MAX_ATTR+1)
	notes.insert(row,a)
	notes.pop_back()

#

func serialize(out:ChunkedFile,length:int,num_fx:int)->void:
	out.start_chunk(CHUNK_ID,0)
	for j in range(length):
		var n=notes[j]
		var mask:int=0
		if n[ATTRS.LG_MODE]!=null and n[ATTRS.LG_MODE]!=LEGATO_MODE.OFF:
			mask|=1
		for i in range(ATTRS.NOTE,MIN_FX_COL+(num_fx*3)):
			if i in [ATTRS.FM0,ATTRS.FM1,ATTRS.FM2,ATTRS.FM3]:
				if n[i]!=null and n[i]!=0:
					mask|=1<<i
			elif n[i]!=null:
				mask|=1<<i
		out.store_32(mask)
		for i in range(MAX_ATTR):
			if mask&(1<<i):
				out.store_8(n[i])
	out.end_chunk()

#

func deserialize(inf:ChunkedFile,pat:Pattern,length:int)->void:
	inf.get_chunk_header()
	for j in range(length):
		var n:Array=pat.notes[j]
		var mask:int=inf.get_32()
		for i in range(MAX_ATTR):
			if mask&(1<<i):
				n[i]=inf.get_8()
		if n[ATTRS.NOTE]==255:
			n[ATTRS.NOTE]=-1
		elif n[ATTRS.NOTE]==254:
			n[ATTRS.NOTE]=-2
