extends HBoxContainer
class_name ChannelButtons


var channel_ix:int
var cell_size:Vector2
var mute_status:int
var connection_object:Object
var add_method:String
var del_method:String
var mute_method:String


func _ready()->void:
	var t:Theme=THEME.get("theme")
	var del:Button=$DelFX
	var add:Button=$AddFX
	var channel:CycleButton=$Channel
	var song:Song=GLOBALS.song
	var nfx:int=song.num_fxs[channel_ix]
	rect_min_size.x=(14+nfx*6)*cell_size.x
	del.disabled=nfx==SongLimits.MIN_FX_LENGTH
	del.connect("pressed",connection_object,del_method,[channel_ix])
	add.disabled=nfx==SongLimits.MAX_FX_LENGTH
	add.connect("pressed",connection_object,add_method,[channel_ix])
	channel.colors=PoolColorArray([Color.white,t.get_color("solo","Tracker"),t.get_color("muted","Tracker")])
	channel.text=tr("PTEDIT_CHANNEL_BUTTON")%[channel_ix+1]
	channel.status=mute_status
	channel.connect("cycled",connection_object,mute_method,[channel_ix])
