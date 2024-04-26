extends Result
class_name LanguageResult

enum{
	ERR_INVALID_CHARACTER=1000,
	ERR_INVALID_NUMBER,
	ERR_VALUE_EXPECTED,
	ERR_WHITESPACE_EXPECTED,
	ERR_COMMAND_EXPECTED,
	ERR_BAD_COMMAND,
	ERR_UNEXPECTED_TOKEN,
	ERR_UNEXPECTED_EOL,
	ERR_MISSING_PARAMS,
	ERR_DUPLICATED_MOD,
}


func _init(errn:int=OK,res_data=null).(errn,res_data)->void:
	ERR_MSGS.merge({
		ERR_INVALID_CHARACTER:"ERR_INVALID_CHARACTER",
		ERR_INVALID_NUMBER:"ERR_INVALID_NUMBER",
		ERR_VALUE_EXPECTED:"ERR_VALUE_EXPECTED",
		ERR_WHITESPACE_EXPECTED:"ERR_WHITESPACE_EXPECTED",
		ERR_COMMAND_EXPECTED:"ERR_COMMAND_EXPECTED",
		ERR_BAD_COMMAND:"ERR_BAD_COMMAND",
		ERR_UNEXPECTED_TOKEN:"ERR_UNEXPECTED_TOKEN",
		ERR_UNEXPECTED_EOL:"ERR_UNEXPECTED_EOL",
		ERR_MISSING_PARAMS:"ERR_MISSING_PARAMS",
		ERR_DUPLICATED_MOD:"ERR_DUPLICATED_MOD",
	})


func pos2index(index:int,text:String)->int:
	if index>0:
		index-=1
	elif index<0:
		index=max(0,text.length()+index)
	return index


func get_error_start()->int:
	return pos2index(error_data["i_start"],error_data["text"])


func get_error_end()->int:
	return pos2index(error_data["i_end"],error_data["text"])
