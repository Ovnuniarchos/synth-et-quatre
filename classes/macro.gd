extends Reference
class_name Macro

var loop_start:int=-1 setget set_loop_start
var loop_end:int=-1 setget set_loop_end
var release_loop_start:int=-1 setget set_release_loop_start
var values:Array setget set_values
var steps:int=0 setget set_steps
var delay:int=0

var loop_size:int=1
var release_loop_size:int=1


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
	release_loop_start=int(max(v,-1)) if v<steps else -1
	normalize_loop_points()

func set_values(a:Array)->void:
	values=a.duplicate()

func set_steps(v:int)->void:
	steps=clamp(v,0,256)
	loop_start=min(loop_start,steps)
	loop_end=min(loop_end,steps)
	normalize_loop_points()

func duplicate()->Macro:
	var np:Macro=get_script().new()
	np.steps=steps
	np.loop_start=loop_start
	np.loop_end=loop_end
	np.loop_size=loop_size
	np.release_loop_start=release_loop_start
	np.release_loop_size=release_loop_size
	np.values=values.duplicate()
	return np

func get_tick(tick:int,release_tick:int,tick_div:int)->int:
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

func get_release_tick(tick:int,tick0:int,tick_div:int)->int:
	tick=(tick/tick_div)+tick0
	if release_loop_start<0:
		return tick if tick<steps else steps-1
	elif tick>=release_loop_start:
		return ((tick-release_loop_start)%release_loop_size)+release_loop_start
	return tick
