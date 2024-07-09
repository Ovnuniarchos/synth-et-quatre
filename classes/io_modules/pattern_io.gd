extends Reference
class_name PatternIO


const CHUNK_ID:String="PATR"
const CHUNK_VERSION:int=1


var _length:int


func _init(length:int=SongLimits.MAX_PAT_LENGTH)->void:
	_length=length
