extends BECommand
class_name BEClear


const NAME:String="CLEAR"
enum{
	P_OP,P_X0,P_X1,P_VALUE,P_HSTEP,P_END
}


func parse(tokens:Array,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,is_cmd,true,BEConstants.COMMANDS[NAME])
	if err.has_error():
		return err
	var opcodes:Array=[]
	var next:int
	if token_type_at(tokens,7)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_CLEAR,
			tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],
			tokens[6][BEConstants.TK_VALUE],1
		]
		next=7
	else:
		opcodes=[BEConstants.OP_CLEAR,
			tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],
			tokens[6][BEConstants.TK_VALUE],tokens[8][BEConstants.TK_VALUE]
		]
		next=9
	err=parse_modifiers(tokens,opcodes,next)
	if err.has_error():
		return err
	next=err.data
	return LanguageResult.new(OK,[next,opcodes])


func execute(macro:MacroInfo,opcodes:Array)->LanguageResult:
	if macro.mode!=MacroInfo.MODE_MASK:
		return LanguageResult.new(LanguageResult.ERR_ONLY_ON_MASKS,{"s_command":NAME})
	var vals:Array=macro.values.duplicate()
	var x0:int=get_value(opcodes,P_X0,macro)
	var x1:int=get_value(opcodes,P_X1,macro)
	var v0:int=get_value(opcodes,P_VALUE,macro)
	var hstep0:int=get_value(opcodes,P_HSTEP,macro)
	var hstep1:int=hstep0
	var hstep_ease:float=1.0
	var ptr:int=P_END
	while ptr<opcodes.size():
		if opcodes[ptr]==BEConstants.OP_HSTEP:
			hstep0=opcodes[ptr+BEHStep.P_S0]
			hstep1=opcodes[ptr+BEHStep.P_S1]
			hstep_ease=opcodes[ptr+BEHStep.P_EASE]
			ptr+=BEHStep.P_END
		else:
			ptr+=1
	var real_hstep:int
	if x1<x0:
		var t:int=x0
		x0=x1
		x1=t
	var weight:float
	var step_count:int=0
	v0=(1<<v0)&ParamMacro.MASK_VALUE_MASK
	for i in range(x0,x1+1):
		weight=range_lerp(i,x0,x1,0.0,1.0)
		real_hstep=lerp(hstep0,hstep1,ease(weight,hstep_ease))
		if (i>=0 or i<vals.size()) and (real_hstep>=0 or step_count==0):
			vals[i]=vals[i]&(~v0)|(v0<<ParamMacro.MASK_PASSTHROUGH_SHIFT)
		step_count+=1
		if step_count>=abs(real_hstep):
			step_count=0
	for i in macro.values.size():
		macro.values[i]=vals[i]
	return LanguageResult.new()
