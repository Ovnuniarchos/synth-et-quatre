extends VBoxContainer


signal instrument_selected(idx)
signal instrument_deleted(idx)
signal instrument_added(idx)


var file_dlg:FileDialog
var inst_l:ItemList
var copy_buffer:Instrument=null


func _ready()->void:
	file_dlg=$FileDialog
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	GLOBALS.connect("instrument_changed",self,"_on_instrument_changed")
	_on_song_changed()


func _on_song_changed()->void:
	GLOBALS.song.connect("instrument_list_changed",self,"update_ui")
	update_ui()


func update_ui()->void:
	inst_l=$Instruments
	inst_l.clear()
	for inst in GLOBALS.song.instrument_list:
		inst_l.add_item(inst.name)
	if GLOBALS.curr_instrument>=GLOBALS.song.instrument_list.size():
		GLOBALS.curr_instrument=GLOBALS.song.instrument_list.size()-1
	inst_l.select(GLOBALS.curr_instrument)
	inst_l.ensure_current_is_visible()
	set_buttons()
	emit_signal("instrument_selected",GLOBALS.curr_instrument)


func set_buttons()->void:
	$Buttons2/Save.disabled=not inst_l.is_anything_selected()
	$Buttons/Add.disabled=!GLOBALS.song.can_add_instrument()
	$Buttons/Copy.disabled=!GLOBALS.song.can_add_instrument() or GLOBALS.curr_instrument==-1
	$Buttons/Del.disabled=GLOBALS.song.instrument_list.size()==1 or GLOBALS.curr_instrument==-1


func select_item(idx:int)->void:
	inst_l.select(idx)
	inst_l.ensure_current_is_visible()
	emit_signal("instrument_selected",idx)


func _on_Add_pressed()->void:
	if GLOBALS.song.can_add_instrument():
		var cnt:int=inst_l.get_item_count()
		var ni:Instrument=FmInstrument.new()
		var nn:String="%s %02X"%[ni.name,cnt]
		inst_l.add_item(nn)
		ni.name=nn
		GLOBALS.song.add_instrument(ni)
		emit_signal("instrument_added",cnt)
		GLOBALS.curr_instrument=cnt
		select_item(cnt)
	set_buttons()


func _on_Del_pressed()->void:
	var i:Instrument=GLOBALS.song.get_instrument(GLOBALS.curr_instrument)
	if i!=null:
		if GLOBALS.song.can_delete_instrument(i):
			inst_l.remove_item(GLOBALS.song.find_instrument(i))
			GLOBALS.song.delete_instrument(i)
			emit_signal("instrument_deleted",GLOBALS.curr_instrument)
			inst_l.unselect_all()
			if GLOBALS.curr_instrument>=GLOBALS.song.instrument_list.size():
				GLOBALS.curr_instrument=GLOBALS.song.instrument_list.size()-1
			select_item(GLOBALS.curr_instrument)
			set_buttons()


func _on_Copy_pressed()->void:
	var i:Instrument=GLOBALS.song.get_instrument(GLOBALS.curr_instrument)
	if i!=null and GLOBALS.song.can_add_instrument():
		var cnt:int=inst_l.get_item_count()
		var ni:Instrument=i.duplicate()
		inst_l.add_item(ni.name)
		GLOBALS.song.add_instrument(ni)
		emit_signal("instrument_added",cnt)
		GLOBALS.curr_instrument=cnt
		select_item(cnt)
	set_buttons()


func _on_instrument_changed(index:int,_name:String)->void:
	$Instruments.set_block_signals(true)
	$Instruments.select(index)
	$Instruments.set_block_signals(false)


func _on_item_selected(index:int)->void:
	var inst:Instrument=GLOBALS.song.get_instrument(index)
	GLOBALS.curr_instrument=-1 if inst==null else index
	set_buttons()
	emit_signal("instrument_selected",GLOBALS.curr_instrument)


func _on_instrument_name_changed(index:int,text:String)->void:
	inst_l.set_item_text(index,text)


func _on_Instruments_gui_input(ev:InputEvent)->void:
	if not (ev is InputEventKey):
		return
	if ev.get_scancode_with_modifiers() in GKBD.COPY:
		if not ev.is_pressed():
			copy_buffer=GLOBALS.get_instrument(-1).duplicate()
		accept_event()
	if ev.get_scancode_with_modifiers() in GKBD.PASTE:
		if not ev.is_pressed():
			GLOBALS.get_instrument(-1).copy(copy_buffer)
			emit_signal("instrument_selected",GLOBALS.curr_instrument)
		accept_event()


func _on_Load_pressed()->void:
	file_dlg.current_dir=CONFIG.get_value(CONFIG.CURR_INST_DIR)
	file_dlg.window_title="INSTED_DLG_LOAD"
	file_dlg.mode=FileDialog.MODE_OPEN_FILES
	file_dlg.current_file=""
	file_dlg.set_as_toplevel(true)
	file_dlg.popup_centered_ratio()


func _on_Save_pressed()->void:
	file_dlg.current_dir=CONFIG.get_value(CONFIG.CURR_INST_DIR)
	file_dlg.window_title="INSTED_DLG_SAVE"
	file_dlg.mode=FileDialog.MODE_SAVE_FILE
	file_dlg.current_file=GLOBALS.song.instrument_list[GLOBALS.curr_instrument].file_name
	file_dlg.set_as_toplevel(true)
	file_dlg.popup_centered_ratio()


func _on_FileDialog_file_selected(path:String)->void:
	var cfg_dir:Array=CONFIG.CURR_INST_DIR
	FmInstrumentWriter.new(GLOBALS.song.wave_list).write(path,GLOBALS.get_instrument())
	CONFIG.set_value(cfg_dir,path.get_base_dir())


func _on_FileDialog_files_selected(paths:PoolStringArray)->void:
	var cfg_dir:Array=CONFIG.CURR_INST_DIR
	var fir:FmInstrumentReader=FmInstrumentReader.new()
	for path in paths:
		fir.read(path)
	CONFIG.set_value(cfg_dir,paths[0].get_base_dir())


