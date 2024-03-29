extends AudioStreamPlayer

signal buffer_sent(buffer)

var tracker:Tracker

var cmds:Array=Array()

func _ready()->void:
	set_mix_rate(CONFIG.get_value(CONFIG.AUDIO_SAMPLERATE))
	set_buffer_length(CONFIG.get_value(CONFIG.AUDIO_BUFFERLENGTH))
	tracker=Tracker.new(SYNTH)
	GLOBALS.connect("song_changed",tracker,"_on_song_changed")
	cmds.resize(65536)
	play()

func set_mix_rate(mr:int)->void:
	stream.mix_rate=mr
	SYNCER.set_mix_rate(stream.mix_rate)
	play()

func set_buffer_length(bl:float)->void:
	stream.buffer_length=bl
	play()

func _process(_delta:float)->void:
	var playback:AudioStreamPlayback=get_stream_playback()
	var size:int=playback.get_frames_available()
	var buf:Array
	if size>0 and playback.can_push_buffer(size):
		tracker.gen_commands(GLOBALS.song,stream.mix_rate,size,cmds)
		buf=DSP.add_sound_streams(
			SYNTH.generate(size,cmds,1.0/GLOBALS.song.num_channels),
			IM_SYNTH.generate(size,[],IM_SYNTH.DEFAULT_VOLUME)
		)
		playback.push_buffer(PoolVector2Array(buf))
		emit_signal("buffer_sent",buf)

