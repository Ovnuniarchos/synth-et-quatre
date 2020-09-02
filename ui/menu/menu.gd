tool extends PanelContainer

const FILES_SE4=PoolStringArray(["*.se4 ; SynthEtQuatre song"])
const FILES_WAV=PoolStringArray(["*.wav ; WAV file"])

var IO_SONG:IOSong=IOSong.new()
var IO_WAV_EXPORT:IOWavExport=IOWavExport.new()


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

#

func _on_mouse_entered()->void:
	var sb:StyleBox=real_theme.get_stylebox("panel","PanelContainer")
	rect_size.y=base_height+sb.get_center_size().y

func _on_mouse_exited()->void:
	rect_size.y=0

#

func _on_New_pressed()->void:
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
		IO_SONG.obj_save(path)
	elif file_mode==FILE_MODE.LOAD:
		IO_SONG.obj_load(path)
	elif file_mode==FILE_MODE.SAVE_WAV:
		IO_WAV_EXPORT.obj_save(path)


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
