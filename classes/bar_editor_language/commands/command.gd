extends Reference
class_name BECommand


func token_type_at(tokens:Array,at:int)->int:
	return tokens[at][BEConstants.TK_TYPE] if tokens.size()>at else BEConstants.TOKEN_WHITESPACE


func token_error_string(token:Array)->String:
	if token[BEConstants.TK_TYPE]<BEConstants.TOKEN_CMD_LINE:
		return tr(BEConstants.TOKEN_NAMES[token[BEConstants.TK_TYPE]])
	return tr(BEConstants.TOKEN_NAMES[BEConstants.TOKEN_CMD_LINE])


func find_invalid_tokens(tokens:Array,cmd_data:Array)->int:
	if tokens.size()<cmd_data[BEConstants.CMD_MIN_TOKENS]:
		return tokens.size()
	var types:Array=cmd_data[BEConstants.CMD_PARAMS]
	var j:int=0
	for i in types.size():
		if types[i]==BEConstants.TOKEN_OPTIONAL:
			if j>=tokens.size() or tokens[j][BEConstants.TK_TYPE]==BEConstants.TOKEN_WHITESPACE:
				return -1
			continue
		if j>=tokens.size():
			return tokens.size()
		if tokens[j][BEConstants.TK_TYPE]!=types[i]:
			return j
		j+=1
	return -1


func common_checks(tokens:Array,is_cmd:bool,expected_cmd:bool,command:Array)->LanguageResult:
	if is_cmd!=expected_cmd:
		return LanguageResult.new(LanguageResult.ERR_UNEXPECTED_TOKEN,{"s_token":token_error_string(tokens[0]),"i_start":tokens[0][BEConstants.TK_START]})
	var end:int=tokens[-1][BEConstants.TK_END]+1 if tokens[-1][BEConstants.TK_END]>-1 else -1
	if command[BEConstants.CMD_MIN_TOKENS]>tokens.size():
		return LanguageResult.new(LanguageResult.ERR_UNEXPECTED_EOL,{"i_start":end,"i_end":end})
	var token:Array=tokens[1]
	var type:int=token[BEConstants.TK_TYPE]
	var start:int=token[BEConstants.TK_START]
	end=token[BEConstants.TK_END]+1 if token[BEConstants.TK_END]>-1 else -1
	if type!=BEConstants.TOKEN_WHITESPACE:
		return LanguageResult.new(
			LanguageResult.ERR_WHITESPACE_EXPECTED,
			{"i_start":start,"i_end":start}
		)
	var itoken_pos:int=find_invalid_tokens(tokens,command)
	if itoken_pos==tokens.size():
		return LanguageResult.new(LanguageResult.ERR_MISSING_PARAMS,{"i_start":tokens[0][BEConstants.TK_START],"i_end":-1})
	elif itoken_pos>-1:
		token=tokens[itoken_pos]
		type=token[BEConstants.TK_TYPE]
		start=token[BEConstants.TK_START]
		end=token[BEConstants.TK_END]+1 if token[BEConstants.TK_END]>-1 else -1
		return LanguageResult.new(
			LanguageResult.ERR_UNEXPECTED_TOKEN,
			{"s_token":token_error_string(token),"i_start":start,"i_end":end}
		)
	return LanguageResult.new()


func parse(tokens:Array,is_cmd:bool)->LanguageResult:
	return LanguageResult.new(LanguageResult.ERR_UNIMPLEMENTED_PARSER,{"s_command":get("NAME")})


func parse_modifiers(tokens:Array,opcodes:Array,next:int)->LanguageResult:
	var name:String=get("NAME")
	var has_mod:Dictionary={}
	while next<tokens.size():
		if tokens[next][BEConstants.TK_TYPE]==BEConstants.TOKEN_WHITESPACE:
			next+=1
		elif tokens[next][BEConstants.TK_TYPE] in BEConstants.COMMANDS[name][BEConstants.CMD_MODIFIERS]:
			if tokens[next][BEConstants.TK_TYPE] in has_mod:
				return LanguageResult.new(LanguageResult.ERR_DUPLICATED_MOD,
					{"s_token":tokens[next][BEConstants.TK_VALUE].NAME,"i_start":tokens[next][BEConstants.TK_START],"i_end":tokens[next][BEConstants.TK_END]}
				)
			var err:LanguageResult=tokens[next][BEConstants.TK_VALUE].parse(tokens.slice(next,-1),false)
			if err.has_error():
				return err
			has_mod[tokens[next][BEConstants.TK_TYPE]]=true
			next+=err.data[0]
			opcodes.append_array(err.data[1])
		else:
			break
	return LanguageResult.new(OK,next)



func get_value(opcodes:Array,index:int,macro:MacroInfo):
	if typeof(opcodes[index])==TYPE_VECTOR2:
		return lerp(macro.min_value,macro.max_value,opcodes[index].x)
	return opcodes[index]


func execute(macro:MacroInfo,opcodes:Array)->LanguageResult:
	return LanguageResult.new(LanguageResult.ERR_UNIMPLEMENTED_EXEC,{"s_command":get("NAME")})
