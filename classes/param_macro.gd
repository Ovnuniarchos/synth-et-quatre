extends Macro
class_name ParamMacro

const MASK_PASSTHROUGH_SHIFT:int=32
const MASK_VALUE_MASK:int=0xffffffff

var relative:bool=true
var tick_div:int=1 setget set_tick_div


func _init(rel:bool=true)->void:
	relative=rel


func set_tick_div(v:int)->void:
	tick_div=max(1,v)


func get_value(tick:int,release_tick:int,base_value:int)->int:
	if steps==0 or tick<delay:
		return base_value
	tick-=delay
	var macro_tick:int
	if release_tick>-1 and release_loop_start>-1:
		release_tick-=delay
		macro_tick=get_release_tick(
			tick-release_tick,
			get_tick(release_tick,-1,tick_div),
			tick_div)
	else:
		macro_tick=get_tick(tick,release_tick-delay,tick_div)
	var value:int=values[macro_tick]
	if value==PASSTHROUGH:
		return base_value
	return base_value+value if relative else value


func duplicate()->Macro:
	var np:ParamMacro=.duplicate()
	np.relative=relative
	np.tick_div=tick_div
	np.delay=delay
	return np
