extends File
class_name ChunkedFile

const CHUNK_NEXT="next"
const CHUNK_ID="id"

var chunk_start:Array

func start_chunk(name:String)->void:
	chunk_start.push_back(get_position())
	store_64(-1)
	store_string(name)

func end_chunk()->void:
	var pos:int=get_position()
	seek(chunk_start.pop_back())
	store_64(pos)
	seek(pos)

func skip_chunk(d:Dictionary)->void:
	if d.has(CHUNK_NEXT) and typeof(d[CHUNK_NEXT]) in [TYPE_INT,TYPE_REAL]:
		seek(d[CHUNK_NEXT])

func get_ascii(length:int)->String:
	return get_buffer(length).get_string_from_ascii()

func get_chunk_header()->Dictionary:
	return {CHUNK_NEXT:get_64(),CHUNK_ID:get_ascii(4)}

func get_signed_16()->int:
	var v:int=get_16()
	v=v if v<0x8000 else v|-65536
	return v
