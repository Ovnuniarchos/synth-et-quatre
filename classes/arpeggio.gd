extends Macro
class_name Arpeggio


const CONSTS=preload("res://classes/tracker/fm_voice_constants.gd")


var name:String
var file_name:String


func _init()->void:
	name="Arp"


func get_value(tick:int,release_tick:int,base_value:int,tick_div:int)->int:
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
	value=base_value if value==PASSTHROUGH else base_value+value
	return CONSTS.MIN_FREQ if value<CONSTS.MIN_FREQ else CONSTS.MAX_FREQ if value>CONSTS.MAX_FREQ else value


func duplicate()->Macro:
	var na:Arpeggio=_duplicate(get_script().new())
	na.name=name
	return na
