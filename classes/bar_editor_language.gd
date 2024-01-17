extends Resource
class_name BarEditorLanguage

enum{MODE_WHITESPACE,MODE_WORD,MODE_NUMBER,MODE_SEPARATOR}
enum{
	TOKEN_WHITESPACE,TOKEN_WORD,TOKEN_NUMBER,TOKEN_SEPARATOR,TOKEN_ERROR,
	TOKEN_CMD_FOR,TOKEN_CMD_LINE
}
enum{TK_TYPE,TK_START,TK_END,TK_VALUE}
enum{CMD_PARSER,CMD_EXECUTOR,CMD_TOKEN,CMD_MIN_PARAMS}

const LETTERS:String="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
const NUMBERS:String="0123456789"
const NUMERICS:String="0123456789-."
const SEPARATORS:String=","
const TOKEN_NAMES:Dictionary={
	TOKEN_WHITESPACE:"whitespace",
	TOKEN_WORD:"word",
	TOKEN_NUMBER:"number",
	TOKEN_SEPARATOR:"separator"
}
const COMMANDS:Dictionary={
	"FOR":[
		"parse_for","execute_for",TOKEN_CMD_FOR,[
			TOKEN_CMD_FOR,TOKEN_WHITESPACE,TOKEN_NUMBER,TOKEN_SEPARATOR,TOKEN_NUMBER
		]
	],
	"LINE":[
		"parse_line","execute_line",TOKEN_CMD_LINE,[
			TOKEN_CMD_LINE,TOKEN_WHITESPACE,TOKEN_NUMBER,TOKEN_SEPARATOR,
			TOKEN_NUMBER,TOKEN_SEPARATOR,TOKEN_NUMBER
		]
	]
}


func parse(text:String)->LanguageResult:
	var tokens:Array=tokenize(text)
	return syntax_check(tokens)


func token(type:int,start:int,end:int,token=null)->Array:
	if type==TOKEN_WHITESPACE:
		return [type,start,end]
	elif type==TOKEN_WORD and token.to_upper() in COMMANDS:
		var cmd:Array=COMMANDS[token.to_upper()]
		return [cmd[CMD_TOKEN],start,end,funcref(self,cmd[CMD_PARSER])]
	return [type,start,end,token]


func tokenize(text:String)->Array:
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
				return [token(
					TOKEN_ERROR,LanguageResult.ERR_INVALID_CHARACTER,0,
					{"char":chr,"start":i,"end":i}
				)]
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
				return [token(
					TOKEN_ERROR,LanguageResult.ERR_INVALID_CHARACTER,0,
					{"char":chr,"start":i,"end":i}
				)]
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
				return [token(
					TOKEN_ERROR,LanguageResult.ERR_INVALID_CHARACTER,0,
					{"char":chr,"start":i,"end":i}
				)]
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
				return [token(
					TOKEN_ERROR,LanguageResult.ERR_INVALID_CHARACTER,0,
					{"char":chr,"start":i,"end":i}
				)]
	if mode==MODE_NUMBER:
		tokens.push_back(token(TOKEN_NUMBER,token_start,-1,token))
	elif mode==MODE_SEPARATOR:
		tokens.push_back(token(TOKEN_SEPARATOR,token_start,-1,token))
	elif mode==MODE_WORD:
		tokens.push_back(token(TOKEN_WORD,token_start,-1,token))
	return tokens


func syntax_check(tokens:Array)->LanguageResult:
	if tokens.empty():
		return LanguageResult.new(OK,tokens)
	var token:Array=tokens[0]
	var type:int=token[TK_TYPE]
	var start:int=token[TK_START]
	var end:int=token[TK_END]+1 if token[TK_END]>-1 else -1
	var value=token[TK_VALUE]
	if type==TOKEN_WORD:
		return LanguageResult.new(
			LanguageResult.ERR_BAD_COMMAND,
			{"command":value,"start":start,"end":end}
		)
	elif type==TOKEN_NUMBER or type==TOKEN_SEPARATOR:
		return LanguageResult.new(
			LanguageResult.ERR_BAD_START,
			{"start":start,"end":start}
		)
	elif type==TOKEN_ERROR:
		return LanguageResult.new(start,value)
	token=tokens[-1]
	if token[TK_TYPE]==TOKEN_SEPARATOR:
		return LanguageResult.new(
			LanguageResult.ERR_VALUE_EXPECTED,
			{"start":token[TK_START],"end":token[TK_END]+1 if token[TK_END]>-1 else -1}
		)
	#
	var consecutive_separators:int=0
	for t in tokens:
		type=token[TK_TYPE]
		start=token[TK_START]
		end=token[TK_END]+1 if token[TK_END]>-1 else -1
		value=token[TK_VALUE]
		if type==TOKEN_NUMBER:
			consecutive_separators=0
			if value.find("-")>0 or value.count(".")>1:
				return LanguageResult.new(
					LanguageResult.ERR_INVALID_NUMBER,
					{"start":start,"end":end}
				)
		elif type==TOKEN_SEPARATOR:
			consecutive_separators+=1
			if consecutive_separators>1:
				return LanguageResult.new(
					LanguageResult.ERR_VALUE_EXPECTED,
					{"start":start,"end":end}
				)
		else:
			consecutive_separators=0
	return tokens[0][TK_VALUE].call_func(tokens)


func find_invalid_tokens(tokens:Array,types:Array)->int:
	if tokens.size()<types.size():
		return tokens.size()
	for i in types.size():
		if tokens[i][TK_TYPE]!=types[i]:
			return i
	return -1


func parse_line(tokens:Array)->LanguageResult:
	var token:Array=tokens[1]
	var type:int=token[TK_TYPE]
	var start:int=token[TK_START]
	var end:int=token[TK_END]+1 if token[TK_END]>-1 else -1
	var value=token[TK_VALUE] if token.size()>TK_VALUE else null
	if type!=TOKEN_WHITESPACE:
		return LanguageResult.new(
			LanguageResult.ERR_WHITESPACE_EXPECTED,
			{"start":start,"end":start}
		)
	var err:int=find_invalid_tokens(tokens,COMMANDS["LINE"][CMD_MIN_PARAMS])
	if err==tokens.size():
		return LanguageResult.new(LanguageResult.ERR_UNEXPECTED_EOL,{"start":-1,"end":-1})
	elif err>-1:
		token=tokens[err]
		type=token[TK_TYPE]
		start=token[TK_START]
		end=token[TK_END]+1 if token[TK_END]>-1 else -1
		value=token[TK_VALUE]
		if type==TOKEN_WORD:
			return LanguageResult.new(
				LanguageResult.ERR_UNEXPECTED_TOKEN,
				{"token":"\""+value+"\"","start":start,"end":end}
			)
		else:
			return LanguageResult.new(
				LanguageResult.ERR_UNEXPECTED_TOKEN,
				{"token":TOKEN_NAMES[type],"start":start,"end":end}
			)
	return LanguageResult.new(OK,[
		funcref(self,COMMANDS["LINE"][CMD_EXECUTOR]),
		tokens[2][TK_VALUE],tokens[4][TK_VALUE],
		tokens[6][TK_VALUE],tokens[8][TK_VALUE],
	])


func execute(tokens:Array)->void:
	pass


func execute_line()->void:
	pass
