extends File
class_name ChunkedFile

const CHUNK_NEXT:String="next"
const CHUNK_ID:String="id"
const CHUNK_VERSION:String="version"
const ERR_INVALID_TYPE:int=-1
const ERR_INVALID_VERSION:int=-2

var chunk_start:Array
var file_mode:int=File.READ
var file_version:int=0

func open(path:String,flags:int)->int:
	file_mode=flags
	return .open(path,flags)

func start_file(signature:String,version:int)->int:
	if file_mode==File.READ or file_mode==File.READ_WRITE:
		if get_ascii(8)!=signature:
			return ERR_INVALID_TYPE
		if get_16()>version:
			return ERR_INVALID_VERSION
		return get_error()
	else:
		store_string((signature+"\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000").left(8))
		store_16(version)
	return get_error()

func start_chunk(name:String,version:int)->void:
	chunk_start.push_back(get_position())
	store_string((name+"\u0000\u0000\u0000\u0000").left(4))
	store_16(version)
	store_64(-1)

func end_chunk()->void:
	var pos:int=get_position()
	seek(chunk_start.pop_back()+6)
	store_64(pos)
	seek(pos)

func skip_chunk(d:Dictionary)->void:
	if d.has(CHUNK_NEXT) and typeof(d[CHUNK_NEXT]) in [TYPE_INT,TYPE_REAL]:
		seek(d[CHUNK_NEXT])

func get_ascii(length:int)->String:
	return get_buffer(length).get_string_from_ascii()

func get_chunk_header()->Dictionary:
	return {CHUNK_ID:get_ascii(4),CHUNK_VERSION:get_16(),CHUNK_NEXT:get_64()}

func get_signed_16()->int:
	var v:int=get_16()
	v=v if v<0x8000 else v|-65536
	return v
