extends Tabs

var arp:Arpeggio

onready var arp_name=get_node("%Name")
onready var arp_edit=get_node("%Values")


func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_arp_selected",[-1])
	_on_arp_selected(-1)


func _on_arp_selected(index:int)->void:
	arp=GLOBALS.song.get_arp(index)
	GLOBALS.curr_arp=arp
	if arp!=null:
		arp_name.text=arp.name
		arp_edit.visible=true
		arp_edit.set_macro(arp)
	else:
		arp_name.text=""
		arp_edit.visible=false


func _on_Name_text_changed(txt:String)->void:
	if arp!=null:
		arp.name=txt


func _on_Values_arp_changed(_parameter:String, values:Array, steps:int, loop_start:int, loop_end:int, release_loop_start:int, _relative:int, _tick_div:int, _delay:int):
	if arp==null:
		return
	arp.steps=steps
	arp.values=values
	arp.loop_start=loop_start
	arp.loop_end=loop_end
	arp.release_loop_start=release_loop_start
