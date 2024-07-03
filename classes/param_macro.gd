extends Macro
class_name ParamMacro

enum {PMM_ABSOLUTE,PMM_RELATIVE,PMM_MASK}
const MASK_PASSTHROUGH_SHIFT:int=32
const MASK_VALUE_MASK:int=0xffffffff


var mode:int
var tick_div:int=1 setget set_tick_div
var min_val:int
var max_val:int


func _init(limits:Array,_mode:int=PMM_RELATIVE)->void:
	mode=_mode
	set_limits(limits)


func set_tick_div(v:int)->void:
	tick_div=max(1,v)


func set_limits(limits:Array)->void:
	if limits.size()>1 and typeof(limits[0])==TYPE_INT and typeof(limits[1])==TYPE_INT:
		min_val=limits[0]
		max_val=limits[1]
	else:
		min_val=0
		max_val=0


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
	if mode==PMM_MASK or max_val==min_val:
		return value if value>MASK_VALUE_MASK else base_value
	elif mode==PMM_ABSOLUTE:
		return min_val if value<min_val else max_val if value>max_val else value
	value=base_value if value==PASSTHROUGH else base_value+value
	return min_val if value<min_val else max_val if value>max_val else value


func duplicate()->Macro:
	var np:ParamMacro=_duplicate(get_script().new([]))
	np.mode=mode
	np.tick_div=tick_div
	np.delay=delay
	np.min_val=min_val
	np.max_val=max_val
	return np
