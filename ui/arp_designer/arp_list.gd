extends VBoxContainer

signal arp_selected(index)

var arp_list:ItemList
var copy_buffer:Arpeggio=null


func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	_on_song_changed()
	get_node("Speed/Ticks").value=GLOBALS.arp_ticks

func _on_song_changed()->void:
	GLOBALS.song.connect("arp_list_changed",self,"update_ui")
	update_ui()

func update_ui()->void:
	arp_list=$Arpeggios
	arp_list.clear()
	for arp in GLOBALS.song.arp_list:
		arp_list.add_item(arp.name)
	arp_list.ensure_current_is_visible()
	set_buttons()

func set_buttons()->void:
	$Buttons/Add.disabled=!GLOBALS.song.can_add_arp()
	$Buttons/Copy.disabled=!GLOBALS.song.can_add_arp() or !arp_list.is_anything_selected()
	$Buttons/Del.disabled=GLOBALS.song.arp_list.empty() or !arp_list.is_anything_selected()

func select_item(idx:int)->void:
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
	set_buttons()
	emit_signal("arp_selected",index)

func _on_Name_text_changed(txt:String)->void:
	if arp_list.is_anything_selected():
		var sel:int=arp_list.get_selected_items()[0]
		arp_list.set_item_text(sel,txt)

func _on_Ticks_value_changed(value:int)->void:
	GLOBALS.arp_ticks=value
