extends Tabs

const BUFFER_SIZE=2048


enum FILE_MODE{LOAD,SAVE,SAVE_WAV}


var file_mode:int


func _on_New_pressed():
	pass # Replace with function body.

func _on_Save_pressed()->void:
	file_mode=FILE_MODE.SAVE
	$FileDialog.window_title="Save Song"
	$FileDialog.mode=FileDialog.MODE_SAVE_FILE
	$FileDialog.popup_centered_ratio()

func _on_Load_pressed()->void:
	file_mode=FILE_MODE.LOAD
	$FileDialog.window_title="Load Song"
	$FileDialog.mode=FileDialog.MODE_OPEN_FILE
	$FileDialog.popup_centered_ratio()

func _on_SaveWav_pressed()->void:
	file_mode=FILE_MODE.SAVE_WAV
	$FileDialog.window_title="Export as Wave"
	$FileDialog.mode=FileDialog.MODE_SAVE_FILE
	$FileDialog.popup_centered_ratio()

#

func _on_CleanPats_pressed()->void:
	AUDIO.tracker.stop()
	GLOBALS.song.clean_patterns()

func _on_CleanInsts_pressed()->void:
	AUDIO.tracker.stop()
	GLOBALS.song.clean_instruments()

func _on_CleanWaves_pressed():
	AUDIO.tracker.stop()
	GLOBALS.song.clean_waveforms()

#

func _on_file_selected(path:String)->void:
	if file_mode==FILE_MODE.SAVE:
		var f:ChunkedFile=ChunkedFile.new()
		f.open(path,File.WRITE)
		GLOBALS.song.serialize(f)
		f.close()
	elif file_mode==FILE_MODE.LOAD:
		var f:ChunkedFile=ChunkedFile.new()
		f.open(path,File.READ)
		var new_song:Song=GLOBALS.song.deserialize(f)
		f.close()
		if new_song!=null:
			AUDIO.tracker.stop()
			GLOBALS.song=new_song
	elif file_mode==FILE_MODE.SAVE_WAV:
		var synth:Synth=Synth.new()
		var tracker:Tracker=Tracker.new(synth)
		var file:WaveFile=WaveFile.new()
		var cmds:Array=[]
		cmds.resize(65536)
		synth.set_mix_rate(11025.0)
		GLOBALS.song.sync_waves(synth)
		file.start_file(path,false,11025)
		while tracker.gen_commands(GLOBALS.song,11025.0,BUFFER_SIZE,cmds):
			file.write_chunk(synth.generate(BUFFER_SIZE,cmds,1.0))
		file.end_file()
