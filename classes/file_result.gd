extends Reference
class_name FileResult

enum{
	ERR_INVALID_TYPE=1000,
	ERR_INVALID_VERSION,
	ERR_INVALID_CHUNK,
	ERR_MISSING_WAVES
}
const ERR_MSGS:Dictionary={
	OK:"",
	ERR_ALREADY_IN_USE:"{0} is already in use by other program.",
	ERR_FILE_CANT_OPEN:"Can't open {0}.",
	ERR_FILE_NOT_FOUND:"{0} not found.",
	ERR_FILE_UNRECOGNIZED:"Unrecognized pack format opening {0}.",
	ERR_FILE_CORRUPT:"{0} is corrupt.",
	ERR_INVALID_TYPE:"{0} is not a {1} file.",
	ERR_INVALID_VERSION:"Wrong version {1} opening {0}.",
	ERR_INVALID_CHUNK:"Invalid chunk {0} for {1}.",
	ERR_MISSING_WAVES:"Standalone instrument is missing its waveforms.",
	ERR_BUG:"This should not happen..."
}

var error:int
var error_data:Array
var data


func _init(errn:int=OK,res_data=null)->void:
	error=errn
	if errn==OK:
		data=res_data
	else:
		error_data=res_data if typeof(res_data)==TYPE_ARRAY else [res_data]


func get_message()->String:
	return ERR_MSGS[error if error in ERR_MSGS else ERR_BUG].format(error_data)


func has_error()->bool:
	return error!=OK
