extends VBoxContainer

signal arp_selected(index)

const FILES_SA4:Dictionary={"*.sa4":"FTYPE_ARPEGGIO"}
enum FILE_MODE{LOAD_ARP,SAVE_ARP}


var arp_list:ItemList
var copy_buffer:Arpeggio=null

var file_mode:int
var file_dlg:FileDialog
var curr_arp_ix:int=-1


func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	_on_song_changed()
	get_node("Speed/Ticks").value=GLOBALS.arp_ticks
	file_dlg=$FileDialog

func _on_song_changed()->void:
	GLOBALS.song.connect("arp_list_changed",self,"update_ui")
	update_ui()

func update_ui()->void:
	arp_list=$Arpeggios
	arp_list.clear()
	for arp in GLOBALS.song.arp_list:
		arp_list.add_item(arp.name)
	arp_list.ensure_current_is_visible()
	curr_arp_ix=arp_list.get_selected_items()[0] if arp_list.is_anything_selected() else -1
	set_buttons()

func set_buttons()->void:
	$Buttons/Add.disabled=!GLOBALS.song.can_add_arp()
	$Buttons/Copy.disabled=!GLOBALS.song.can_add_arp() or !arp_list.is_anything_selected()
	$Buttons/Del.disabled=GLOBALS.song.arp_list.empty() or !arp_list.is_anything_selected()
	$Buttons2/Load.disabled=!GLOBALS.song.can_add_arp()
	$Buttons2/Save.disabled=curr_arp_ix==-1

func select_item(idx:int)->void:
	curr_arp_ix=idx
	set_buttons()
	arp_list.select(idx)
	arp_list.ensure_current_is_visible()
	_on_Arpeggios_item_selected(idx)

func _on_Add_pressed()->void:
	if GLOBALS.song.can_add_arp():
		var cnt:int=arp_list.get_item_count()
		var na:Arpeggio=Arpeggio.new()
		var nn:String="%s %02X"%[na.name,cnt]
		arp_list.add_item(nn)
		na.name=nn
		GLOBALS.song.add_arp(na)
		select_item(cnt)
	set_buttons()

func _on_Del_pressed()->void:
	var sel:int=arp_list.get_selected_items()[0] if arp_list.is_anything_selected() else -1
	var i:Arpeggio=GLOBALS.song.get_arp(sel)
	if i!=null and GLOBALS.song.can_delete_arp(i):
		arp_list.remove_item(GLOBALS.song.find_arp(i))
		GLOBALS.song.delete_arp(i)
		arp_list.unselect_all()
		if sel>=GLOBALS.song.arp_list.size():
			sel=GLOBALS.song.arp_list.size()-1
		select_item(sel)
		set_buttons()

func _on_Copy_pressed()->void:
	var sel:int=arp_list.get_selected_items()[0] if arp_list.is_anything_selected() else -1
	var i:Arpeggio=GLOBALS.song.get_arp(sel)
	if i!=null and GLOBALS.song.can_add_arp():
		var cnt:int=arp_list.get_item_count()
		var ni:Arpeggio=i.duplicate()
		arp_list.add_item(ni.name)
		GLOBALS.song.add_arp(ni)
		select_item(cnt)
		set_buttons()

func _on_Arpeggios_item_selected(index:int)->void:
	curr_arp_ix=index
	set_buttons()
	emit_signal("arp_selected",index)

func _on_Name_text_changed(txt:String)->void:
	if arp_list.is_anything_selected():
		var sel:int=arp_list.get_selected_items()[0]
		arp_list.set_item_text(sel,txt)

func _on_Ticks_value_changed(value:int)->void:
	GLOBALS.arp_ticks=value

func _on_Load_pressed()->void:
	file_mode=FILE_MODE.LOAD_ARP
	file_dlg.current_dir=CONFIG.get_value(CONFIG.CURR_ARP_DIR)
	file_dlg.window_title="ARPED_LOAD_DLG"
	file_dlg.mode=FileDialog.MODE_OPEN_FILES
	file_dlg.current_file=""
	file_dlg.filters=GLOBALS.translate_filetypes(FILES_SA4)
	file_dlg.set_as_toplevel(true)
	file_dlg.popup_centered_ratio()

func _on_Save_pressed()->void:
	file_mode=FILE_MODE.SAVE_ARP
	file_dlg.current_dir=CONFIG.get_value(CONFIG.CURR_ARP_DIR)
	file_dlg.window_title="ARPED_SAVE_DLG"
	file_dlg.mode=FileDialog.MODE_SAVE_FILE
	file_dlg.current_file=GLOBALS.song.arp_list[curr_arp_ix].file_name
	file_dlg.filters=GLOBALS.translate_filetypes(FILES_SA4)
	file_dlg.set_as_toplevel(true)
	file_dlg.popup_centered_ratio()

func _on_file_selected(path:String)->void:
	var res:FileResult=ArpeggioWriter.new().write(path,GLOBALS.song.arp_list[curr_arp_ix])
	if res.has_error():
		ALERT.alert(res.get_message())
		print(res.get_message())
	else:
		CONFIG.set_value(CONFIG.CURR_ARP_DIR,path.get_base_dir())

func _on_files_selected(paths:PoolStringArray)->void:
	var arr:ArpeggioReader=ArpeggioReader.new()
	var res:FileResult=null
	for path in paths:
		res=arr.read(path)
		if res.has_error():
			ALERT.alert(res.get_message())
			print(res.get_message())
			break
	if res==null or res.is_ok():
		CONFIG.set_value(CONFIG.CURR_ARP_DIR,paths[0].get_base_dir())
