extends Result
class_name FileResult

const ERRV_FILE:String="s_file"
const ERRV_TYPE:String="s_type"
const ERRV_VERSION:String="i_version"
const ERRV_EXP_VERSION:String="i_ex_version"
const ERRV_CHUNK:String="s_chunk"
const ERRV_EXP_CHUNK:String="s_ex_chunk"
const ERRV_OP:String="i_op"
const ERRV_COMPONENT:String="s_component"


enum{
	ERR_INVALID_TYPE=1000,
	ERR_INVALID_VERSION,
	ERR_INVALID_CHUNK,
	ERR_MISSING_WAVES,
	ERR_BAD_WAVE_COMPONENT,
	ERR_BAD_WAVE_COMPONENT_OUT,
	ERR_INVALID_WAVE_TYPE,
	ERR_INVALID_INPUT_SLOT,
	ERR_INVALID_MACRO,
	ERR_SONG_MAX_WAVES,
	ERR_SONG_MAX_INSTRUMENTS,
	ERR_SONG_MAX_ARPS,
}


func _init(errn:int=OK,res_data=null).(errn,res_data)->void:
	ERR_MSGS.merge({
		ERR_FILE_BAD_DRIVE:"ERR_FILE_BAD_DRIVE",
		ERR_FILE_BAD_PATH:"ERR_FILE_BAD_PATH",
		ERR_FILE_NO_PERMISSION:"ERR_FILE_NO_PERMISSION",
		ERR_FILE_ALREADY_IN_USE:"ERR_FILE_ALREADY_IN_USE",
		ERR_FILE_CANT_WRITE:"ERR_FILE_CANT_WRITE",
		ERR_FILE_CANT_READ:"ERR_FILE_CANT_READ",
		ERR_FILE_MISSING_DEPENDENCIES:"ERR_FILE_MISSING_DEPENDENCIES",
		ERR_FILE_EOF:"ERR_FILE_EOF",
		ERR_ALREADY_IN_USE:"ERR_ALREADY_IN_USE",
		ERR_FILE_CANT_OPEN:"ERR_FILE_CANT_OPEN",
		ERR_FILE_NOT_FOUND:"ERR_FILE_NOT_FOUND",
		ERR_FILE_UNRECOGNIZED:"ERR_FILE_UNRECOGNIZED",
		ERR_FILE_CORRUPT:"ERR_FILE_CORRUPT",
		ERR_INVALID_TYPE:"ERR_INVALID_TYPE",
		ERR_INVALID_VERSION:"ERR_INVALID_VERSION",
		ERR_INVALID_CHUNK:"ERR_INVALID_CHUNK",
		ERR_MISSING_WAVES:"ERR_MISSING_WAVES",
		ERR_BAD_WAVE_COMPONENT:"ERR_BAD_WAVE_COMPONENT",
		ERR_BAD_WAVE_COMPONENT_OUT:"ERR_BAD_WAVE_COMPONENT_OUT",
		ERR_INVALID_WAVE_TYPE:"ERR_INVALID_WAVE_TYPE",
		ERR_INVALID_INPUT_SLOT:"ERR_INVALID_INPUT_SLOT",
		ERR_INVALID_MACRO:"ERR_INVALID_MACRO",
		ERR_SONG_MAX_WAVES:"ERR_SONG_MAX_WAVES",
		ERR_SONG_MAX_INSTRUMENTS:"ERR_SONG_MAX_INSTRUMENTS",
		ERR_SONG_MAX_ARPS:"ERR_SONG_MAX_ARPS",
	})
