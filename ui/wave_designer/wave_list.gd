extends VBoxContainer

signal wave_selected(wave_ix)
signal wave_deleted(wave_ix)
signal wave_added(wave_ix)


const FILES_SW4:Dictionary={"*.sw4":"FTYPE_WAVEFORM"}
enum FILE_MODE{LOAD_WAVE,SAVE_WAVE}


var file_mode:int
var file_dlg:FileDialog
var curr_wave_ix:int=-1
var copy_buffer:Waveform=null


func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	$Buttons/Add.get_popup().connect("id_pressed",self,"_on_Add_id_pressed")
	_on_song_changed()
	ThemeHelper.apply_styles(ThemeHelper.get_theme(),"Button",$Buttons/Add)
	file_dlg=$FileDialog


func _on_song_changed()->void:
	GLOBALS.song.connect("wave_list_changed",self,"update_ui")
	curr_wave_ix=-1
	emit_signal("wave_selected",-1)
	update_ui()


func update_ui()->void:
	var wl:ItemList=$Waves
	wl.clear()
	for w in GLOBALS.song.wave_list:
		wl.add_item(w.name,null,w is Waveform)
	var sz:int=GLOBALS.song.wave_list.size()
	if curr_wave_ix<sz:
		wl.call_deferred("select",curr_wave_ix)
	elif sz>0:
		wl.call_deferred("select",sz-1)
	wl.call_deferred("ensure_current_is_visible")
	set_buttons()


func set_buttons()->void:
	$Buttons/Add.disabled=!GLOBALS.song.can_add_wave()
	$Buttons/Duplicate.disabled=!GLOBALS.song.can_add_wave() or curr_wave_ix==-1
	$Buttons/Del.disabled=GLOBALS.song.wave_list.empty() or curr_wave_ix==-1
	$Buttons2/Load.disabled=!GLOBALS.song.can_add_wave()
	$Buttons2/Save.disabled=GLOBALS.song.wave_list.empty() or curr_wave_ix==-1


func _on_item_selected(index:int)->void:
	var wave:Waveform=GLOBALS.song.get_wave(index)
	curr_wave_ix=-1 if wave==null else index
	set_buttons()
	emit_signal("wave_selected",curr_wave_ix)


func _on_Del_pressed()->void:
	var w:Waveform=GLOBALS.song.get_wave(curr_wave_ix)
	if w!=null:
		if GLOBALS.song.can_delete_wave(w):
			$Waves.remove_item(GLOBALS.song.find_wave(w))
			GLOBALS.song.delete_wave(w)
			GLOBALS.song.sync_waves(SYNTH,curr_wave_ix)
			GLOBALS.song.sync_waves(IM_SYNTH,curr_wave_ix)
			emit_signal("wave_deleted",curr_wave_ix)
			if curr_wave_ix>=GLOBALS.song.wave_list.size():
				curr_wave_ix=GLOBALS.song.wave_list.size()-1
			emit_signal("wave_selected",curr_wave_ix)
			set_buttons()


func _on_Duplicate_pressed()->void:
	var w:Waveform=GLOBALS.song.get_wave(curr_wave_ix)
	if w!=null and GLOBALS.song.can_add_wave():
		var cnt:int=$Waves.get_item_count()
		var nw:Waveform=w.duplicate()
		curr_wave_ix=cnt
		$Waves.add_item(nw.name)
		GLOBALS.song.add_wave(nw)
		SYNCER.send_wave(nw)
		emit_signal("wave_added",cnt)
		emit_signal("wave_selected",cnt)
	set_buttons()


func _on_Add_id_pressed(id:int)->void:
	if GLOBALS.song.can_add_wave():
		var cnt:int=$Waves.get_item_count()
		curr_wave_ix=cnt
		var nw:Waveform
		if id==0:
			nw=NodeWave.new()
		else:
			nw=SampleWave.new()
		var nn:String="%s %02X"%[nw.name,cnt]
		nw.name=nn
		$Waves.add_item(nn)
		GLOBALS.song.add_wave(nw)
		SYNCER.send_wave(nw)
		emit_signal("wave_added",cnt)
		emit_signal("wave_selected",cnt)
	set_buttons()


func _on_name_changed(wave:int,text:String)->void:
	$Waves.set_item_text(wave,text)


func _on_Load_pressed()->void:
	file_mode=FILE_MODE.LOAD_WAVE
	file_dlg.current_dir=CONFIG.get_value(CONFIG.CURR_SONG_DIR)
	file_dlg.window_title="WAVED_LOAD_DLG"
	file_dlg.mode=FileDialog.MODE_OPEN_FILES
	file_dlg.current_file=""
	file_dlg.filters=GLOBALS.translate_filetypes(FILES_SW4)
	file_dlg.set_as_toplevel(true)
	file_dlg.popup_centered_ratio()


func _on_Save_pressed()->void:
	file_mode=FILE_MODE.SAVE_WAVE
	file_dlg.current_dir=CONFIG.get_value(CONFIG.CURR_WAVE_DIR)
	file_dlg.window_title="WAVED_SAVE_DLG"
	file_dlg.mode=FileDialog.MODE_SAVE_FILE
	file_dlg.current_file=GLOBALS.song.wave_list[curr_wave_ix].file_name
	file_dlg.filters=GLOBALS.translate_filetypes(FILES_SW4)
	file_dlg.set_as_toplevel(true)
	file_dlg.popup_centered_ratio()


func _on_file_selected(path:String)->void:
	var res:FileResult
	match file_mode:
		FILE_MODE.LOAD_WAVE:
			res=WaveformReader.new().read(path)
		FILE_MODE.SAVE_WAVE:
			res=WaveformWriter.new().write(path,GLOBALS.song.wave_list[curr_wave_ix])
	if res.has_error():
		ALERT.alert(res.get_message())
		print(res.get_message())
	else:
		CONFIG.set_value(CONFIG.CURR_WAVE_DIR,path.get_base_dir())


func _on_files_selected(paths:PoolStringArray):
	var cfg_dir:Array=CONFIG.CURR_WAVE_DIR
	var res:FileResult=null
	for path in paths:
		res=WaveformReader.new().read(path)
		if res.has_error:
			ALERT.alert(res.get_message())
			print(res.get_message())
			break
	if res==null or res.is_ok():
		CONFIG.set_value(cfg_dir,paths[0].get_base_dir())


func _on_Waves_gui_input(ev:InputEvent)->void:
	if not (ev is InputEventKey) or curr_wave_ix==-1:
		return
	if ev.get_scancode_with_modifiers() in GKBD.COPY:
		if not ev.is_pressed():
			copy_buffer=GLOBALS.song.get_wave(curr_wave_ix).duplicate()
		accept_event()
	if ev.get_scancode_with_modifiers() in GKBD.PASTE:
		if not ev.is_pressed():
			GLOBALS.song.get_wave(curr_wave_ix).copy(copy_buffer)
			emit_signal("wave_selected",curr_wave_ix)
		accept_event()
