tool extends PanelContainer

const FILES_SE4=PoolStringArray(["*.se4 ; SynthEtQuatre song"])
const FILES_SI4=PoolStringArray(["*.si4 ; SynthEtQuatre instrument"])
const FILES_WAV=PoolStringArray(["*.wav ; WAV file"])

var IO_SONG:IOSong=IOSong.new()
var IO_WAV_EXPORT:IOWavExport=IOWavExport.new()
var IO_INSTRUMENT:IOInstrument=IOInstrument.new()


enum FILE_MODE{LOAD_SONG,LOAD_INST,SAVE_SONG,SAVE_WAV,SAVE_INST}


var file_mode:int
var real_theme:Theme
var base_height:float
var popup_on:bool
var bar_on:bool


func _ready()->void:
	popup_on=false
	bar_on=false
	set_popup($CC/HBC/Cleanup.get_popup(),"_on_Cleanup_id_pressed")
	set_popup($CC/HBC/Save.get_popup(),"_on_Save_id_pressed")
	set_popup($CC/HBC/Load.get_popup(),"_on_Load_id_pressed")
	real_theme=THEME.get("theme")
	print(real_theme)
	rect_size.y=0.0
	base_height=$CC/HBC.rect_size.y

func set_popup(pu:Popup,sel:String)->void:
	pu.connect("id_pressed",self,sel)
	pu.connect("popup_hide",self,"_on_popup_hide")
	pu.connect("about_to_show",self,"_on_popup_about_to_show")

#

func _on_mouse_entered()->void:
	var sb:StyleBox=real_theme.get_stylebox("panel","PanelContainer")
	rect_size.y=base_height+sb.get_center_size().y
	bar_on=true

func _on_mouse_exited()->void:
	bar_on=false
	if !popup_on:
		rect_size.y=0

func _on_popup_about_to_show():
	popup_on=true

func _on_popup_hide():
	popup_on=false
	if !bar_on:
		_on_mouse_exited()

#

func _on_New_pressed()->void:
	var song:Song=Song.new()
	AUDIO.tracker.stop()
	AUDIO.tracker.reset()
	GLOBALS.set_song(song)

#

func _on_file_selected(path:String)->void:
	var cfg_dir:Array
	match file_mode:
		FILE_MODE.LOAD_SONG:
			cfg_dir=CONFIG.CURR_SONG_DIR
			IO_SONG.obj_load(path)
		FILE_MODE.LOAD_INST:
			cfg_dir=CONFIG.CURR_INST_DIR
			IO_INSTRUMENT.obj_load(path)
		FILE_MODE.SAVE_SONG:
			cfg_dir=CONFIG.CURR_SONG_DIR
			IO_SONG.obj_save(path)
		FILE_MODE.SAVE_WAV:
			cfg_dir=CONFIG.CURR_EXPORT_DIR
			IO_WAV_EXPORT.obj_save(path)
		FILE_MODE.SAVE_INST:
			cfg_dir=CONFIG.CURR_INST_DIR
			IO_INSTRUMENT.obj_save(path)
	CONFIG.set_value(cfg_dir,path.get_base_dir())

func _on_files_selected(paths:PoolStringArray)->void:
	var cfg_dir:Array
	match file_mode:
		FILE_MODE.LOAD_INST:
			cfg_dir=CONFIG.CURR_INST_DIR
			for path in paths:
				IO_INSTRUMENT.obj_load(path)
	CONFIG.set_value(cfg_dir,paths[0].get_base_dir())

func _on_FileDialog_visibility_changed()->void:
	if $FileDialog.visible:
		FADER.open_dialog($FileDialog)
	else:
		FADER.close_dialog($FileDialog)

#

func _on_Load_id_pressed(id:int)->void:
	popup_on=false
	_on_mouse_exited()
	match id:
		0:
			load_song()
		1:
			load_instrument()

func load_song()->void:
	file_mode=FILE_MODE.LOAD_SONG
	$FileDialog.current_dir=CONFIG.get_value(CONFIG.CURR_SONG_DIR)
	$FileDialog.window_title="Load Song"
	$FileDialog.mode=FileDialog.MODE_OPEN_FILE
	$FileDialog.filters=FILES_SE4
	$FileDialog.current_file=""
	$FileDialog.set_as_toplevel(true)
	$FileDialog.popup_centered_ratio()

func load_instrument()->void:
	file_mode=FILE_MODE.LOAD_INST
	$FileDialog.current_dir=CONFIG.get_value(CONFIG.CURR_INST_DIR)
	$FileDialog.window_title="Load Instrument"
	$FileDialog.mode=FileDialog.MODE_OPEN_FILES
	$FileDialog.filters=FILES_SI4
	$FileDialog.current_file=""
	$FileDialog.set_as_toplevel(true)
	$FileDialog.popup_centered_ratio()

#

func _on_Save_id_pressed(id:int)->void:
	popup_on=false
	_on_mouse_exited()
	match id:
		0:
			save_song()
		1:
			save_wave()
		2:
			save_instrument()

func save_song()->void:
	file_mode=FILE_MODE.SAVE_SONG
	$FileDialog.current_dir=CONFIG.get_value(CONFIG.CURR_SONG_DIR)
	$FileDialog.window_title="Save Song"
	$FileDialog.mode=FileDialog.MODE_SAVE_FILE
	$FileDialog.filters=FILES_SE4
	$FileDialog.current_file=GLOBALS.song.file_name
	$FileDialog.set_as_toplevel(true)
	$FileDialog.popup_centered_ratio()

func save_wave()->void:
	file_mode=FILE_MODE.SAVE_WAV
	$FileDialog.current_dir=CONFIG.get_value(CONFIG.CURR_EXPORT_DIR)
	$FileDialog.window_title="Export as Wave"
	$FileDialog.mode=FileDialog.MODE_SAVE_FILE
	$FileDialog.filters=FILES_WAV
	$FileDialog.current_file=""
	$FileDialog.set_as_toplevel(true)
	$FileDialog.popup_centered_ratio()

func save_instrument()->void:
	file_mode=FILE_MODE.SAVE_INST
	$FileDialog.current_dir=CONFIG.get_value(CONFIG.CURR_INST_DIR)
	$FileDialog.window_title="Save Instrument"
	$FileDialog.mode=FileDialog.MODE_SAVE_FILE
	$FileDialog.filters=FILES_SI4
	$FileDialog.current_file=GLOBALS.song.instrument_list[GLOBALS.curr_instrument].file_name
	$FileDialog.set_as_toplevel(true)
	$FileDialog.popup_centered_ratio()

#

func _on_Cleanup_id_pressed(id:int)->void:
	popup_on=false
	_on_mouse_exited()
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
