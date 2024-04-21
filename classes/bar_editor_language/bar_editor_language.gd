extends Resource
class_name BarEditorLanguage

enum{MODE_WHITESPACE,MODE_WORD,MODE_NUMBER,MODE_SEPARATOR}
enum{
	TOKEN_WHITESPACE,TOKEN_WORD,TOKEN_NUMBER,TOKEN_SEPARATOR,
	TOKEN_CMD_LINE,TOKEN_CMD_ALPHA,TOKEN_CMD_EASE
	TOKEN_OPTIONAL=0x80000000
}
enum{TK_TYPE,TK_START,TK_END,TK_VALUE}
enum{CMD_PARSER,CMD_TOKEN,CMD_MIN_TOKENS,CMD_PARAMS}
enum{OP_INTERPOLATE=1000,OP_ALPHA,OP_EASE}

const LETTERS:String="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
const NUMBERS:String="0123456789"
const NUMERICS:String="0123456789-."
const SEPARATORS:String=","
const TOKEN_NAMES:Dictionary={
	TOKEN_WHITESPACE:"TOKEN_WHITESPACE",
	TOKEN_WORD:"TOKEN_WORD",
	TOKEN_NUMBER:"TOKEN_NUMBER",
	TOKEN_SEPARATOR:"TOKEN_SEPARATOR",
	TOKEN_CMD_LINE:"TOKEN_COMMAND"
}
const COMMANDS:Dictionary={
	"LINE":[
		"parse_line",TOKEN_CMD_LINE,7,[
			TOKEN_CMD_LINE,TOKEN_WHITESPACE,TOKEN_NUMBER,TOKEN_SEPARATOR,
			TOKEN_NUMBER,TOKEN_SEPARATOR,TOKEN_NUMBER,TOKEN_OPTIONAL,
			TOKEN_SEPARATOR,TOKEN_NUMBER,TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER
		]
	],
	"ALPHA":[
		"parse_alpha",TOKEN_CMD_ALPHA,3,[
			TOKEN_CMD_ALPHA,TOKEN_WHITESPACE,TOKEN_NUMBER,
			TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER,
			TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER
		]
	],
	"EASE":[
		"parse_ease",TOKEN_CMD_EASE,3,[
			TOKEN_CMD_ALPHA,TOKEN_WHITESPACE,TOKEN_NUMBER,
			TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER,
			TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER
		]
	]
}


func parse(text:String)->LanguageResult:
	var err:LanguageResult=tokenize(text)
	if err.has_error():
		err.error_data["text"]=text
		return err
	var tokens:Array=err.data
	var start:int=0
	var opcodes:Array=[]
	while true:
		err=syntax_check(tokens,start)
		if err.has_error() or err.data==-1:
			break
		start=err.data
		err=tokens[start][TK_VALUE].call_func(tokens,start,true)
		if err.has_error():
			break
		start=err.data[0]
		opcodes.append(err.data[1])
	if err.has_error():
		err.error_data["text"]=text
		return err
	return LanguageResult.new(OK,opcodes)


func token(type:int,start:int,end:int,token:String="")->Array:
	if type==TOKEN_WHITESPACE:
		return [type,start,end]
	elif type==TOKEN_WORD and token.to_upper() in COMMANDS:
		var cmd:Array=COMMANDS[token.to_upper()]
		return [cmd[CMD_TOKEN],start,end,funcref(self,cmd[CMD_PARSER])]
	return [type,start,end,token]


func token_error_string(token:Array)->String:
	if token[TK_TYPE]<TOKEN_CMD_LINE:
		return tr(TOKEN_NAMES[token[TK_TYPE]])
	return tr(TOKEN_NAMES[TOKEN_CMD_LINE])


func tokenize(text:String)->LanguageResult:
	var tokens:Array=[]
	var token:String=""
	var mode:int=MODE_WHITESPACE
	var chr:String
	var token_start:int=1
	for i in range(1,text.length()+1):
		chr=text[i-1]
		if mode==MODE_WHITESPACE:
			if chr in LETTERS:
				if not tokens.empty():
					tokens.push_back(token(TOKEN_WHITESPACE,token_start,i))
				token=chr
				token_start=i
				mode=MODE_WORD
			elif chr in NUMERICS:
				if not tokens.empty():
					tokens.push_back(token(TOKEN_WHITESPACE,token_start,i))
				token=chr
				token_start=i
				mode=MODE_NUMBER
			elif chr in SEPARATORS:
				token=chr
				token_start=i
				mode=MODE_SEPARATOR
			elif chr!=" ":
				return LanguageResult.new(LanguageResult.ERR_INVALID_CHARACTER,
					{"s_char":chr,"i_start":i,"i_end":i}
				)
		elif mode==MODE_WORD:
			if chr in LETTERS or chr in NUMBERS:
				token+=chr
			elif chr in NUMERICS:
				tokens.push_back(token(TOKEN_WORD,token_start,i,token))
				token=chr
				token_start=i
				mode=MODE_NUMBER
			elif chr in SEPARATORS:
				tokens.push_back(token(TOKEN_WORD,token_start,i,token))
				token=chr
				token_start=i
				mode=MODE_SEPARATOR
			elif chr<=" ":
				tokens.push_back(token(TOKEN_WORD,token_start,i,token))
				token_start=i
				mode=MODE_WHITESPACE
			else:
				return LanguageResult.new(LanguageResult.ERR_INVALID_CHARACTER,
					{"s_char":chr,"i_start":i,"i_end":i}
				)
		elif mode==MODE_NUMBER:
			if chr in NUMERICS:
				token+=chr
			elif chr in LETTERS:
				tokens.push_back(token(TOKEN_NUMBER,token_start,i,token))
				token=chr
				token_start=i
				mode=MODE_WORD
			elif chr in SEPARATORS:
				tokens.push_back(token(TOKEN_NUMBER,token_start,i,token))
				token_start=i
				token=chr
				mode=MODE_SEPARATOR
			elif chr==" ":
				tokens.push_back(token(TOKEN_NUMBER,token_start,i,token))
				token_start=i
				mode=MODE_WHITESPACE
			else:
				return LanguageResult.new(LanguageResult.ERR_INVALID_CHARACTER,
					{"s_char":chr,"i_start":i,"i_end":i}
				)
		elif mode==MODE_SEPARATOR:
			if chr in NUMERICS:
				tokens.push_back(token(TOKEN_SEPARATOR,token_start,i,token))
				token=chr
				token_start=i
				mode=MODE_NUMBER
			elif chr in LETTERS:
				tokens.push_back(token(TOKEN_SEPARATOR,token_start,i,token))
				token=chr
				token_start=i
				mode=MODE_WORD
			elif chr in SEPARATORS:
				tokens.push_back(token(TOKEN_SEPARATOR,token_start,i,token))
				token=chr
				token_start=i
			elif chr!=" ":
				return LanguageResult.new(LanguageResult.ERR_INVALID_CHARACTER,
					{"s_char":chr,"i_start":i,"i_end":i}
				)
	if mode==MODE_NUMBER:
		tokens.push_back(token(TOKEN_NUMBER,token_start,text.length()+1,token))
	elif mode==MODE_SEPARATOR:
		tokens.push_back(token(TOKEN_SEPARATOR,token_start,text.length()+1,token))
	elif mode==MODE_WORD:
		tokens.push_back(token(TOKEN_WORD,token_start,text.length()+1,token))
	return LanguageResult.new(OK,tokens)


# end doesn't have to be +1 in all cases
func syntax_check(tokens:Array,from:int)->LanguageResult:
	tokens=tokens.slice(from,-1)
	var from2:int=0
	for t in tokens:
		if t[TK_TYPE]!=TOKEN_WHITESPACE:
			break
		from+=1
		from2+=1
	tokens=tokens.slice(from2,-1)
	if tokens.empty():
		return LanguageResult.new(OK,-1)
	var token:Array=tokens[0]
	var type:int=token[TK_TYPE]
	var start:int=token[TK_START]
	var end:int=token[TK_END] if token[TK_END]>-1 else -1
	var value=token[TK_VALUE]
	if type==TOKEN_WORD:
		return LanguageResult.new(
			LanguageResult.ERR_BAD_COMMAND,
			{"s_command":value,"i_start":start,"i_end":end}
		)
	elif type==TOKEN_NUMBER or type==TOKEN_SEPARATOR:
		return LanguageResult.new(
			LanguageResult.ERR_COMMAND_EXPECTED,
			{"i_start":start,"i_end":start}
		)
	token=tokens[-1]
	if token[TK_TYPE]==TOKEN_SEPARATOR:
		end=token[TK_END] if token[TK_END]>-1 else -1
		return LanguageResult.new(
			LanguageResult.ERR_VALUE_EXPECTED,
			{"i_start":end,"i_end":end}
		)
	#
	var consecutive_separators:int=0
	for t in tokens:
		type=t[TK_TYPE]
		start=t[TK_START]
		end=t[TK_END]+1 if t[TK_END]>-1 else -1
		value=t[TK_VALUE] if type!=TOKEN_WHITESPACE else null
		if type==TOKEN_NUMBER and not typeof(value) in [TYPE_INT,TYPE_REAL]:
			consecutive_separators=0
			if value.find("-")>0 or value.count(".")>1:
				return LanguageResult.new(
					LanguageResult.ERR_INVALID_NUMBER,
					{"i_start":start,"i_end":end}
				)
			# warning-ignore:incompatible_ternary
			value=float(value) if "." in value or abs(int(value))>0xffffffff else int(value)
			t[TK_VALUE]=value
		elif type==TOKEN_SEPARATOR:
			consecutive_separators+=1
			if consecutive_separators>1:
				return LanguageResult.new(
					LanguageResult.ERR_VALUE_EXPECTED,
					{"i_start":end,"i_end":end}
				)
		else:
			consecutive_separators=0
	return LanguageResult.new(OK,from)


func find_invalid_tokens(tokens:Array,cmd_data:Array,from:int)->int:
	if tokens.size()<cmd_data[CMD_MIN_TOKENS]:
		return tokens.size()
	var types:Array=cmd_data[CMD_PARAMS]
	for i in types.size():
		if types[i]==TOKEN_OPTIONAL:
			if from>=tokens.size() or tokens[from][TK_TYPE]==TOKEN_WHITESPACE:
				return -1
			continue
		if from>=tokens.size():
			return tokens.size()
		if tokens[from][TK_TYPE]!=types[i]:
			return from
		from+=1
	return -1


func token_type_at(tokens:Array,at:int)->int:
	return tokens[at][TK_TYPE] if tokens.size()>at else TOKEN_WHITESPACE


func common_checks(tokens:Array,from:int,is_cmd:bool,expected_cmd:bool,command:Array)->LanguageResult:
	if is_cmd!=expected_cmd:
		return LanguageResult.new(LanguageResult.ERR_UNEXPECTED_TOKEN,{"s_token":token_error_string(tokens[from]),"i_start":tokens[from][TK_START]})
	var end:int=tokens[-1][TK_END]+1 if tokens[-1][TK_END]>-1 else -1
	if from+command[CMD_MIN_TOKENS]>tokens.size():
		return LanguageResult.new(LanguageResult.ERR_UNEXPECTED_EOL,{"i_start":end,"i_end":end})
	var token:Array=tokens[from+1]
	var type:int=token[TK_TYPE]
	var start:int=token[TK_START]
	end=token[TK_END]+1 if token[TK_END]>-1 else -1
	if type!=TOKEN_WHITESPACE:
		return LanguageResult.new(
			LanguageResult.ERR_WHITESPACE_EXPECTED,
			{"i_start":start,"i_end":start}
		)
	var itoken_pos:int=find_invalid_tokens(tokens,command,from)
	if itoken_pos==tokens.size():
		return LanguageResult.new(LanguageResult.ERR_MISSING_PARAMS,{"i_start":tokens[from][TK_START],"i_end":-1})
	elif itoken_pos>-1:
		token=tokens[itoken_pos]
		type=token[TK_TYPE]
		start=token[TK_START]
		end=token[TK_END]+1 if token[TK_END]>-1 else -1
		return LanguageResult.new(
			LanguageResult.ERR_UNEXPECTED_TOKEN,
			{"s_token":token_error_string(token),"i_start":start,"i_end":end}
		)
	return LanguageResult.new()

func parse_line(tokens:Array,from:int,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,from,is_cmd,true,COMMANDS["LINE"])
	if err.has_error():
		return err
	var opcodes:Array=[]
	if token_type_at(tokens,from+7)==TOKEN_WHITESPACE:
		opcodes=[OP_INTERPOLATE,
			tokens[from+2][TK_VALUE],tokens[from+4][TK_VALUE],
			tokens[from+6][TK_VALUE],tokens[from+6][TK_VALUE],
			1.0
		]
		from+=7
	elif token_type_at(tokens,9)==TOKEN_WHITESPACE:
		opcodes=[OP_INTERPOLATE,
			tokens[from+2][TK_VALUE],tokens[from+6][TK_VALUE],
			tokens[from+4][TK_VALUE],tokens[from+8][TK_VALUE],
			1.0
		]
		from+=9
	else:
		opcodes=[OP_INTERPOLATE,
			tokens[from+2][TK_VALUE],tokens[from+6][TK_VALUE],
			tokens[from+4][TK_VALUE],tokens[from+8][TK_VALUE],
			tokens[from+10][TK_VALUE]
		]
		from+=11
	while from<tokens.size():
		if tokens[from][TK_TYPE]==TOKEN_WHITESPACE:
			from+=1
		elif tokens[from][TK_TYPE] in [TOKEN_CMD_ALPHA,TOKEN_CMD_EASE]:
			err=tokens[from][TK_VALUE].call_func(tokens,from,false)
			if err.has_error():
				return err
			from=err.data[0]
			opcodes.append_array(err.data[1])
		else:
			break
	return LanguageResult.new(OK,[from,opcodes])


func parse_alpha(tokens:Array,from:int,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,from,is_cmd,false,COMMANDS["ALPHA"])
	if err.has_error():
		return err
	var opcodes:Array=[]
	if token_type_at(tokens,from+3)==TOKEN_WHITESPACE:
		opcodes=[OP_ALPHA,
			tokens[from+2][TK_VALUE],tokens[from+2][TK_VALUE],1.0
		]
		from+=3
	elif token_type_at(tokens,from+5)==TOKEN_WHITESPACE:
		opcodes=[OP_ALPHA,
			tokens[from+2][TK_VALUE],tokens[from+4][TK_VALUE],1.0
		]
		from+=5
	else:
		opcodes=[OP_ALPHA,
			tokens[from+2][TK_VALUE],tokens[from+4][TK_VALUE],tokens[from+6][TK_VALUE]
		]
		from+=7
	return LanguageResult.new(OK,[from,opcodes])


func parse_ease(tokens:Array,from:int,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,from,is_cmd,false,COMMANDS["EASE"])
	if err.has_error():
		return err
	var opcodes:Array=[]
	if token_type_at(tokens,from+3)==TOKEN_WHITESPACE:
		opcodes=[OP_EASE,
			tokens[from+2][TK_VALUE],tokens[from+2][TK_VALUE],1.0
		]
		from+=3
	elif token_type_at(tokens,from+5)==TOKEN_WHITESPACE:
		opcodes=[OP_EASE,
			tokens[from+2][TK_VALUE],tokens[from+4][TK_VALUE],1.0
		]
		from+=5
	else:
		opcodes=[OP_EASE,
			tokens[from+2][TK_VALUE],tokens[from+4][TK_VALUE],tokens[from+6][TK_VALUE]
		]
		from+=7
	return LanguageResult.new(OK,[from,opcodes])


func execute(values:Array,opcodes:Array)->LanguageResult:
	var ptr:int=0
	while ptr<opcodes.size():
		ptr+=1
	return LanguageResult.new()
