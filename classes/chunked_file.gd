extends File
class_name ChunkedFile

const CHUNK_NEXT="next"
const CHUNK_ID="id"
const CHUNK_VERSION="version"

var chunk_start:Array

func start_chunk(name:String,version:int)->void:
	chunk_start.push_back(get_position())
	store_string((name+"\u0000\u0000\u0000\u0000").left(4))
	store_16(version)
	store_64(-1)

func end_chunk()->void:
	var pos:int=get_position()
	seek(chunk_start.pop_back()+4)
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
