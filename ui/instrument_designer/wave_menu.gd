extends OptionButton

const DEFAULT_ITEMS=["Rectangle","Saw","Triangle","Noise"]

var delayed_ix:int=-1

func _ready():
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	_on_song_changed()

func _on_song_changed()->void:
	GLOBALS.song.connect("wave_list_changed",self,"update_waves")
	update_waves()

func update_waves()->void:
	var ix:int=selected
	clear()
	var id:int=0
	for i in DEFAULT_ITEMS:
		add_item(i,id)
		id+=1
	for i in GLOBALS.song.wave_list:
		add_item("%02X %s"%[id,i.name.left(8)])
		id+=1
	select(ix if delayed_ix==-1 else delayed_ix)
	delayed_ix=-1

func select(ix:int)->void:
	if ix<get_item_count():
		.select(ix)
	else:
		delayed_ix=ix
