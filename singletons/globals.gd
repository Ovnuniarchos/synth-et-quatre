extends Node

signal song_changed
signal octave_changed(octave)
signal instrument_changed(instrument,inst_name)
# warning-ignore:unused_signal
signal tab_changed(tab)

var song:Song
var curr_instrument:int setget set_instrument
var curr_octave:int setget set_octave
var curr_order:int setget goto_order
var curr_arp:Arpeggio
var arp_ticks:int=1
var muted_mask:int=0


func _init():
	set_song(Song.new())
	curr_arp=null
	curr_instrument=0
	curr_order=0
	curr_octave=4

#

func set_song(s:Song)->void:
	song=s
	curr_instrument=0
	curr_order=0
	curr_arp=null
	emit_signal("song_changed")

func get_instrument(index:int=-1)->Instrument:
	if index<=0:
		index=curr_instrument
	return song.get_instrument(index)

func set_instrument(index:int)->void:
	if index>-1 and index<song.instrument_list.size():
		curr_instrument=index
		emit_signal("instrument_changed",index,get_instrument_name(index))

func get_instrument_name(index:int=-1)->String:
	if index<=0:
		index=curr_instrument
	var instr:Instrument=song.get_instrument(index)
	return "--" if instr==null else instr.name

func set_octave(oct:int)->void:
	curr_octave=clamp(oct,0.0,10.0)
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
	array.fill(value)

func nvl(value,default):
	return value if value!=null else default

func translate_filetypes(dict:Dictionary)->PoolStringArray:
	var a:Array=[]
	for i in dict:
		a.append(i+" ; "+tr(dict[i]))
	return PoolStringArray(a)
