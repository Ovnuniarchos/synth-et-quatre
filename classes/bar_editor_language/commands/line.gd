extends BECommand
class_name BELine


const NAME:String="LINE"


func parse(tokens:Array,from:int,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,from,is_cmd,true,BEConstants.COMMANDS["LINE"])
	if err.has_error():
		return err
	var opcodes:Array=[]
	if token_type_at(tokens,from+7)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_INTERPOLATE,
			tokens[from+2][BEConstants.TK_VALUE],tokens[from+4][BEConstants.TK_VALUE],
			tokens[from+6][BEConstants.TK_VALUE],tokens[from+6][BEConstants.TK_VALUE],
			1.0
		]
		from+=7
	elif token_type_at(tokens,9)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_INTERPOLATE,
			tokens[from+2][BEConstants.TK_VALUE],tokens[from+6][BEConstants.TK_VALUE],
			tokens[from+4][BEConstants.TK_VALUE],tokens[from+8][BEConstants.TK_VALUE],
			1.0
		]
		from+=9
	else:
		opcodes=[BEConstants.OP_INTERPOLATE,
			tokens[from+2][BEConstants.TK_VALUE],tokens[from+6][BEConstants.TK_VALUE],
			tokens[from+4][BEConstants.TK_VALUE],tokens[from+8][BEConstants.TK_VALUE],
			tokens[from+10][BEConstants.TK_VALUE]
		]
		from+=11
	var has_mod:Dictionary={}
	while from<tokens.size():
		if tokens[from][BEConstants.TK_TYPE]==BEConstants.TOKEN_WHITESPACE:
			from+=1
		elif tokens[from][BEConstants.TK_TYPE] in [BEConstants.TOKEN_CMD_ALPHA,BEConstants.TOKEN_CMD_EASE]:
			if tokens[from][BEConstants.TK_TYPE] in has_mod:
				return LanguageResult.new(LanguageResult.ERR_DUPLICATED_MOD,
					{"s_token":tokens[from][BEConstants.TK_VALUE].NAME,"i_start":tokens[from][BEConstants.TK_START],"i_end":tokens[from][BEConstants.TK_END]}
				)
			err=tokens[from][BEConstants.TK_VALUE].parse(tokens,from,false)
			if err.has_error():
				return err
			has_mod[tokens[from][BEConstants.TK_TYPE]]=true
			from=err.data[0]
			opcodes.append_array(err.data[1])
		else:
			break
	return LanguageResult.new(OK,[from,opcodes])

