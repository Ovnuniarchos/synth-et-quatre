extends Reference
class_name VoiceMacro

var loop_start:int=-1
var loop_end:int=-1
var values:Array
var relative:bool=true
var steps:int=0
var tick_div:int=1
var delay:int=0

var loop_size:int=(loop_end-loop_start)%1


func get_value(tick:int,release_tick:int,default:float)->float:
	if steps==0:
		return default
	var macro_tick:int=tick/tick_div
	if loop_start==-1:
		if macro_tick>=steps:
			macro_tick=steps-1
	elif macro_tick>loop_end:
		if release_tick>-1:
			macro_tick=((tick-release_tick)/tick_div)+loop_end
			if macro_tick>=steps:
				macro_tick=steps-1
		else:
			macro_tick=((macro_tick-loop_start)%loop_size)+loop_start
	return values[macro_tick]
