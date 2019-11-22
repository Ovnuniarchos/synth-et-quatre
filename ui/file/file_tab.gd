extends Tabs

func _on_Save_pressed()->void:
	var f:ChunkedFile=ChunkedFile.new()
	f.open(".songs/tmp.txt",File.WRITE)
	GLOBALS.song.serialize(f)
	f.close()

func _on_Load_pressed()->void:
	var f:ChunkedFile=ChunkedFile.new()
	f.open(".songs/tmp.txt",File.READ)
	var new_song:Song=GLOBALS.song.deserialize(f)
	f.close()
	if new_song!=null:
		GLOBALS.song=new_song

func _on_CleanPats_pressed()->void:
	GLOBALS.song.clean_patterns()

func _on_CleanInsts_pressed()->void:
	GLOBALS.song.clean_instruments()

const BUFFER_SIZE=2048

func _on_SaveWav_pressed()->void:
	var synth:Synth=Synth.new()
	var tracker:Tracker=Tracker.new(synth)
	var file:WaveFile=WaveFile.new()
	var cmds:Array=[]
	cmds.resize(65536)
	synth.set_mix_rate(11025.0)
	tracker.record()
	file.start_file(".songs/z.wav",false,11025)
	while tracker.gen_commands(GLOBALS.song,11025.0,BUFFER_SIZE,cmds):
		file.write_chunk(synth.generate(BUFFER_SIZE,cmds,1.0))
	file.end_file()
