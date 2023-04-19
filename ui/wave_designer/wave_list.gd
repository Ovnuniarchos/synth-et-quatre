extends VBoxContainer

signal wave_selected(wave_ix)
signal wave_deleted(wave_ix)
signal wave_added(wave_ix)

var curr_wave_ix:int=-1

func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	$Buttons/Add.get_popup().connect("id_pressed",self,"_on_Add_id_pressed")
	_on_song_changed()
	ThemeHelper.apply_styles(THEME.get("theme"),"Button",$Buttons/Add)

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
	$Buttons/Copy.disabled=!GLOBALS.song.can_add_wave() or curr_wave_ix==-1
	$Buttons/Del.disabled=GLOBALS.song.wave_list.empty() or curr_wave_ix==-1

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

func _on_Copy_pressed()->void:
	var w:Waveform=GLOBALS.song.get_wave(curr_wave_ix)
	if w!=null and GLOBALS.song.can_add_wave():
		var cnt:int=$Waves.get_item_count()
		var nw:Waveform=w.duplicate()
		curr_wave_ix=cnt
		$Waves.add_item(nw.name)
		GLOBALS.song.add_wave(nw)
		GLOBALS.song.send_wave(nw,SYNTH)
		GLOBALS.song.send_wave(nw,IM_SYNTH)
		emit_signal("wave_added",cnt)
		emit_signal("wave_selected",cnt)
	set_buttons()

func _on_Add_id_pressed(id:int)->void:
	if GLOBALS.song.can_add_wave():
		var cnt:int=$Waves.get_item_count()
		var nn:String=("Wave %02X" if id==0 else "Sample %02X")%[cnt]
		curr_wave_ix=cnt
		$Waves.add_item(nn)
		var nw:Waveform
		if id==0:
			nw=SynthWave.new()
		else:
			nw=SampleWave.new()
		nw.name=nn
		GLOBALS.song.add_wave(nw)
		GLOBALS.song.send_wave(nw,SYNTH)
		GLOBALS.song.send_wave(nw,IM_SYNTH)
		emit_signal("wave_added",cnt)
		emit_signal("wave_selected",cnt)
	set_buttons()

func _on_name_changed(wave:int,text:String)->void:
	$Waves.set_item_text(wave,text)
