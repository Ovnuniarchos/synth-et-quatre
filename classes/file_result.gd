extends Reference
class_name FileResult

enum{
	ERR_INVALID_TYPE=1000,
	ERR_INVALID_VERSION,
	ERR_INVALID_CHUNK,
	ERR_MISSING_WAVES,
	ERR_BAD_WAVE_COMPONENT,
	ERR_BAD_WAVE_COMPONENT_OUT,
	ERR_INVALID_WAVE_TYPE,
	ERR_INVALID_MACRO
}
const ERR_MSGS:Dictionary={
	OK:"",
	ERR_FILE_BAD_DRIVE:"Bad drive trying to write {file}.",
	ERR_FILE_BAD_PATH:"Bad path opening {file}.",
	ERR_FILE_NO_PERMISSION:"No permission to access {file}.",
	ERR_FILE_ALREADY_IN_USE:"File {file} is already in use.",
	ERR_FILE_CANT_WRITE:"Can't write to {file}.",
	ERR_FILE_CANT_READ:"Can't read {file}.'",
	ERR_FILE_MISSING_DEPENDENCIES:"{file} is missing dependencies.",
	ERR_FILE_EOF:"Unexpected EOF in {file}.",
	ERR_ALREADY_IN_USE:"{file} is already in use by other program.",
	ERR_FILE_CANT_OPEN:"Can't open {file}.",
	ERR_FILE_NOT_FOUND:"{file} not found.",
	ERR_FILE_UNRECOGNIZED:"Unrecognized pack format opening {file}.",
	ERR_FILE_CORRUPT:"{file} is corrupt.",
	ERR_INVALID_TYPE:"{file} is not a {type} file.",
	ERR_INVALID_VERSION:"Wrong version {version} opening {file}.",
	ERR_INVALID_CHUNK:"Invalid chunk {chunk}:{version} for {file}. Expected {ex_chunk}:{ex_version}.",
	ERR_MISSING_WAVES:"Standalone instrument is missing its waveforms.",
	ERR_BAD_WAVE_COMPONENT:"Invalid wave component type {chunk} in file {file}.",
	ERR_BAD_WAVE_COMPONENT_OUT:"Invalid wave component type {type} writing {file}.",
	ERR_INVALID_WAVE_TYPE:"Invalid wave type {type} writing {file}.",
	ERR_INVALID_MACRO:"Invalid macro type/operator {type}/{op} in file {file}.",
	ERR_BUG:"This should not happen..."
}

var error:int
var error_data:Dictionary
var data


func _init(errn:int=OK,res_data=null)->void:
	error=errn
	if errn==OK:
		data=res_data
		error_data={}
	else:
		error_data=res_data
		data=null


func get_message()->String:
	return ERR_MSGS[error if error in ERR_MSGS else ERR_BUG].format(error_data)


func has_error()->bool:
	return error!=OK
