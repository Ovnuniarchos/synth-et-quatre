extends Reference
class_name Pattern

const SONGL=preload("res://classes/song/song_limits.gd")
enum LEGATO_MODE{OFF,LEGATO,STACCATO}
enum ATTRS{LG_MODE,NOTE,INSTR,VOL,PAN,FX0,FM0,FV0,FX1,FM1,FV1,FX2,FM2,FV2,FX3,FM3,FV3,MAX}
const MIN_FX_COL:int=ATTRS.FX0
const MAX_ATTR:int=ATTRS.FV3
const MIN_FX:int=0
const MAX_FX:int=4
const LEGATO_MIN:int=LEGATO_MODE.OFF
const LEGATO_MAX:int=LEGATO_MODE.STACCATO

var notes:Array=[]

func _init(length:int=SONGL.MAX_PAT_LENGTH)->void:
	notes.resize(length)
	for i in length:
		notes[i]=[]
		notes[i].resize(ATTRS.MAX)

func duplicate()->Pattern:
	var np:Pattern=get_script().new(notes.size())
	for i in notes.size():
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
	a.resize(ATTRS.MAX)
	notes.append(a)

func insert_row(row:int)->void:
	if row<0 or row>=notes.size():
		return
	var a:Array=[]
	a.resize(ATTRS.MAX)
	notes.insert(row,a)
	notes.pop_back()
