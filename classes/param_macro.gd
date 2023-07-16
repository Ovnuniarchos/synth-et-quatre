extends Reference
class_name ParamMacro

var loop_start:int=-1 setget set_loop_start
var loop_end:int=-1 setget set_loop_end
var release_loop_start:int=-1 setget set_release_loop_start
var values:Array setget set_values
var steps:int=0 setget set_steps
var relative:bool=true
var tick_div:int=1
var delay:int=0

var loop_size:int=1
var release_loop_size:int=1


func _init(rel:bool=true)->void:
	relative=rel

func get_tick(tick:int,release_tick:int)->int:
	tick/=tick_div
	if loop_start<0:
		return tick if tick<steps else steps-1
	elif tick>=loop_start:
		if release_tick<0 or (loop_end==steps-1):
			return ((tick-loop_start)%loop_size)+loop_start
		else:
			tick=((release_tick-loop_start)%loop_size)+loop_start+(tick-release_tick)
			return tick if tick<steps else steps-1
	return tick

func get_release_tick(tick:int,tick0:int)->int:
	tick=(tick/tick_div)+tick0
	if release_loop_start<0:
		return tick if tick<steps else steps-1
	elif tick>=release_loop_start:
		return ((tick-release_loop_start)%release_loop_size)+release_loop_start
	return tick

func get_value(tick:int,release_tick:int,base_value:int)->int:
	if steps==0 or tick<delay:
		return base_value
	tick-=delay
	var macro_tick:int
	if release_tick>-1 and release_loop_start>-1:
		release_tick-=delay
		macro_tick=get_release_tick(tick-release_tick,get_tick(release_tick,-1))
	else:
		release_tick-=delay
		macro_tick=get_tick(tick,release_tick)
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
	release_loop_size=steps-release_loop_start

func set_loop_end(v:int)->void:
	if loop_start==-1:
		loop_end=-1
	else:
		loop_end=clamp(v,-1,steps-1)
	normalize_loop_points()

func set_release_loop_start(v:int)->void:
	release_loop_start=clamp(v,-1,steps-1)
	normalize_loop_points()

func set_values(a:Array)->void:
	values=a.duplicate()

func set_steps(v:int)->void:
	steps=clamp(v,0,256)
	loop_start=min(loop_start,steps)
	loop_end=min(loop_end,steps)
	normalize_loop_points()
