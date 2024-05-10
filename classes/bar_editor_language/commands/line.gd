extends BECommand
class_name BELine


const NAME:String="LINE"
enum{
	P_OP,P_X0,P_X1,P_V0,P_V1,P_EASE
}

func parse(tokens:Array,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,is_cmd,true,BEConstants.COMMANDS["LINE"])
	if err.has_error():
		return err
	var opcodes:Array=[]
	var next:int
	if token_type_at(tokens,7)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_LINE,
			tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],
			tokens[6][BEConstants.TK_VALUE],tokens[6][BEConstants.TK_VALUE],
			1.0
		]
		next=7
	elif token_type_at(tokens,9)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_LINE,
			tokens[2][BEConstants.TK_VALUE],tokens[6][BEConstants.TK_VALUE],
			tokens[4][BEConstants.TK_VALUE],tokens[8][BEConstants.TK_VALUE],
			1.0
		]
		next=9
	else:
		opcodes=[BEConstants.OP_LINE,
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


func execute(macro:MacroInfo,opcodes:Array)->LanguageResult:
	var vals:Array=macro.values.duplicate()
	var x0:int=get_value(opcodes,P_X0,macro)
	var x1:int=get_value(opcodes,P_X1,macro)
	var v0:int=get_value(opcodes,P_V0,macro)
	var v1:int=get_value(opcodes,P_V1,macro)
	var p_ease:float=get_value(opcodes,P_EASE,macro)
	var p_alpha:float=1.0
	var p_hstep:int=1
	var p_vstep:int=200
	var real_ease:float
	var real_alpha:float
	var real_hstep:int
	var real_vstep:int
	if x1<x0:
		var t:int=x0
		x0=x1
		x1=t
		t=v0
		v0=v1
		v1=t
	var val:float
	var step_count:int=0
	for i in range(x0,x1+1):
		real_ease=p_ease
		real_alpha=p_alpha
		real_hstep=p_hstep
		real_vstep=p_vstep
		if step_count==0:
			if vals[i]==ParamMacro.PASSTHROUGH:
				val=lerp(v0,v1,ease(range_lerp(i,x0,x1,0.0,1.0),real_ease))
			else:
				val=lerp(vals[clamp(i,0,vals.size()-1)],
					lerp(v0,
						v1,
						ease(range_lerp(i,x0,x1,0.0,1.0),real_ease)),
					real_alpha)
			val=clamp(stepify(val,real_vstep),macro.min_value,macro.max_value)
		if (i>=0 or i<vals.size()) and (real_hstep>=0 or step_count==0):
			vals[i]=val
		step_count+=1
		if step_count>=abs(real_hstep):
			step_count=0
	for i in macro.values.size():
		macro.values[i]=vals[i]
	return LanguageResult.new()
