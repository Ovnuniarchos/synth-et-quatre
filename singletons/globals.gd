extends Node

signal song_changed
signal octave_changed(oct)

const KEYBOARD=[
	KEY_Z,KEY_S,KEY_X,KEY_D,KEY_C,KEY_V,KEY_G,KEY_B,KEY_H,KEY_N,KEY_J,KEY_M,
	KEY_Q,KEY_2,KEY_W,KEY_3,KEY_E,KEY_R,KEY_5,KEY_T,KEY_6,KEY_Y,KEY_7,KEY_U
]
const HEX_INPUT=[
	KEY_0,KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,
	KEY_8,KEY_9,KEY_A,KEY_B,KEY_C,KEY_D,KEY_E,KEY_F
]

var song:Song setget set_song
var curr_instrument:int setget set_instrument
var curr_octave:int setget set_octave
var curr_order:int

func _init():
	set_song(Song.new())
	curr_instrument=0
	curr_order=0
	curr_octave=4

#

func set_song(s:Song)->void:
	song=s
	curr_instrument=0
	curr_order=0
	emit_signal("song_changed")

func get_instrument(index:int=-1)->Instrument:
	if index<=0:
		index=curr_instrument
	return song.get_instrument(index)

func set_instrument(index:int)->void:
	if index>-1 and index<song.instrument_list.size():
		curr_instrument=index

func set_octave(oct:int)->void:
	curr_octave=clamp(oct,-1.0,10.0)
	emit_signal("octave_changed",curr_octave)

func goto_order(order:int)->void:
	var mx:int=song.orders.size()-1
	curr_order=clamp(order,0.0,mx)

#

func array_fill(array:Array,value,size:int=-1)->void:
	if size<0:
		size=array.size()
	else:
		array.resize(size)
	for i in range(0,array.size()):
		array[i]=value

func nvl(value,default):
	return value if value!=null else default
