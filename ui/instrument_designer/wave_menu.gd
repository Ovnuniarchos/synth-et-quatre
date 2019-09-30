extends OptionButton

const DEFAULT_ITEMS=["Rectangle","Saw","Triangle","Noise"]

func _ready():
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
	select(ix)
