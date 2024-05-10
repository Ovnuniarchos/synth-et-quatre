extends Resource
class_name BarEditorLanguage


const CMD_INIT:Dictionary={
	BEConstants.OP2CMD[BEConstants.OP_LINE]:BELine,
	BEConstants.OP2CMD[BEConstants.OP_ALPHA]:BEAlpha,
	BEConstants.OP2CMD[BEConstants.OP_EASE]:BEEase,
	BEConstants.OP2CMD[BEConstants.OP_HSTEP]:BEHStep,
	BEConstants.OP2CMD[BEConstants.OP_VSTEP]:BEVStep,
}


var rx_number:RegEx


func _init()->void:
	for c in CMD_INIT.keys():
		var a:Array=BEConstants.COMMANDS[c]
		a[0]=CMD_INIT[c].new()
	rx_number=RegEx.new()
	rx_number.compile("^-?(\\d+\\.?\\d*|\\d*\\.?\\d+)%?$")


func parse(text:String)->LanguageResult:
	var err:LanguageResult=tokenize(text)
	if err.has_error():
		err.error_data["text"]=text
		return err
	var tokens:Array=err.data
	var from:int=0
	var opcodes:Array=[]
	while true:
		err=syntax_check(tokens,from)
		if err.has_error() or err.data==-1:
			break
		from=err.data
		err=tokens[from][BEConstants.TK_VALUE].parse(tokens.slice(from,-1),true)
		if err.has_error():
			break
		from+=err.data[0]
		opcodes.append(err.data[1])
	if err.has_error():
		err.error_data["text"]=text
		return err
	return LanguageResult.new(OK,opcodes)


func token(type:int,start:int,end:int,token:String="")->Array:
	if type==BEConstants.TOKEN_WHITESPACE:
		return [type,start,end]
	elif type==BEConstants.TOKEN_WORD and token.to_upper() in BEConstants.COMMANDS:
		var cmd:Array=BEConstants.COMMANDS[token.to_upper()]
		return [cmd[BEConstants.CMD_TOKEN],start,end,cmd[BEConstants.CMD_PARSER]]
	return [type,start,end,token]


func tokenize(text:String)->LanguageResult:
	var tokens:Array=[]
	var token:String=""
	var mode:int=BEConstants.MODE_WHITESPACE
	var chr:String
	var token_start:int=1
	for i in range(1,text.length()+1):
		chr=text[i-1]
		if mode==BEConstants.MODE_WHITESPACE:
			if chr in BEConstants.LETTERS:
				if not tokens.empty():
					tokens.push_back(token(BEConstants.TOKEN_WHITESPACE,token_start,i))
				token=chr
				token_start=i
				mode=BEConstants.MODE_WORD
			elif chr in BEConstants.NUMERICS:
				if not tokens.empty():
					tokens.push_back(token(BEConstants.TOKEN_WHITESPACE,token_start,i))
				token=chr
				token_start=i
				mode=BEConstants.MODE_NUMBER
			elif chr in BEConstants.SEPARATORS:
				token=chr
				token_start=i
				mode=BEConstants.MODE_SEPARATOR
			elif chr!=" ":
				return LanguageResult.new(LanguageResult.ERR_INVALID_CHARACTER,
					{"s_char":chr,"i_start":i,"i_end":i}
				)
		elif mode==BEConstants.MODE_WORD:
			if chr in BEConstants.LETTERS or chr in BEConstants.NUMBERS:
				token+=chr
			elif chr in BEConstants.NUMERICS:
				tokens.push_back(token(BEConstants.TOKEN_WORD,token_start,i,token))
				token=chr
				token_start=i
				mode=BEConstants.MODE_NUMBER
			elif chr in BEConstants.SEPARATORS:
				tokens.push_back(token(BEConstants.TOKEN_WORD,token_start,i,token))
				token=chr
				token_start=i
				mode=BEConstants.MODE_SEPARATOR
			elif chr<=" ":
				tokens.push_back(token(BEConstants.TOKEN_WORD,token_start,i,token))
				token_start=i
				mode=BEConstants.MODE_WHITESPACE
			else:
				return LanguageResult.new(LanguageResult.ERR_INVALID_CHARACTER,
					{"s_char":chr,"i_start":i,"i_end":i}
				)
		elif mode==BEConstants.MODE_NUMBER:
			if chr in BEConstants.NUMERICS:
				token+=chr
			elif chr in BEConstants.LETTERS:
				tokens.push_back(token(BEConstants.TOKEN_NUMBER,token_start,i,token))
				token=chr
				token_start=i
				mode=BEConstants.MODE_WORD
			elif chr in BEConstants.SEPARATORS:
				tokens.push_back(token(BEConstants.TOKEN_NUMBER,token_start,i,token))
				token_start=i
				token=chr
				mode=BEConstants.MODE_SEPARATOR
			elif chr==" ":
				tokens.push_back(token(BEConstants.TOKEN_NUMBER,token_start,i,token))
				token_start=i
				mode=BEConstants.MODE_WHITESPACE
			else:
				return LanguageResult.new(LanguageResult.ERR_INVALID_CHARACTER,
					{"s_char":chr,"i_start":i,"i_end":i}
				)
		elif mode==BEConstants.MODE_SEPARATOR:
			if chr in BEConstants.NUMERICS:
				tokens.push_back(token(BEConstants.TOKEN_SEPARATOR,token_start,i,token))
				token=chr
				token_start=i
				mode=BEConstants.MODE_NUMBER
			elif chr in BEConstants.LETTERS:
				tokens.push_back(token(BEConstants.TOKEN_SEPARATOR,token_start,i,token))
				token=chr
				token_start=i
				mode=BEConstants.MODE_WORD
			elif chr in BEConstants.SEPARATORS:
				tokens.push_back(token(BEConstants.TOKEN_SEPARATOR,token_start,i,token))
				token=chr
				token_start=i
			elif chr!=" ":
				return LanguageResult.new(LanguageResult.ERR_INVALID_CHARACTER,
					{"s_char":chr,"i_start":i,"i_end":i}
				)
	if mode==BEConstants.MODE_NUMBER:
		tokens.push_back(token(BEConstants.TOKEN_NUMBER,token_start,text.length()+1,token))
	elif mode==BEConstants.MODE_SEPARATOR:
		tokens.push_back(token(BEConstants.TOKEN_SEPARATOR,token_start,text.length()+1,token))
	elif mode==BEConstants.MODE_WORD:
		tokens.push_back(token(BEConstants.TOKEN_WORD,token_start,text.length()+1,token))
	return LanguageResult.new(OK,tokens)


func syntax_check(tokens:Array,from:int)->LanguageResult:
	tokens=tokens.slice(from,-1)
	var from2:int=0
	for t in tokens:
		if t[BEConstants.TK_TYPE]!=BEConstants.TOKEN_WHITESPACE:
			break
		from+=1
		from2+=1
	tokens=tokens.slice(from2,-1)
	if tokens.empty():
		return LanguageResult.new(OK,-1)
	var token:Array=tokens[0]
	var type:int=token[BEConstants.TK_TYPE]
	var start:int=token[BEConstants.TK_START]
	var end:int=token[BEConstants.TK_END] if token[BEConstants.TK_END]>-1 else -1
	var value=token[BEConstants.TK_VALUE]
	if type==BEConstants.TOKEN_WORD:
		return LanguageResult.new(
			LanguageResult.ERR_BAD_COMMAND,
			{"s_command":value,"i_start":start,"i_end":end}
		)
	elif type==BEConstants.TOKEN_NUMBER or type==BEConstants.TOKEN_SEPARATOR:
		return LanguageResult.new(
			LanguageResult.ERR_COMMAND_EXPECTED,
			{"i_start":start,"i_end":start}
		)
	token=tokens[-1]
	if token[BEConstants.TK_TYPE]==BEConstants.TOKEN_SEPARATOR:
		end=token[BEConstants.TK_END] if token[BEConstants.TK_END]>-1 else -1
		return LanguageResult.new(
			LanguageResult.ERR_VALUE_EXPECTED,
			{"i_start":end,"i_end":end}
		)
	#
	var consecutive_separators:int=0
	for t in tokens:
		type=t[BEConstants.TK_TYPE]
		start=t[BEConstants.TK_START]
		end=t[BEConstants.TK_END]+1 if t[BEConstants.TK_END]>-1 else -1
		value=t[BEConstants.TK_VALUE] if type!=BEConstants.TOKEN_WHITESPACE else null
		if type==BEConstants.TOKEN_NUMBER and not typeof(value) in [TYPE_INT,TYPE_REAL]:
			consecutive_separators=0
			if rx_number.search(value)==null:
				return LanguageResult.new(
					LanguageResult.ERR_INVALID_NUMBER,
					{"i_start":start,"i_end":end}
				)
			# warning-ignore:incompatible_ternary
			var v=float(value) if "." in value or abs(int(value))>0xffffffff else int(value)
			t[BEConstants.TK_VALUE]=v*0.01 if value.ends_with("%") else v
		elif type==BEConstants.TOKEN_SEPARATOR:
			consecutive_separators+=1
			if consecutive_separators>1:
				return LanguageResult.new(
					LanguageResult.ERR_VALUE_EXPECTED,
					{"i_start":end,"i_end":end}
				)
		else:
			consecutive_separators=0
	return LanguageResult.new(OK,from)


func execute(macro:MacroInfo,opcodes:Array)->LanguageResult:
	var ptr:int=0
	var err:LanguageResult
	while ptr<opcodes.size():
		err=BEConstants.COMMANDS[BEConstants.OP2CMD[opcodes[ptr][0]]][BEConstants.CMD_PARSER].execute(macro,opcodes[ptr])
		if err.has_error():
			return err
		ptr+=1
	return LanguageResult.new()
