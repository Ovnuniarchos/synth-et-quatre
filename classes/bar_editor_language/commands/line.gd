extends BECommand
class_name BELine


const NAME:String="LINE"


func parse(tokens:Array,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,is_cmd,true,BEConstants.COMMANDS["LINE"])
	if err.has_error():
		return err
	var opcodes:Array=[]
	var next:int
	if token_type_at(tokens,7)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_INTERPOLATE,
			tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],
			tokens[6][BEConstants.TK_VALUE],tokens[6][BEConstants.TK_VALUE],
			1.0
		]
		next=7
	elif token_type_at(tokens,9)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_INTERPOLATE,
			tokens[2][BEConstants.TK_VALUE],tokens[6][BEConstants.TK_VALUE],
			tokens[4][BEConstants.TK_VALUE],tokens[8][BEConstants.TK_VALUE],
			1.0
		]
		next=9
	else:
		opcodes=[BEConstants.OP_INTERPOLATE,
			tokens[2][BEConstants.TK_VALUE],tokens[6][BEConstants.TK_VALUE],
			tokens[4][BEConstants.TK_VALUE],tokens[8][BEConstants.TK_VALUE],
			tokens[10][BEConstants.TK_VALUE]
		]
		next=11
	var has_mod:Dictionary={}
	while next<tokens.size():
		if tokens[next][BEConstants.TK_TYPE]==BEConstants.TOKEN_WHITESPACE:
			next+=1
		elif tokens[next][BEConstants.TK_TYPE] in [BEConstants.TOKEN_CMD_ALPHA,BEConstants.TOKEN_CMD_EASE]:
			if tokens[next][BEConstants.TK_TYPE] in has_mod:
				return LanguageResult.new(LanguageResult.ERR_DUPLICATED_MOD,
					{"s_token":tokens[next][BEConstants.TK_VALUE].NAME,"i_start":tokens[next][BEConstants.TK_START],"i_end":tokens[next][BEConstants.TK_END]}
				)
			err=tokens[next][BEConstants.TK_VALUE].parse(tokens.slice(next,-1),false)
			if err.has_error():
				return err
			has_mod[tokens[next][BEConstants.TK_TYPE]]=true
			next+=err.data[0]
			opcodes.append_array(err.data[1])
		else:
			break
	return LanguageResult.new(OK,[next,opcodes])

