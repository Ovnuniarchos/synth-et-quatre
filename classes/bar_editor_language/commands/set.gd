extends BECommand
class_name BESet


const NAME:String="SET"
enum{
	P_OP,P_X0,P_X1,P_VALUE,P_HSTEP,P_ALPHA,P_END
}


func parse(tokens:Array,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,is_cmd,true,BEConstants.COMMANDS[NAME])
	if err.has_error():
		return err
	var opcodes:Array=[]
	var next:int
	if token_type_at(tokens,7)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_SET,
			tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],
			tokens[6][BEConstants.TK_VALUE],1,1.0
		]
		next=7
	elif token_type_at(tokens,9)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_SET,
			tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],
			tokens[6][BEConstants.TK_VALUE],tokens[8][BEConstants.TK_VALUE],
			1.0
		]
		next=9
	else:
		opcodes=[BEConstants.OP_SET,
			tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],
			tokens[6][BEConstants.TK_VALUE],tokens[8][BEConstants.TK_VALUE],
			tokens[10][BEConstants.TK_VALUE]
		]
		next=11
	err=parse_modifiers(tokens,opcodes,next)
	if err.has_error():
		return err
	next=err.data
	return LanguageResult.new(OK,[next,opcodes])


func execute(macro:MacroInfo,opcodes:Array)->LanguageResult:
	var vals:Array=macro.values.duplicate()
	var x0:int=get_value(opcodes,P_X0,macro)
	var x1:int=get_value(opcodes,P_X1,macro)
	var v0:int=get_value(opcodes,P_VALUE,macro)
	var alpha0:float=get_value(opcodes,P_ALPHA,macro)
	var alpha1:float=alpha0
	var alpha_ease:float=1.0
	var hstep0:int=get_value(opcodes,P_HSTEP,macro)
	var hstep1:int=hstep0
	var hstep_ease:float=1.0
	var ptr:int=P_END
	while ptr<opcodes.size():
		if opcodes[ptr]==BEConstants.OP_ALPHA:
			alpha0=opcodes[ptr+BEAlpha.P_A0]
			alpha1=opcodes[ptr+BEAlpha.P_A1]
			alpha_ease=opcodes[ptr+BEAlpha.P_EASE]
			ptr+=BEAlpha.P_END
		elif opcodes[ptr]==BEConstants.OP_HSTEP:
			hstep0=opcodes[ptr+BEHStep.P_S0]
			hstep1=opcodes[ptr+BEHStep.P_S1]
			hstep_ease=opcodes[ptr+BEHStep.P_EASE]
			ptr+=BEHStep.P_END
		else:
			ptr+=1
	if not macro.can_use_alpha():
		if alpha0!=alpha1:
			return LanguageResult.new(LanguageResult.ERR_NOT_ON_MASKS_OR_SELS,{"s_command":BEAlpha.NAME})
		elif not is_equal_approx(alpha0,1.0):
			return LanguageResult.new(LanguageResult.ERR_ALPHA_ON_MASK_OR_SEL,{})
	var real_alpha:float
	var real_hstep:int
	if x1<x0:
		var t:int=x0
		x0=x1
		x1=t
	var val:float
	var weight:float
	var step_count:int=0
	if macro.mode!=MacroInfo.MODE_MASK:
		for i in range(x0,x1+1):
			weight=range_lerp(i,x0,x1,0.0,1.0)
			real_hstep=lerp(hstep0,hstep1,ease(weight,hstep_ease))
			real_alpha=lerp(alpha0,alpha1,ease(weight,alpha_ease))
			if step_count==0:
				val=v0
				if vals[i]!=ParamMacro.PASSTHROUGH:
					val=lerp(vals[clamp(i,0,vals.size()-1)],val,real_alpha)
				val=clamp(val,macro.min_value,macro.max_value)
			if (i>=0 or i<vals.size()) and (real_hstep>=0 or step_count==0):
				vals[i]=val
			step_count+=1
			if step_count>=abs(real_hstep):
				step_count=0
	else:
		v0=1<<v0
		for i in range(x0,x1+1):
			weight=range_lerp(i,x0,x1,0.0,1.0)
			real_hstep=lerp(hstep0,hstep1,ease(weight,hstep_ease))
			if (i>=0 or i<vals.size()) and (real_hstep>=0 or step_count==0):
				vals[i]=vals[i]|v0|(v0<<ParamMacro.MASK_PASSTHROUGH_SHIFT)
			step_count+=1
			if step_count>=abs(real_hstep):
				step_count=0
	for i in macro.values.size():
		macro.values[i]=vals[i]
	return LanguageResult.new()
