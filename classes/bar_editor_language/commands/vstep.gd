extends BECommand
class_name BEVStep


const NAME:String="VSTEP"
enum{
	P_OP,P_S0,P_S1,P_EASE,P_END
}
const COMMAND_LENGTH:int=4


func parse(tokens:Array,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,is_cmd,false,BEConstants.COMMANDS["VSTEP"])
	if err.has_error():
		return err
	var opcodes:Array=[]
	var next:int
	if token_type_at(tokens,3)==BEConstants.TOKEN_WHITESPACE:
		err=check_values(tokens[2])
		if err!=null:
			return err
		opcodes=[BEConstants.OP_VSTEP,
			tokens[2][BEConstants.TK_VALUE],tokens[2][BEConstants.TK_VALUE],1.0
		]
		next=3
	else:
		err=check_values(tokens[2])
		if err==null:
			err=check_values(tokens[4])
		if err!=null:
			return err
		if token_type_at(tokens,5)==BEConstants.TOKEN_WHITESPACE:
			opcodes=[BEConstants.OP_VSTEP,
				tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],1.0
			]
			next=5
		else:
			opcodes=[BEConstants.OP_VSTEP,
				tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],tokens[6][BEConstants.TK_VALUE]
			]
			next=7
	return LanguageResult.new(OK,[next,opcodes])


func check_values(token:Array)->LanguageResult:
	if token[BEConstants.TK_VALUE]<1.0:
		return LanguageResult.new(LanguageResult.ERR_MUST_BE_GE,{"n_value":1.0,
			"i_start":token[BEConstants.TK_START],"i_end":token[BEConstants.TK_END]})
	return null
