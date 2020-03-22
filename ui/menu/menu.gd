tool extends PanelContainer

const BUFFER_SIZE=2048
const FILES_SE4=PoolStringArray(["*.se4 ; SynthEtQuatre song"])
const FILES_WAV=PoolStringArray(["*.wav ; WAV file"])


enum FILE_MODE{LOAD,SAVE,SAVE_WAV}


var file_mode:int
var real_theme:Theme
var base_height:float


func _ready()->void:
	$CC/HBC/Cleanup.get_popup().connect("id_pressed",self,"_on_Cleanup_id_pressed")
	if get_tree().edited_scene_root!=null:
		real_theme=get_tree().edited_scene_root.get_theme()
	else:
		real_theme=get_tree().current_scene.get_theme()
	rect_size.y=0.0
	base_height=$CC/HBC.rect_size.y

func _on_New_pressed():
	var song:Song=Song.new()
	AUDIO.tracker.stop()
	SYNTH.mute_voices(0)
	GLOBALS.song=song

func _on_Load_pressed()->void:
	file_mode=FILE_MODE.LOAD
	$FileDialog.current_dir=CONFIG.get_value(CONFIG.CURR_DIR)
	$FileDialog.window_title="Load Song"
	$FileDialog.mode=FileDialog.MODE_OPEN_FILE
	$FileDialog.filters=FILES_SE4
	$FileDialog.popup_centered_ratio()

func _on_Save_pressed()->void:
	file_mode=FILE_MODE.SAVE
	$FileDialog.current_dir=CONFIG.get_value(CONFIG.CURR_DIR)
	$FileDialog.window_title="Save Song"
	$FileDialog.mode=FileDialog.MODE_SAVE_FILE
	$FileDialog.filters=FILES_SE4
	$FileDialog.popup_centered_ratio()

func _on_SaveWav_pressed()->void:
	file_mode=FILE_MODE.SAVE_WAV
	$FileDialog.current_dir=CONFIG.get_value(CONFIG.CURR_DIR)
	$FileDialog.window_title="Export as Wave"
	$FileDialog.mode=FileDialog.MODE_SAVE_FILE
	$FileDialog.filters=FILES_WAV
	$FileDialog.popup_centered_ratio()

func adjust_base_dir()->void:
	var d:String=CONFIG.get_value(CONFIG.CURR_DIR)
	var dir:Directory=Directory.new()
	if dir.file_exists(d):
		d=d.get_base_dir()
	elif !dir.dir_exists(d):
		d=OS.get_user_data_dir()
	CONFIG.set_value(CONFIG.CURR_DIR,d)

#

func _on_file_selected(path:String)->void:
	CONFIG.set_value(CONFIG.CURR_DIR,path.get_base_dir())
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
		synth.set_mix_rate(CONFIG.get_value(CONFIG.RECORD_SAMPLERATE))
		if CONFIG.get_value(CONFIG.RECORD_SAVEMUTED):
			synth.mute_voices(GLOBALS.muted_mask)
		GLOBALS.song.sync_waves(synth)
		GLOBALS.song.sync_lfos(synth)
		var thr:Thread=Thread.new()
		thr.start(self,"export_thread",{
			"synth":synth,
			"path":path,
			"thread":thr
		})

func export_thread(data:Dictionary)->void:
	var synth:Synth=data["synth"]
	var tracker:Tracker=Tracker.new(synth)
	var file:WaveFile=WaveFile.new()
	var sample_rate:int=CONFIG.get_value(CONFIG.RECORD_SAMPLERATE)
	var cmds:Array=[]
	cmds.resize(65536)
	tracker.set_block_signals(true)
	PROGRESS.start()
	var err:int=file.start_file(data["path"],CONFIG.get_value(CONFIG.RECORD_FPSAMPLES),sample_rate)
	if err==OK:
		tracker.record(0)
		while tracker.gen_commands(GLOBALS.song,sample_rate,BUFFER_SIZE,cmds):
			err=file.write_chunk(synth.generate(BUFFER_SIZE,cmds,1.0))
			if err!=OK:
				ALERT.alert(file.get_error_message(err))
				call_deferred("thread_kill",data["thread"])
				return
			PROGRESS.set_value((tracker.curr_order*100)/GLOBALS.song.orders.size())
		file.end_file()
	else:
		ALERT.alert(file.get_error_message(err))
	PROGRESS.end()
	call_deferred("thread_kill",data["thread"])

func thread_kill(thr:Thread)->void:
	thr.wait_to_finish()


func _on_FileDialog_visibility_changed()->void:
	if $FileDialog.visible:
		FADER.open_dialog($FileDialog)
	else:
		FADER.close_dialog($FileDialog)

#

func _on_Cleanup_id_pressed(id:int)->void:
	AUDIO.tracker.stop()
	if id==0:
		GLOBALS.song.clean_patterns()
	elif id==1:
		GLOBALS.song.clean_instruments()
	elif id==2:
		GLOBALS.song.clean_waveforms()
	elif id==3:
		GLOBALS.song.clean_patterns()
		GLOBALS.song.clean_instruments()
		GLOBALS.song.clean_waveforms()

#

func _on_mouse_entered()->void:
	var sb:StyleBox=real_theme.get_stylebox("panel","PanelContainer")
	rect_size.y=base_height+sb.get_center_size().y

func _on_mouse_exited()->void:
	rect_size.y=0
