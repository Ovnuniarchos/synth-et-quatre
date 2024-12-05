extends BECommand
class_name BESmooth


const NAME:String="SMOOTH"
enum{
	P_OP,P_X0,P_X1,P_SIZE,P_CURVE,P_ALPHA,P_END
}


func parse(tokens:Array,is_cmd:bool)->LanguageResult:
	var err:LanguageResult=common_checks(tokens,is_cmd,true,BEConstants.COMMANDS[NAME])
	if err.has_error():
		return err
	var opcodes:Array=[]
	var next:int
	if token_type_at(tokens,5)==BEConstants.TOKEN_WHITESPACE:
		opcodes=[BEConstants.OP_SMOOTH,
			tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],
			1,1.0,1.0
		]
		next=5
	else:
		err=check_values(tokens[6])
		if err!=null:
			return err
		if token_type_at(tokens,7)==BEConstants.TOKEN_WHITESPACE:
			opcodes=[BEConstants.OP_SMOOTH,
				tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],
				tokens[6][BEConstants.TK_VALUE],1.0,1.0
			]
			next=7
		elif token_type_at(tokens,9)==BEConstants.TOKEN_WHITESPACE:
			opcodes=[BEConstants.OP_SMOOTH,
				tokens[2][BEConstants.TK_VALUE],tokens[4][BEConstants.TK_VALUE],
				tokens[6][BEConstants.TK_VALUE],tokens[8][BEConstants.TK_VALUE],
				1.0
			]
			next=9
		else:
			opcodes=[BEConstants.OP_SMOOTH,
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


func check_values(token:Array)->LanguageResult:
	if token[BEConstants.TK_VALUE]<1.0 or token[BEConstants.TK_VALUE]>ParamMacro.MAX_STEPS:
		return LanguageResult.new(LanguageResult.ERR_MUST_BE_GE,{"n_min":1.0,"n_max":ParamMacro.MAX_STEPS,
			"i_start":token[BEConstants.TK_START],"i_end":token[BEConstants.TK_END]})
	return null


func execute(macro:MacroInfo,opcodes:Array)->LanguageResult:
	if not macro.can_use_alpha():
		return LanguageResult.new(LanguageResult.ERR_NOT_ON_MASKS_OR_SELS,{"s_command":NAME})
	var vals:Array=macro.values.duplicate()
	var x0:int=get_value(opcodes,P_X0,macro)
	var x1:int=get_value(opcodes,P_X1,macro)
	var size:int=get_value(opcodes,P_SIZE,macro)
	var curve0:float=get_value(opcodes,P_CURVE,macro)
	var curve1:float=curve0
	var curve_ease:float=1.0
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
			curve0=opcodes[ptr+BEEase.P_E0]
			curve1=opcodes[ptr+BEEase.P_E1]
			curve_ease=opcodes[ptr+BEEase.P_EASE]
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
	var real_curve:float
	var real_alpha:float
	var real_hstep:int
	var real_vstep:int
	if x1<x0:
		var t:int=x0
		x0=x1
		x1=t
	var val:float
	var weight:float
	var step_count:int=0
	var weights_list:Array=[]
	var vals_list:Array=[]
	var val_sum:float
	var wgt_sum:float
	for i in range(x0,x1+1):
		weight=range_lerp(i,x0,x1,0.0,1.0)
		real_curve=lerp(curve0,curve1,ease(weight,curve_ease))
		real_alpha=lerp(alpha0,alpha1,ease(weight,alpha_ease))
		real_hstep=lerp(hstep0,hstep1,ease(weight,hstep_ease))
		real_vstep=lerp(vstep0,vstep1,ease(weight,vstep_ease))
		if step_count==0:
			weights_list.resize(0)
			vals_list.resize(0)
			fetch_values(i,macro.values,1.0,vals_list,weights_list)
			for j in range(1,size+1):
				weight=1.0 if is_zero_approx(real_curve) else ease(range_lerp(j,0.0,size+1.0,0.0,1.0),real_curve)
				fetch_values(i+j,macro.values,weight,vals_list,weights_list)
				fetch_values(i-j,macro.values,weight,vals_list,weights_list)
			val_sum=0.0
			wgt_sum=0.0
			for j in vals_list.size():
				val_sum+=vals_list[j]
				wgt_sum+=weights_list[j]
			val=val_sum/wgt_sum if wgt_sum>0.0 else 0.0
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


func fetch_values(ix:int,values:Array,weight:float,res_val:Array,res_wgt:Array)->void:
	if ix<0 or ix>=values.size() or values[ix]==ParamMacro.PASSTHROUGH:
		return
	res_val.append(values[ix]*weight)
	res_wgt.append(weight)
