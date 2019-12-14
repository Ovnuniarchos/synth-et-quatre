tool extends PanelContainer

const BUFFER_SIZE=2048


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
	GLOBALS.song=song

func _on_Load_pressed()->void:
	file_mode=FILE_MODE.LOAD
	$FileDialog.window_title="Load Song"
	$FileDialog.mode=FileDialog.MODE_OPEN_FILE
	$FileDialog.popup_centered_ratio()

func _on_Save_pressed()->void:
	file_mode=FILE_MODE.SAVE
	$FileDialog.window_title="Save Song"
	$FileDialog.mode=FileDialog.MODE_SAVE_FILE
	$FileDialog.popup_centered_ratio()

func _on_SaveWav_pressed()->void:
	file_mode=FILE_MODE.SAVE_WAV
	$FileDialog.window_title="Export as Wave"
	$FileDialog.mode=FileDialog.MODE_SAVE_FILE
	$FileDialog.popup_centered_ratio()

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


func _on_FileDialog_visibility_changed()->void:
	if $FileDialog.visible:
		GLOBALS.dialog_opened($FileDialog)
	else:
		GLOBALS.dialog_closed($FileDialog)

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
