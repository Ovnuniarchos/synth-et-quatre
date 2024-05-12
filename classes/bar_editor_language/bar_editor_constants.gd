extends Reference
class_name BEConstants


enum{MODE_WHITESPACE,MODE_WORD,MODE_NUMBER,MODE_SEPARATOR}
enum{
	TOKEN_WHITESPACE,TOKEN_WORD,TOKEN_NUMBER,TOKEN_SEPARATOR,
	TOKEN_CMD_LINE,TOKEN_CMD_ALPHA,TOKEN_CMD_EASE,
	TOKEN_CMD_HSTEP,TOKEN_CMD_VSTEP,
	TOKEN_OPTIONAL=0x80000000
}
enum{TK_TYPE,TK_START,TK_END,TK_VALUE}
enum{CMD_PARSER,CMD_TOKEN,CMD_MIN_TOKENS,CMD_PARAMS,CMD_MODIFIERS}
enum{OP_LINE=1000,OP_ALPHA,OP_EASE,OP_HSTEP,OP_VSTEP}

const LETTERS:String="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
const NUMBERS:String="0123456789"
const NUMERICS:String="0123456789-.%"
const SEPARATORS:String=","
const TOKEN_NAMES:Dictionary={
	TOKEN_WHITESPACE:"TOKEN_WHITESPACE",
	TOKEN_WORD:"TOKEN_WORD",
	TOKEN_NUMBER:"TOKEN_NUMBER",
	TOKEN_SEPARATOR:"TOKEN_SEPARATOR",
	TOKEN_CMD_LINE:"TOKEN_COMMAND"
}
const OP2CMD:Dictionary={
	OP_LINE:"LINE",
	OP_ALPHA:"ALPHA",
	OP_EASE:"EASE",
	OP_HSTEP:"HSTEP",
	OP_VSTEP:"VSTEP",
}
const COMMANDS:Dictionary={
	OP2CMD[OP_LINE]:[
		null,TOKEN_CMD_LINE,7,[
			TOKEN_CMD_LINE,TOKEN_WHITESPACE,TOKEN_NUMBER,TOKEN_SEPARATOR,
			TOKEN_NUMBER,TOKEN_SEPARATOR,TOKEN_NUMBER,TOKEN_OPTIONAL,
			TOKEN_SEPARATOR,TOKEN_NUMBER,TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER
		],[TOKEN_CMD_ALPHA,TOKEN_CMD_EASE,TOKEN_CMD_HSTEP,TOKEN_CMD_VSTEP]
	],
	OP2CMD[OP_ALPHA]:[
		null,TOKEN_CMD_ALPHA,3,[
			TOKEN_CMD_ALPHA,TOKEN_WHITESPACE,TOKEN_NUMBER,
			TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER,
			TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER
		],[]
	],
	OP2CMD[OP_EASE]:[
		null,TOKEN_CMD_EASE,3,[
			TOKEN_CMD_EASE,TOKEN_WHITESPACE,TOKEN_NUMBER,
			TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER,
			TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER
		],[]
	],
	OP2CMD[OP_HSTEP]:[
		null,TOKEN_CMD_HSTEP,3,[
			TOKEN_CMD_HSTEP,TOKEN_WHITESPACE,TOKEN_NUMBER,
			TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER,
			TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER
		],[]
	],
	OP2CMD[OP_VSTEP]:[
		null,TOKEN_CMD_VSTEP,3,[
			TOKEN_CMD_VSTEP,TOKEN_WHITESPACE,TOKEN_NUMBER,
			TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER,
			TOKEN_OPTIONAL,TOKEN_SEPARATOR,TOKEN_NUMBER
		],[]
	],
}
