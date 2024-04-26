extends BECommand
class_name BEHStep


const NAME:String="HSTEP"


func parse(tokens:Array,from:int,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,from,is_cmd,false,BEConstants.COMMANDS["HSTEP"])
	if err.has_error():
		return err
	var opcodes:Array=[]
	if token_type_at(tokens,from+3)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_HSTEP,
			tokens[from+2][BEConstants.TK_VALUE],tokens[from+2][BEConstants.TK_VALUE],1.0
		]
		from+=3
	elif token_type_at(tokens,from+5)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_HSTEP,
			tokens[from+2][BEConstants.TK_VALUE],tokens[from+4][BEConstants.TK_VALUE],1.0
		]
		from+=5
	else:
		opcodes=[BEConstants.OP_HSTEP,
			tokens[from+2][BEConstants.TK_VALUE],tokens[from+4][BEConstants.TK_VALUE],tokens[from+6][BEConstants.TK_VALUE]
		]
		from+=7
	return LanguageResult.new(OK,[from,opcodes])
