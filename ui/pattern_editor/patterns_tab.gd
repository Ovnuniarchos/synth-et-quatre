extends Tabs

enum {ENABLED,SOLO,MUTE}

onready var chan_but:Control=$VSC/VBC/CNT/Channels/Scroll/HB/Channel
onready var delfx_but:Control=$VSC/VBC/CNT/Channels/Scroll/HB/DelFX
onready var addfx_but:Control=$VSC/VBC/CNT/Channels/Scroll/HB/AddFX
onready var sep:Control=$VSC/VBC/CNT/Channels/Scroll/HB/S
onready var channels:HBoxContainer=$VSC/VBC/CNT/Channels/Scroll/HB

var mute_status:Array

func _ready()->void:
	mute_status.resize(Song.MAX_CHANNELS)
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	_on_song_changed()
	connect("resized",$VSC/VBC/Editor,"_on_container_resized",[self])
	$VSC/VBC/Editor._on_container_resized(self)

func _on_song_changed()->void:
	for i in range(Song.MAX_CHANNELS):
		mute_status[i]=ENABLED
	GLOBALS.song.connect("channels_changed",self,"_on_channels_changed",[true])
	_on_channels_changed(false)

func _on_channels_changed(delete:bool)->void:
	var song:Song=GLOBALS.song
	for chl in channels.get_children():
		if delete:
			chl.queue_free()
		else:
			channels.remove_child(chl)
	for i in range(0,song.num_channels):
		var nb:Button=delfx_but.duplicate()
		nb.connect("pressed",self,"_on_DelFX_pressed",[i])
		nb.disabled=song.num_fxs[i]==song.MIN_FX_LENGTH
		channels.add_child(nb)
		nb=addfx_but.duplicate()
		nb.connect("pressed",self,"_on_AddFX_pressed",[i])
		nb.disabled=song.num_fxs[i]==song.MAX_FX_LENGTH
		channels.add_child(nb)
		nb=chan_but.duplicate()
		nb.rect_min_size.x=64.0+(song.num_fxs[i]*48.0)
		nb.text=("F%d" if song.num_fxs[i]<1 else "FM %d")%[i+1]
		nb.status=mute_status[i]
		nb.connect("cycled",self,"_on_Channel_cycled",[i])
		channels.add_child(nb)
		channels.add_child(sep.duplicate())

func _on_editor_horizontal_scroll(offset:float)->void:
	channels.margin_left=offset

func _on_goto_position(pos:int)->void:
	if GLOBALS.curr_order==pos:
		$VSC/VBC/Editor.update_tilemap()

func _on_CNT_sort_children()->void:
	$VSC/VBC/CNT.rect_min_size.y=$VSC/VBC/CNT/Channels.rect_size.y

func _on_DelFX_pressed(chan:int)->void:
	GLOBALS.song.mod_fx_channel(chan,-1)

func _on_AddFX_pressed(chan:int)->void:
	GLOBALS.song.mod_fx_channel(chan,1)

func _on_Channel_cycled(status:int,chan:int)->void:
	mute_status[chan]=status
	var song:Song=GLOBALS.song
	var mask:int=0
	var solo:bool=false
	for i in range(song.num_channels):
		if mute_status[i]==SOLO:
			solo=true
			break
		mask|=(1<<i) if mute_status[i]==MUTE else 0
	if solo:
		mask=0
		for i in range(song.num_channels):
			mask|=(1<<i) if mute_status[i]==SOLO else 0
		mask^=0xffffffff
	SYNTH.mute_voices(mask)
