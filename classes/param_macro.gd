extends Reference
class_name ParamMacro

var loop_start:int=-1 setget set_loop_start
var loop_end:int=-1 setget set_loop_end
var values:Array setget set_values
var steps:int=0 setget set_steps
var relative:bool=true
var tick_div:int=1
var delay:int=0

var loop_size:int=1


func get_value(tick:int,release_tick:int,base_value:int)->int:
	if steps==0 or tick<delay:
		return base_value
	tick-=delay
	var macro_tick:int=tick/tick_div
	if loop_start==-1:
		if macro_tick>=steps:
			macro_tick=steps-1
	elif macro_tick>loop_end:
		if loop_end==steps-1:
			macro_tick=((macro_tick-loop_start)%loop_size)+loop_start
		elif release_tick>-1:
			macro_tick=((tick-release_tick)/tick_div)+loop_end
			if macro_tick>=steps:
				macro_tick=steps-1
		else:
			macro_tick=((macro_tick-loop_start)%loop_size)+loop_start
	return base_value+values[macro_tick] if relative else values[macro_tick]

func duplicate()->ParamMacro:
	var np:ParamMacro=get_script().new()
	np.loop_start=loop_start
	np.loop_end=loop_end
	np.values=values.duplicate()
	np.relative=relative
	np.steps=steps
	np.tick_div=tick_div
	np.delay=delay
	np.loop_size=loop_size
	return np

func set_loop_start(v:int)->void:
	loop_start=clamp(v,-1,steps-1)
	if loop_start==-1:
		loop_end=-1
	normalize_loop_points()

func normalize_loop_points()->void:
	if loop_end<loop_start:
		loop_end=loop_start
	loop_size=(loop_end-loop_start)+1

func set_loop_end(v:int)->void:
	if loop_start==-1:
		loop_end=-1
	else:
		loop_end=clamp(v,-1,steps-1)
	normalize_loop_points()

func set_values(a:Array)->void:
	values=a.duplicate()

func set_steps(v:int)->void:
	steps=clamp(v,0,256)
	loop_start=min(loop_start,steps)
	loop_end=min(loop_end,steps)
	normalize_loop_points()
