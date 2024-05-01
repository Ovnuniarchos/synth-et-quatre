extends BECommand
class_name BEEase


const NAME:String="EASE"


func parse(tokens:Array,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,is_cmd,false,BEConstants.COMMANDS["EASE"])
	if err.has_error():
		return err
	var opcodes:Array=[]
	var next:int
	if token_type_at(tokens,3)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_EASE,
			tokens[2][BEConstants.TK_VALUE],tokens[2][BEConstants.TK_VALUE],1.0
		]
		next=3
	elif token_type_at(tokens,5)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_EASE,
			tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],1.0
		]
		next=5
	else:
		opcodes=[BEConstants.OP_EASE,
			tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],tokens[6][BEConstants.TK_VALUE]
		]
		next=7
	return LanguageResult.new(OK,[next,opcodes])
