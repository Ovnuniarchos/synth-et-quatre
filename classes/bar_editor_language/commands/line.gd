extends BECommand
class_name BELine


const NAME:String="LINE"
enum{
	P_OP,P_X0,P_X1,P_V0,P_V1,P_EASE,P_ALPHA,P_END
}


func parse(tokens:Array,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,is_cmd,true,BEConstants.COMMANDS[NAME])
	if err.has_error():
		return err
	var opcodes:Array=[]
	var next:int
	if token_type_at(tokens,7)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_LINE,
			tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],
			tokens[6][BEConstants.TK_VALUE],tokens[6][BEConstants.TK_VALUE],
			1.0,1.0
		]
		next=7
	elif token_type_at(tokens,9)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_LINE,
			tokens[2][BEConstants.TK_VALUE],tokens[6][BEConstants.TK_VALUE],
			tokens[4][BEConstants.TK_VALUE],tokens[8][BEConstants.TK_VALUE],
			1.0,1.0
		]
		next=9
	elif token_type_at(tokens,11)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_LINE,
			tokens[2][BEConstants.TK_VALUE],tokens[6][BEConstants.TK_VALUE],
			tokens[4][BEConstants.TK_VALUE],tokens[8][BEConstants.TK_VALUE],
			tokens[10][BEConstants.TK_VALUE],1.0
		]
		next=11
	else:
		opcodes=[BEConstants.OP_LINE,
			tokens[2][BEConstants.TK_VALUE],tokens[6][BEConstants.TK_VALUE],
			tokens[4][BEConstants.TK_VALUE],tokens[8][BEConstants.TK_VALUE],
			tokens[10][BEConstants.TK_VALUE],tokens[12][BEConstants.TK_VALUE]
		]
		next=11
	err=parse_modifiers(tokens,opcodes,next)
	if err.has_error():
		return err
	next=err.data
	return LanguageResult.new(OK,[next,opcodes])


func execute(macro:MacroInfo,opcodes:Array)->LanguageResult:
	if not macro.can_use_alpha():
		return LanguageResult.new(LanguageResult.ERR_NOT_ON_MASKS_OR_SELS,{"s_command":NAME})
	var vals:Array=macro.values.duplicate()
	var x0:int=get_value(opcodes,P_X0,macro)
	var x1:int=get_value(opcodes,P_X1,macro)
	var v0:int=get_value(opcodes,P_V0,macro)
	var v1:int=get_value(opcodes,P_V1,macro)
	var ease0:float=get_value(opcodes,P_EASE,macro)
	var ease1:float=ease0
	var ease_ease:float=1.0
	var alpha0:float=get_value(opcodes,P_ALPHA,macro)
	var alpha1:float=alpha0
	var alpha_ease:float=1.0
	var hstep0:int=1
	var hstep1:int=1
	var hstep_ease:float=1.0
	var vstep0:int=1
	var vstep1:int=1
	var vstep_ease:float=1.0
	var ptr:int=P_END
	while ptr<opcodes.size():
		if opcodes[ptr]==BEConstants.OP_ALPHA:
			alpha0=opcodes[ptr+BEAlpha.P_A0]
			alpha1=opcodes[ptr+BEAlpha.P_A1]
			alpha_ease=opcodes[ptr+BEAlpha.P_EASE]
			ptr+=BEAlpha.P_END
		elif opcodes[ptr]==BEConstants.OP_EASE:
			ease0=opcodes[ptr+BEEase.P_E0]
			ease1=opcodes[ptr+BEEase.P_E1]
			ease_ease=opcodes[ptr+BEEase.P_EASE]
			ptr+=BEEase.P_END
		elif opcodes[ptr]==BEConstants.OP_HSTEP:
			hstep0=opcodes[ptr+BEHStep.P_S0]
			hstep1=opcodes[ptr+BEHStep.P_S1]
			hstep_ease=opcodes[ptr+BEHStep.P_EASE]
			ptr+=BEHStep.P_END
		elif opcodes[ptr]==BEConstants.OP_VSTEP:
			vstep0=opcodes[ptr+BEVStep.P_S0]
			vstep1=opcodes[ptr+BEVStep.P_S1]
			vstep_ease=opcodes[ptr+BEVStep.P_EASE]
			ptr+=BEVStep.P_END
		else:
			ptr+=1
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
	var weight:float
	var step_count:int=0
	for i in range(x0,x1+1):
		weight=range_lerp(i,x0,x1,0.0,1.0)
		real_ease=lerp(ease0,ease1,ease(weight,ease_ease))
		real_alpha=lerp(alpha0,alpha1,ease(weight,alpha_ease))
		real_hstep=lerp(hstep0,hstep1,ease(weight,hstep_ease))
		real_vstep=lerp(vstep0,vstep1,ease(weight,vstep_ease))
		if step_count==0:
			val=lerp(v0,v1,ease(weight,real_ease))
			if vals[i]!=ParamMacro.PASSTHROUGH:
				val=lerp(vals[clamp(i,0,vals.size()-1)],val,real_alpha)
			val=clamp(stepify(val,real_vstep),macro.min_value,macro.max_value)
		if (i>=0 or i<vals.size()) and (real_hstep>=0 or step_count==0):
			vals[i]=val
		step_count+=1
		if step_count>=abs(real_hstep):
			step_count=0
	for i in macro.values.size():
		macro.values[i]=vals[i]
	return LanguageResult.new()
