extends Reference
class_name Tracker

signal position_changed(order,row)

enum{
	CMD_WAIT=0,
	CMD_DEBUG=254,
	CMD_END=255
}
const ATTRS=Pattern.ATTRS
const LG_MODE=Pattern.LEGATO_MODE
const DEFAULT_VOLUME:int=255
const DEFAULT_PAN:int=31

var playing:bool
var curr_sample:float
var curr_tick:int
var curr_row:int
var curr_order:int
var voices:Array

func _init()->void:
	playing=false
	curr_sample=0.0
	curr_tick=0
	curr_row=0
	curr_order=0
	voices.resize(Song.MAX_CHANNELS)
	for i in range(Song.MAX_CHANNELS):
		voices[i]=FmVoice.new()

func play(from:int=-1)->void:
	if from!=-1:
		curr_order=from
		curr_tick=0
		curr_row=0
		curr_sample=0.0
	playing=true

func pause()->void:
	playing=!playing

func stop()->void:
	playing=false
	curr_order=0
	curr_tick=0
	curr_row=0
	curr_sample=0.0
	SYNTH.reset()

#

func _on_song_changed()->void:
	stop()

#

func gen_commands(song:Song,mix_rate:float,buf_size:int,cmds:Array)->void:
	if !playing:
		cmds[0]=255
		return
	var samples_tick:float=mix_rate/song.ticks_second
	var ptr:int=0
	var bs:float=0.0
	var ibuf_size:int=buf_size
	var last_wait:int=0
	# Should not insert more than buf_size
	if curr_sample>=1.0:
		bs=min(min(256.0,ibuf_size),floor(curr_sample))
		while bs>=1.0 and ibuf_size>0:
			cmds[ptr]=CMD_WAIT
			cmds[ptr+1]=bs-1
			curr_sample-=bs
			ibuf_size-=bs
			ptr+=2
			bs=min(min(256.0,ibuf_size),floor(curr_sample))
	if ibuf_size<=0:
		cmds[last_wait]=CMD_END
		return
	#
	var spt:float
	var dbs:float
	bs=ibuf_size
	while bs>=1.0:
		for chn in range(song.num_channels):
			if curr_tick==0:
				voices[chn].reset_row(song,chn,curr_order,curr_row)
			voices[chn].process_tick(song,chn,curr_order,curr_row,curr_tick)
			ptr=voices[chn].commit(chn,cmds,ptr)
		curr_tick+=1
		if curr_tick>=song.ticks_row:
			curr_tick=0
			curr_row=curr_row+1
			if curr_row>=song.pattern_length:
				curr_row=0
				curr_order=(curr_order+1)%song.orders.size()
			DEBUG.set_var("order",curr_order)
			DEBUG.set_var("row",curr_row)
			emit_signal("position_changed",curr_order,curr_row)
		spt=samples_tick
		last_wait=ptr
		while spt>=1.0 and bs>=1.0:
			dbs=min(256.0,spt)
			cmds[ptr]=CMD_WAIT
			cmds[ptr+1]=dbs-1
			spt-=dbs
			bs-=dbs
			ptr+=2
		if bs<1.0:
			break
	curr_sample=spt
	cmds[last_wait]=CMD_END
