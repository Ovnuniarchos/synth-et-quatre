extends File
class_name ChunkedFile


const CHUNK_NEXT:String="next"
const CHUNK_ID:String="id"
const CHUNK_VERSION:String="version"
const CHUNK_POSITION:String="position"


var chunk_start:Array
var file_mode:int=File.READ
var file_version:int=0


func open(path:String,flags:int)->int:
	file_mode=flags
	return .open(path,flags)


func start_file(signature:String,version:int)->int:
	if file_mode==File.READ or file_mode==File.READ_WRITE:
		if get_ascii(8)!=signature:
			return FileResult.ERR_INVALID_TYPE
		if get_16()>version:
			return FileResult.ERR_INVALID_VERSION
		return get_error()
	else:
		store_ascii(signature,8)
		store_16(version)
	return get_error()


func start_chunk(name:String,version:int)->void:
	chunk_start.push_back(get_position())
	store_ascii(name)
	store_16(version)
	store_64(-1)


func seek(pos:int)->void:
	.seek(pos)
	if pos<0:
		breakpoint


func end_chunk()->void:
	var pos:int=get_position()
	seek(chunk_start.pop_back()+6)
	store_64(pos)
	seek(pos)


func skip_chunk(d:Dictionary)->void:
	if d.has(CHUNK_NEXT) and typeof(d[CHUNK_NEXT]) in [TYPE_INT,TYPE_REAL]:
		seek(d[CHUNK_NEXT])


func rewind_chunk(d:Dictionary)->void:
	if d.has(CHUNK_POSITION) and typeof(d[CHUNK_POSITION]) in [TYPE_INT,TYPE_REAL]:
		seek(d[CHUNK_POSITION])


func get_ascii(length:int)->String:
	return get_buffer(length).get_string_from_ascii()


func store_ascii(string:String,length:int=4)->void:
	var t0:PoolByteArray=string.to_ascii()
	var t1:PoolByteArray=PoolByteArray()
	var i:int=0
	t1.resize(length)
	while i<length and i<t0.size():
		t1[i]=t0[i]
		i+=1
	store_buffer(t1)


func get_signed_16()->int:
	var v:int=get_16()
	v=v if v<0x8000 else v|-0x10000
	return v


func get_signed_32()->int:
	var v:int=get_32()
	v=v if v<0x80000000 else v|-0x100000000
	return v


func get_chunk_header()->Dictionary:
	var pos:int=get_position()
	var hdr:Dictionary={CHUNK_POSITION:pos,CHUNK_ID:get_ascii(4),CHUNK_VERSION:get_16(),CHUNK_NEXT:get_64()}
	if hdr[CHUNK_NEXT]<-1: # Fix for a bugged chunk writer
		seek(pos)
		hdr={CHUNK_POSITION:pos,CHUNK_ID:get_ascii(4),CHUNK_VERSION:0,CHUNK_NEXT:get_64()}
		seek(pos+14)
	return hdr


func is_chunk_valid(hdr:Dictionary,id:String,version:int)->bool:
	var ret:bool=true
	if hdr[CHUNK_ID]!=id:
		invalid_chunk(hdr)
		ret=false
	if hdr[CHUNK_VERSION]>version:
		push_error(tr("ERR_FILE_BAD_CHUNK_VERSION").format(
			{"i_version":CHUNK_VERSION,"s_chunk":CHUNK_ID,"i_position":CHUNK_POSITION}
		).format(hdr))
		ret=false
	return ret


func invalid_chunk(hdr:Dictionary)->void:
	push_error(tr("ERR_FILE_BAD_CHUNK").format(
		{"s_chunk":CHUNK_ID,"i_position":CHUNK_POSITION}
	).format(hdr))


func chunk_is(hdr:Dictionary,id:String)->bool:
	return hdr[CHUNK_ID]==id


func get_chunk_id(hdr:Dictionary)->String:
	return hdr[CHUNK_ID]


func get_chunk_version(hdr:Dictionary)->int:
	return hdr[CHUNK_VERSION]
