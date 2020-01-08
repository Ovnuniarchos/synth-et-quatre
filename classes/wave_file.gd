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

func get_error_message(err:int)->String:
	if err in ERR_MESSAGES:
		return ERR_MESSAGES[err]%[get_path(),err]
	return ERR_MESSAGES[ERR_UNRECOGNIZED_ERROR]
