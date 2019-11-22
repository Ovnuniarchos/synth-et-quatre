extends AudioStreamPlayer

signal buffer_sent(buffer)

var tracker:Tracker

var cmds:Array=Array()

func _ready()->void:
	tracker=Tracker.new(SYNTH)
	SYNTH.set_mix_rate(stream.mix_rate)
	GLOBALS.connect("song_changed",tracker,"_on_song_changed")
	cmds.resize(65536)
	play()

# warning-ignore:unused_argument
func _process(delta:float)->void:
	var playback:AudioStreamPlayback=get_stream_playback()
	var size:int=playback.get_frames_available()
	if size>0 and playback.can_push_buffer(size):
		tracker.gen_commands(GLOBALS.song,stream.mix_rate,size,cmds)
		var buf:PoolVector2Array=SYNTH.generate(size,cmds,1.0)
		playback.push_buffer(buf)
		emit_signal("buffer_sent",buf)
