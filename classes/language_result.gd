extends Result
class_name LanguageResult

enum{
	ERR_INVALID_CHARACTER=1000,
	ERR_INVALID_NUMBER,
	ERR_VALUE_EXPECTED,
	ERR_WHITESPACE_EXPECTED,
	ERR_BAD_START,
	ERR_BAD_COMMAND,
	ERR_UNEXPECTED_TOKEN,
	ERR_UNEXPECTED_EOL
}


func _init(errn:int=OK,res_data=null).(errn,res_data)->void:
	ERR_MSGS.merge({
		ERR_INVALID_CHARACTER:"Invalid character [{char}] at position {start}.",
		ERR_INVALID_NUMBER:"Invalid number at position {start}.",
		ERR_VALUE_EXPECTED:"Value expected at position {start}.",
		ERR_WHITESPACE_EXPECTED:"Space expected at position {start}",
		ERR_BAD_START:"Lines must start with a command.",
		ERR_BAD_COMMAND:"Unrecognized command {command}.",
		ERR_UNEXPECTED_TOKEN:"Unexpected {token} at position {start}.",
		ERR_UNEXPECTED_EOL:"Unexpected end of line."
	})
