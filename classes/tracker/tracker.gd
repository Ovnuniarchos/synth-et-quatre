extends Reference
class_name Tracker


signal position_changed(order,row)


const CONSTS=preload("res://classes/tracker/tracker_constants.gd")
const SONGL=preload("res://classes/song/song_limits.gd")


var playing:bool
var loop_track:bool
var recording:bool
var curr_sample:float
var curr_tick:int
var curr_row:int
var curr_order:int
var song_delay:int
var goto_order:int
var goto_next:int
var ticks_second:int
var ticks_row:int
var messages:Array
var voices:Array
var synth:Synth


func _init(syn:Synth)->void:
	playing=false
	curr_sample=0.0
	curr_tick=0
	curr_row=0
	curr_order=0
	song_delay=0
	voices.resize(SONGL.MAX_CHANNELS)
	messages.resize(CONSTS.SIG_MAX)
	synth=syn
	for i in SONGL.MAX_CHANNELS:
		voices[i]=FmVoice.new()
	reset()

func reset()->void:
	for i in SONGL.MAX_CHANNELS:
		voices[i].reset()
	curr_order=0
	curr_tick=0
	curr_row=0
	curr_sample=0.0
	song_delay=0
	goto_order=-1
	goto_next=-1
	messages.fill(null)
	ticks_second=GLOBALS.song.ticks_second
	ticks_row=GLOBALS.song.ticks_row

func play(from:int=-1)->void:
	if from!=-1:
		curr_order=from
		curr_tick=0
		curr_row=0
		curr_sample=0.0
		song_delay=0
		goto_order=-1
		goto_next=-1
		messages.fill(null)
	if from==0:
		ticks_second=GLOBALS.song.ticks_second
		ticks_row=GLOBALS.song.ticks_row
	playing=true
	recording=false
	loop_track=false

func play_track(from:int=-1)->void:
	play(from)
	loop_track=true

func record(from:int=-1)->void:
	play(from)
	recording=true

func pause()->void:
	playing=!playing

func stop()->void:
	playing=false
	curr_order=0
	curr_tick=0
	curr_row=0
	curr_sample=0.0
	synth.reset()

#

func _on_song_changed()->void:
	stop()
	ticks_second=GLOBALS.song.ticks_second
	ticks_row=GLOBALS.song.ticks_row

#

func gen_commands(song:Song,mix_rate:float,buffer_size:int,cmds:Array,order_start:Array=[])->Dictionary:
	if !playing:
		cmds[0]=CONSTS.CMD_END
		return {"play":false,"loop":-1}
	var max_wait:int=min(CONSTS.MAX_WAIT_TIME,buffer_size)
	var samples_tick:float=mix_rate/ticks_second
	var ptr:int=0
	var optr:int=0
	var buffer_left:float=buffer_size
	var buffer_pos:int=0
	var wait:int=0
	# Should not insert more than buf_size
	if curr_sample>=1.0:
		wait=floor(min(min(max_wait,samples_tick),curr_sample))
		cmds[ptr]=CONSTS.CMD_WAIT
		cmds[ptr+1]=wait-1
		ptr+=2
		buffer_left-=wait
	buffer_pos+=wait
	#
	while buffer_left>=1.0:
		if curr_tick==0:
			messages.fill(null)
		for chn in song.num_channels:
			voices[chn].process_tick(song,chn,curr_order,curr_row,curr_tick,messages)
			ptr=voices[chn].commit(chn,cmds,ptr)
		if messages[CONSTS.SIG_DELAY_SONG]!=null:
			song_delay=messages[CONSTS.SIG_DELAY_SONG]
			messages[CONSTS.SIG_DELAY_SONG]=null
		if messages[CONSTS.SIG_GOTO_NEXT]!=null:
			goto_next=messages[CONSTS.SIG_GOTO_NEXT]
			messages[CONSTS.SIG_GOTO_NEXT]=null
		if messages[CONSTS.SIG_GOTO_ORDER]!=null:
			goto_order=messages[CONSTS.SIG_GOTO_ORDER]
			goto_next=-1
			messages[CONSTS.SIG_GOTO_ORDER]=null
		if messages[CONSTS.SIG_TICKS_SEC]!=null:
			ticks_second=messages[CONSTS.SIG_TICKS_SEC]
			samples_tick=mix_rate/ticks_second
			messages[CONSTS.SIG_TICKS_SEC]=null
		if messages[CONSTS.SIG_TICKS_ROW]!=null:
			ticks_row=messages[CONSTS.SIG_TICKS_ROW]
			messages[CONSTS.SIG_TICKS_ROW]=null
		#
		optr=ptr
		curr_sample+=samples_tick
		wait=floor(min(min(max_wait,buffer_left),samples_tick))
		cmds[ptr]=CONSTS.CMD_WAIT
		cmds[ptr+1]=wait-1
		ptr+=2
		buffer_left-=wait
		buffer_pos+=wait
		#
		curr_tick+=1
		if song_delay>0:
			song_delay-=1
		else:
			if goto_order!=-1:
				order_start.append(buffer_pos)
				curr_tick=0
				curr_row=0
				if recording and goto_order<=curr_order:
					return {"play":false,"loop":goto_order}
				next_order(goto_order)
				goto_order=-1
				if needs_stop(song):
					return {"play":false,"loop":-1}
				emit_signal("position_changed",curr_order,curr_row)
			elif goto_next!=-1:
				order_start.append(buffer_pos)
				curr_tick=0
				curr_row=0 if goto_next>=song.pattern_length else goto_next
				next_order(curr_order+1)
				goto_next=-1
				if needs_stop(song):
					return {"play":false,"loop":-1}
				emit_signal("position_changed",curr_order,curr_row)
			if curr_tick>=ticks_row:
				curr_tick=0
				curr_row=curr_row+1
				if curr_row>=song.pattern_length:
					order_start.append(buffer_pos)
					curr_row=0
					next_order(curr_order+1)
					if needs_stop(song):
						return {"play":false,"loop":-1}
				emit_signal("position_changed",curr_order,curr_row)
	if cmds[optr]==CONSTS.CMD_WAIT:
		ptr=optr
	cmds[ptr]=CONSTS.CMD_END
	curr_sample-=buffer_size
	return {"play":true,"loop":-1.0}

func next_order(next:int)->void:
	if not loop_track:
		curr_order=next

func needs_stop(song:Song)->bool:
	if curr_order>=song.orders.size():
		curr_order=0
		return recording
	return false
