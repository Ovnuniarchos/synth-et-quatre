extends Tabs

enum {ENABLED,SOLO,MUTE}


onready var chan_but:Control=$VSC/CCVBC/VBC/CNT/Channels/Scroll/HB/Channel
onready var delfx_but:Control=$VSC/CCVBC/VBC/CNT/Channels/Scroll/HB/DelFX
onready var addfx_but:Control=$VSC/CCVBC/VBC/CNT/Channels/Scroll/HB/AddFX
onready var sep:Control=$VSC/CCVBC/VBC/CNT/Channels/Scroll/HB/S
onready var channels:HBoxContainer=$VSC/CCVBC/VBC/CNT/Channels/Scroll/HB
onready var editor:PanelContainer=$VSC/CCVBC/VBC/Editor

var mute_status:Array

func _ready()->void:
	$VSC.split_offset=rect_size.y*-0.25
	$VSC/CCHSC/HSC.split_offset=rect_size.x*0.25
	mute_status.resize(Song.MAX_CHANNELS)
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	delfx_but.connect("pressed",self,"_on_DelFX_pressed",[0])
	addfx_but.connect("pressed",self,"_on_AddFX_pressed",[0])
	chan_but.connect("cycled",self,"_on_Channel_cycled",[0])
	_on_song_changed()
	connect("resized",editor,"_on_container_resized",[self])
	editor._on_container_resized(self)

func _on_song_changed()->void:
	for i in range(Song.MAX_CHANNELS):
		mute_status[i]=ENABLED
	GLOBALS.song.connect("channels_changed",self,"_on_channels_changed")
	_on_channels_changed()

func _on_channels_changed()->void:
	var song:Song=GLOBALS.song
	for chl in channels.get_children():
		if !(chl in [chan_but,delfx_but,addfx_but,sep]):
			channels.remove_child(chl)
			chl.queue_free()
	delfx_but.disabled=song.num_fxs[0]==song.MIN_FX_LENGTH
	addfx_but.disabled=song.num_fxs[0]==song.MAX_FX_LENGTH
	chan_but.rect_min_size.x=64.0+(song.num_fxs[0]*48.0)
	chan_but.text=("F%d" if song.num_fxs[0]<1 else "FM %d")%[1]
	chan_but.status=mute_status[0]
	for i in range(1,song.num_channels):
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
		editor.update_tilemap()

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
	GLOBALS.muted_mask=mask
	SYNTH.mute_voices(mask)
