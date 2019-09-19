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

func get_ascii(length:int)->String:
	return get_buffer(length).get_string_from_ascii()

func get_chunk_header()->Dictionary:
	return {CHUNK_NEXT:get_64(),CHUNK_ID:get_ascii(4)}
