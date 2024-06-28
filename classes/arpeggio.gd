extends Macro
class_name Arpeggio

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
	if value==PASSTHROUGH:
		return base_value
	return base_value+value

func duplicate()->Macro:
	var na:Arpeggio=.duplicate()
	na.name=name
	return na
