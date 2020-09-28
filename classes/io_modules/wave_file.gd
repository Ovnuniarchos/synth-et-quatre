extends File
class_name WaveFile

const ERR_FILE_NOT_OPEN:int=-1
const ERR_UNRECOGNIZED_ERROR:int=-2
const ERR_MESSAGES={
	ERR_FILE_NOT_FOUND:"File %s not found.",
	ERR_FILE_BAD_DRIVE:"Bad drive trying to write %s.",
	ERR_FILE_BAD_PATH:"Bad path %s.",
	ERR_FILE_NO_PERMISSION:"No permission to access %s.",
	ERR_FILE_ALREADY_IN_USE:"File %s is already in use.",
	ERR_FILE_CANT_OPEN:"Can't open %s.'",
	ERR_FILE_CANT_WRITE:"Can't write %s.",
	ERR_FILE_CANT_READ:"Can't read %s.'",
	ERR_FILE_UNRECOGNIZED:"Unrecognized file type %s",
	ERR_FILE_CORRUPT:"File %s is corrupt.",
	ERR_FILE_MISSING_DEPENDENCIES:"File %s is missing dependencies.",
	ERR_FILE_EOF:"EOF met in file %s.",
	ERR_FILE_NOT_OPEN:"File %s is not open.",
	ERR_UNRECOGNIZED_ERROR:"Unknown error %d."
}

var float_samples:bool
var block_bytes:int
var data_size:int

func start_file(path:String,fp_samples:bool,sample_rate:int)->int:
	var err:int=open(path,WRITE)
	if err!=OK:
		return err
	float_samples=fp_samples
	block_bytes=2*(4 if float_samples else 2)
	store_string("RIFF")
	store_32(0)
	store_string("WAVE")
	store_string("fmt ")
	store_32(16)
	store_16(3 if float_samples else 1)
	store_16(2)
	store_32(sample_rate)
	store_32(sample_rate*block_bytes)
	store_16(block_bytes)
	store_16(32 if float_samples else 16)
	store_string("data")
	store_32(0)
	data_size=0
	err=get_error()
	if err!=OK:
		close()
		return err
	return OK

func write_chunk(data:Array)->int:
	if !is_open():
		return ERR_FILE_NOT_OPEN
	for block in data:
		if float_samples:
			store_float(block.x)
			store_float(block.y)
			data_size+=8
		else:
			store_16(clamp(block.x,-1.0,1.0)*32767)
			store_16(clamp(block.y,-1.0,1.0)*32767)
			data_size+=4
	var err:int=get_error()
	if err!=OK:
		close()
		return err
	return OK

func end_file()->int:
	if !is_open():
		return ERR_FILE_NOT_OPEN
	seek(4)
	var err:int=get_error()
	if err!=OK:
		close()
		return err
	store_32(36+data_size)
	err=get_error()
	if err!=OK:
		close()
		return err
	seek(40)
	err=get_error()
	if err!=OK:
		close()
		return err
	store_32(data_size)
	err=get_error()
	if err!=OK:
		close()
		return err
	close()
	err=get_error()
	if err!=OK:
		return err
	return OK

#

func obj_load(path:String)->Dictionary:
	var err:int=open(path,READ)
	if err!=OK:
		return {"error":err}
	var wave:Dictionary=do_load()
	close()
	return wave
	

func do_load()->Dictionary:
	if get_buffer(4).get_string_from_ascii()!="RIFF":
		return {"error":ERR_FILE_UNRECOGNIZED}
	get_32()
	if get_buffer(4).get_string_from_ascii()!="WAVE":
		return {"error":ERR_FILE_UNRECOGNIZED}
	var chunk_id:String
	var size:int
	var pos:int
	var mode:int
	var channels:int
	var frequency:int
	var bits_sample:int
	var format:bool=false
	var data:Array=[]
	while !eof_reached():
		chunk_id=get_buffer(4).get_string_from_ascii()
		size=get_32()
		pos=get_position()
		if chunk_id=="fmt ":
			mode=get_16()
			channels=get_16()
			frequency=get_32()
			get_32()
			get_16()
			bits_sample=get_16()
			if (mode!=1 and mode !=3) or (channels<1 and channels>2)\
					or !bits_sample in [8,16,24,32]:
				return {"error":0}
			format=true
		elif chunk_id=="data":
			if !format:
				return {"error":0}
			size/=channels*(bits_sample>>3)
			while size>0:
				size-=1
				if eof_reached():
					break
				if channels==1:
					data.append(get_sample(bits_sample))
				else:
					data.append((get_sample(bits_sample)+get_sample(bits_sample))/2)
		else:
			seek(pos+size)
	return {"error":OK,"bits":bits_sample,"freq":frequency,"data":data}

func get_sample(bits_sample:int):
	var t:int
	if bits_sample==8:
		return get_8()-0x80
	elif bits_sample==16:
		t=get_16()
		return t if t<0x8000 else t-0x10000
	elif bits_sample==32:
		return get_float()
	t=(get_8()<<16)|get_16()
	return t if t<0x800000 else t-0x1000000

#

func get_error_message(err:int)->String:
	if err in ERR_MESSAGES:
		return ERR_MESSAGES[err]%[get_path(),err]
	return ERR_MESSAGES[ERR_UNRECOGNIZED_ERROR]