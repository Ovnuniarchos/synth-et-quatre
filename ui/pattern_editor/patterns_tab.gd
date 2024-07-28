extends Tabs


enum {ENABLED,SOLO,MUTE}


onready var channels:HBoxContainer=$VSC/CCVBC/VBC/CNT/Channels/Scroll/HB
onready var editor:PanelContainer=$VSC/CCVBC/VBC/Editor

var mute_status:Array
var cell_size:Vector2
var channel_group:PackedScene=preload("channel_buttons.tscn")


func _ready()->void:
	cell_size=Vector2(ThemeHelper.get_constant("cell_w","Tracker"),ThemeHelper.get_constant("cell_h","Tracker"))
	$VSC.split_offset=rect_size.y*-0.25
	$VSC/CCHSC/HSC.split_offset=rect_size.x*0.25
	$VSC/CCVBC/VBC/CNT/Channels/LineColumn.rect_min_size.x=cell_size.x*4.0
	channels.add_constant_override("separation",cell_size.x*2.0)
	mute_status.resize(SongLimits.MAX_CHANNELS)
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	_on_song_changed()
	connect("resized",editor,"_on_container_resized",[self])
	editor._on_container_resized(self)


func _on_song_changed()->void:
	for i in SongLimits.MAX_CHANNELS:
		mute_status[i]=ENABLED
	GLOBALS.muted_mask=0
	SYNTH.mute_voices(0)
	GLOBALS.song.connect("channels_changed",self,"_on_channels_changed")
	_on_channels_changed()


func _on_channels_changed()->void:
	var song:Song=GLOBALS.song
	for chg in channels.get_children():
		channels.remove_child(chg)
		chg.queue_free()
	for i in range(song.num_channels):
		var chg:ChannelButtons=channel_group.instance()
		chg.channel_ix=i
		chg.cell_size=cell_size
		chg.mute_status=mute_status[i]
		chg.connection_object=self
		chg.add_method="_on_AddFX_pressed"
		chg.del_method="_on_DelFX_pressed"
		chg.mute_method="_on_Channel_cycled"
		channels.add_child(chg)
	editor.set_bg_rows(song.pattern_length)


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


func _on_Info_focus_exited():
	if editor!=null and editor.is_ready:
		editor.grab_focus()
