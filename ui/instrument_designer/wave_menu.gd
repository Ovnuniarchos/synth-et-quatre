extends OptionButton

const DEFAULT_ITEMS=["FMED_DEFW_RECTANGLE","FMED_DEFW_SAW","FMED_DEFW_TRIANGLE","FMED_DEFW_NOISE"]

var delayed_ix:int=-1

func _ready():
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	_on_song_changed()

func _on_song_changed()->void:
	GLOBALS.song.connect("wave_list_changed",self,"update_waves")
	GLOBALS.song.connect("wave_changed",self,"_on_wave_changed")
	update_waves()

func _on_wave_changed(wave:Waveform,ix:int)->void:
	ix+=SongLimits.MIN_CUSTOM_WAVE
	if ix>=get_item_count():
		return
	set_item_text(ix,item_name(wave,ix))

func update_waves()->void:
	var ix:int=selected
	clear()
	var id:int=0
	for i in DEFAULT_ITEMS:
		add_item(i,id)
		id+=1
	for i in GLOBALS.song.wave_list:
		add_item(item_name(i,id))
		id+=1
	select(ix if delayed_ix==-1 else delayed_ix)
	delayed_ix=-1

func item_name(wave:Waveform,ix:int)->String:
	var s:String="%02X %s"%[ix,wave.name]
	if s.length()>32:
		s=s.left(31)+"…"
	return s

func select(ix:int)->void:
	if ix<get_item_count():
		.select(ix)
	else:
		delayed_ix=ix
