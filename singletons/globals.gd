extends Node

signal song_changed
signal octave_changed(oct)

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
	for w in song.wave_list:
		song.send_wave(w)
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
