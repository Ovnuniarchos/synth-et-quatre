extends Reference
class_name Tracker


signal position_changed(order,row)


const CONSTS=preload("res://classes/tracker/tracker_constants.gd")


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
var voices:Array
var synth:Synth


func _init(syn:Synth)->void:
	playing=false
	curr_sample=0.0
	curr_tick=0
	curr_row=0
	curr_order=0
	song_delay=0
	voices.resize(Song.MAX_CHANNELS)
	synth=syn
	for i in range(Song.MAX_CHANNELS):
		voices[i]=FmVoice.new()

func play(from:int=-1)->void:
	if from!=-1:
		curr_order=from
		curr_tick=0
		curr_row=0
		curr_sample=0.0
		song_delay=0
		goto_order=-1
		goto_next=-1
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

#

func gen_commands(song:Song,mix_rate:float,buf_size:int,cmds:Array)->bool:
	if !playing:
		cmds[0]=255
		return false
	var samples_tick:float=mix_rate/song.ticks_second
	var ptr:int=0
	var bs:float=0.0
	var ibuf_size:int=buf_size
	var last_wait:int=0
	# Should not insert more than buf_size
	if curr_sample>=1.0:
		bs=min(min(256.0,ibuf_size),floor(curr_sample))
		while bs>=1.0 and ibuf_size>0:
			cmds[ptr]=CONSTS.CMD_WAIT
			cmds[ptr+1]=bs-1
			curr_sample-=bs
			ibuf_size-=bs
			ptr+=2
			bs=min(min(256.0,ibuf_size),floor(curr_sample))
	if ibuf_size<=0:
		cmds[last_wait]=CONSTS.CMD_END
		return true
	#
	var spt:float
	var dbs:float
	bs=ibuf_size
	var sig_cmd:int
	var sig:int
	while bs>=1.0:
		for chn in range(song.num_channels):
			sig=voices[chn].process_tick(song,chn,curr_order,curr_row,curr_tick)
			sig_cmd=sig&CONSTS.SIG_CMD_MASK
			if sig_cmd==CONSTS.SIG_DELAY_SONG:
				song_delay=sig&CONSTS.SIG_VAL_MASK
			elif sig_cmd==CONSTS.SIG_GOTO_ORDER:
				goto_order=sig&CONSTS.SIG_VAL_MASK
			elif sig_cmd==CONSTS.SIG_GOTO_NEXT:
				goto_next=sig&CONSTS.SIG_VAL_MASK
			ptr=voices[chn].commit(chn,cmds,ptr)
		#
		curr_tick+=1
		if song_delay<=0:
			 # FUTURE: uniorder play
			if goto_order!=-1:
				curr_tick=0
				curr_row=0
				next_order(goto_order)
				goto_order=-1
				if needs_stop(song):
					return false
				DEBUG.set_var("order",curr_order)
				DEBUG.set_var("row",curr_row)
				emit_signal("position_changed",curr_order,curr_row)
			elif goto_next!=-1:
				curr_tick=0
				curr_row=0 if goto_next>=song.pattern_length else goto_next
				next_order(curr_order+1)
				goto_next=-1
				if needs_stop(song):
					return false
				DEBUG.set_var("order",curr_order)
				DEBUG.set_var("row",curr_row)
				emit_signal("position_changed",curr_order,curr_row)
			if curr_tick>=song.ticks_row:
				curr_tick=0
				curr_row=curr_row+1
				if curr_row>=song.pattern_length:
					curr_row=0
					next_order(curr_order+1)
					if needs_stop(song):
						return false
				DEBUG.set_var("order",curr_order)
				DEBUG.set_var("row",curr_row)
				emit_signal("position_changed",curr_order,curr_row)
			DEBUG.unset_var("SD")
		else:
			DEBUG.set_var("SD",song_delay)
			song_delay-=1
		#
		spt=samples_tick
		last_wait=ptr
		while spt>=1.0 and bs>=1.0:
			dbs=min(256.0,spt)
			cmds[ptr]=CONSTS.CMD_WAIT
			cmds[ptr+1]=dbs-1
			spt-=dbs
			bs-=dbs
			ptr+=2
		if bs<1.0:
			break
	curr_sample=spt
	cmds[last_wait]=CONSTS.CMD_END
	return true

func next_order(next:int)->void:
	if not loop_track:
		curr_order=next

func needs_stop(song:Song)->bool:
	if curr_order>=song.orders.size():
		curr_order=0
		return recording
	return false
