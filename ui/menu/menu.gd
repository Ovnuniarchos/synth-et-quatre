extends PanelContainer


const FILES_SE4=PoolStringArray(["*.se4 ; SynthEtQuatre song"])
const FILES_WAV=PoolStringArray(["*.wav ; WAV file"])

const MENUS:Array=[
	{"option":"MENU_FILE","options":
		[
			{"text":"MENU_NEW","function":"_on_New_pressed"},
			{"separator":true},
			{"text":"MENU_OPEN_SONG","function":"_on_Open_pressed"},
			{"text":"MENU_SAVE_SONG","function":"_on_Save_pressed"},
			{"text":"MENU_SAVE_WAVE","function":"_on_SaveWave_pressed"},
			{"separator":true},
			{"text":"MENU_CLEANUP","options":[
				{"text":"MENU_CLEANUP_PATTERNS","function":"_on_CleanupPatterns_pressed"},
				{"text":"MENU_CLEANUP_INSTRUMENTS","function":"_on_CleanupInstruments_pressed"},
				{"text":"MENU_CLEANUP_WAVES","function":"_on_CleanupWaveforms_pressed"},
				{"text":"MENU_CLEANUP_ARPEGGIOS","function":"_on_CleanupArpeggios_pressed"},
				{"separator":true},
				{"text":"MENU_CLEANUP_ALL","function":"_on_CleanupAll_pressed"},
			]},
		]
	},
	{"separator":2},
	{"option":"MENU_PATTERNS","function":"_on_Patterns_pressed"},
	{"option":"MENU_INSTRUMENTS","function":"_on_Instruments_pressed"},
	{"option":"MENU_WAVES","function":"_on_Waves_pressed"},
	{"option":"MENU_ARPEGGIOS","function":"_on_Arpeggios_pressed"},
	{"option":"MENU_OPTIONS","function":"_on_Options_pressed"},
	{"separator":-1},
	{"option":"MENU_QUIT","function":"_on_Quit_pressed"},
]

enum FILE_MODE{LOAD_SONG,SAVE_SONG,SAVE_WAV}


var file_mode:int
var file_dlg:FileDialog
var real_theme:Theme


func _init()->void:
	real_theme=THEME.get("theme")
	theme=real_theme


func _ready()->void:
	file_dlg=$FileDialog
	var hbc:HBoxContainer=get_node("HBC")
	for op in MENUS:
		if "option" in op:
			if "options" in op:
				var mb:MenuButton=MenuButton.new()
				mb.flat=false
				mb.text=op["option"]
				ThemeHelper.apply_styles(real_theme,"MenuButton",mb)
				add_options(op["options"],mb.get_popup())
				hbc.add_child(mb)
			else:
				var mb:Button=Button.new()
				mb.text=op["option"]
				ThemeHelper.apply_styles(real_theme,"MenuButton",mb)
				mb.connect("pressed",self,"_on_menu_pressed",[-1,funcref(self,op["function"])])
				hbc.add_child(mb)
		else:
			var sep:Control=Control.new()
			var w:float=op["separator"]
			if w>0.0:
				sep.rect_min_size.x=16*w
			else:
				sep.size_flags_horizontal=SIZE_EXPAND_FILL
				sep.size_flags_stretch_ratio=-w
			hbc.add_child(sep)


func add_options(ops:Array,menu:PopupMenu)->void:
	var ix:int=0
	for op in ops:
		if "separator" in op:
			menu.add_separator()
		elif "options" in op:
			var new_menu:PopupMenu=PopupMenu.new()
			new_menu.set_name(op["text"])
			add_options(op["options"],new_menu)
			menu.add_child(new_menu)
			menu.add_submenu_item(op["text"],op["text"])
		else:
			menu.add_item(op["text"])
			menu.set_item_metadata(ix,funcref(self,op["function"]))
		ix+=1
	menu.connect("index_pressed",self,"_on_menu_pressed",[menu])
	menu.connect("popup_hide",self,"_on_popup_hide")


func _on_menu_pressed(index:int,menu)->void:
	if index>-1:
		menu.get_item_metadata(index).call_func()
	else:
		menu.call_func()


func _on_popup_hide()->void:
	for n in $HBC.get_children():
		n.notification(NOTIFICATION_MOUSE_EXIT)
		n.notification(NOTIFICATION_FOCUS_EXIT)


func _on_New_pressed()->void:
	var song:Song=Song.new()
	AUDIO.tracker.stop()
	AUDIO.tracker.reset()
	GLOBALS.set_song(song)


func _on_Open_pressed()->void:
	file_mode=FILE_MODE.LOAD_SONG
	file_dlg.current_dir=CONFIG.get_value(CONFIG.CURR_SONG_DIR)
	file_dlg.window_title=tr("MENU_OPEN_SONG")
	file_dlg.mode=FileDialog.MODE_OPEN_FILE
	file_dlg.filters=FILES_SE4
	file_dlg.current_file=""
	file_dlg.set_as_toplevel(true)
	file_dlg.popup_centered_ratio()


func _on_Save_pressed()->void:
	file_mode=FILE_MODE.SAVE_SONG
	file_dlg.current_dir=CONFIG.get_value(CONFIG.CURR_SONG_DIR)
	file_dlg.window_title=tr("MENU_SAVE_SONG")
	file_dlg.mode=FileDialog.MODE_SAVE_FILE
	file_dlg.filters=FILES_SE4
	file_dlg.current_file=GLOBALS.song.file_name
	file_dlg.set_as_toplevel(true)
	file_dlg.popup_centered_ratio()


func _on_SaveWave_pressed()->void:
	file_mode=FILE_MODE.SAVE_WAV
	file_dlg.current_dir=CONFIG.get_value(CONFIG.CURR_EXPORT_DIR)
	file_dlg.window_title=tr("MENU_EXPORT_WAVE")
	file_dlg.mode=FileDialog.MODE_SAVE_FILE
	file_dlg.filters=FILES_WAV
	file_dlg.current_file=""
	file_dlg.set_as_toplevel(true)
	file_dlg.popup_centered_ratio()


func _on_file_selected(path:String)->void:
	var cfg_dir:Array
	match file_mode:
		FILE_MODE.LOAD_SONG:
			cfg_dir=CONFIG.CURR_SONG_DIR
			SongReader.new().read(path)
		FILE_MODE.SAVE_SONG:
			cfg_dir=CONFIG.CURR_SONG_DIR
			SongWriter.new().write(path,GLOBALS.song)
		FILE_MODE.SAVE_WAV:
			cfg_dir=CONFIG.CURR_EXPORT_DIR
			WaveFileWriter.new().write(path)
	CONFIG.set_value(cfg_dir,path.get_base_dir())


func _on_FileDialog_visibility_changed()->void:
	if file_dlg.visible:
		FADER.open_dialog(file_dlg)
	else:
		FADER.close_dialog(file_dlg)


func _on_CleanupPatterns_pressed()->void:
	AUDIO.tracker.stop()
	GLOBALS.song.clean_patterns()


func _on_CleanupInstruments_pressed()->void:
	AUDIO.tracker.stop()
	GLOBALS.song.clean_instruments()


func _on_CleanupWaveforms_pressed()->void:
	AUDIO.tracker.stop()
	GLOBALS.song.clean_waveforms()


func _on_CleanupArpeggios_pressed()->void:
	AUDIO.tracker.stop()
	GLOBALS.song.clean_arps()


func _on_CleanupAll_pressed()->void:
	AUDIO.tracker.stop()
	GLOBALS.song.clean_patterns()
	GLOBALS.song.clean_instruments()
	GLOBALS.song.clean_waveforms()
	GLOBALS.song.clean_arps()


func _on_Patterns_pressed()->void:
	GLOBALS.emit_signal("tab_changed",0)

func _on_Instruments_pressed()->void:
	GLOBALS.emit_signal("tab_changed",1)

func _on_Waves_pressed()->void:
	GLOBALS.emit_signal("tab_changed",2)

func _on_Arpeggios_pressed()->void:
	GLOBALS.emit_signal("tab_changed",3)

func _on_Options_pressed()->void:
	GLOBALS.emit_signal("tab_changed",4)

func _on_Quit_pressed()->void:
	get_tree().quit()
