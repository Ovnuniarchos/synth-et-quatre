extends VBoxContainer

signal wave_calculated(wave_ix)
signal name_changed(wave_ix,text)


var curr_wave_ix:int=-1
var new_menu:PopupMenu
# var components:HBoxContainer


func _ready():
	# components=$Designer/SC/Components
	new_menu=$Designer/NewMenu
	new_menu.connect("id_pressed",self,"_on_New_id_pressed")
	$Designer.get_zoom_hbox().hide()
	update_ui()


func update_ui()->void:
	_on_wave_selected(curr_wave_ix)


#


func _on_Name_changed(text:String)->void:
	var w:Waveform=GLOBALS.song.get_wave(curr_wave_ix)
	if w!=null:
		w.name=text
		emit_signal("name_changed",curr_wave_ix,text)


func _on_Size_changed(value:float)->void:
	var w:NodeWave=GLOBALS.song.get_wave(curr_wave_ix) as NodeWave
	if w!=null:
		w.size_po2=value
		calculate()
		set_size_bytes(w.size)


func set_size_bytes(size:int)->void:
	if size>0:
		$Info/HBC/LabelSizeSamples.text=tr("WAVED_SIZE_SAMPLES").format({"i_samples":size})
	else:
		$Info/HBC/LabelSizeSamples.text="WAVED_SIZE_NONE"


func _on_wave_selected(wave:int)->void:
	curr_wave_ix=wave
	var w:NodeWave=GLOBALS.song.get_wave(curr_wave_ix) as NodeWave
	if w==null:
		$Info/HBC/Name.editable=false
		$Info/HBC/Name.text=""
		set_size_bytes(-1)
		$Designer.visible=false
	else:
		$Info/HBC/Name.editable=true
		$Info/HBC/Name.text=w.name
		$Info/HBC/Size.value=w.size_po2
		set_size_bytes(w.size)
		$Designer.visible=true
	"""if components!=null:
		regen_editor_nodes(w)"""
	calculate()


func _on_wave_deleted(_wave:int)->void:
	curr_wave_ix=-1
	$Info/HBC/Name.editable=false
	$Info/HBC/Name.text=""
	set_size_bytes(-1)
	# regen_editor_nodes(null)
	calculate()


#

"""func regen_editor_nodes(wave:NodeWave)->void:
	for n in components.get_children():
		if n is WaveController:
			n.queue_free()
	if wave==null:
		return
	# TODO


func insert_component(type:int,wave:NodeWave,wc:WaveComponent)->void:
	pass
	# TODO


func _on_New_id_pressed(id:int)->void:
	var wave:Waveform=GLOBALS.song.get_wave(curr_wave_ix)
	if wave==null:
		return
	var wc:WaveComponent=null
	# TODO
	wave.components.append(wc)
	insert_component(id,wave,wc)
	wave.readjust_inputs()
	calculate()


func _on_delete_requested(control:WaveController)->void:
	var wave:NodeWave=control.wave
	# TODO
	regen_editor_nodes(wave)
"""

#


func calculate()->void:
	var wave:Waveform=GLOBALS.song.get_wave(curr_wave_ix)
	if wave!=null:
		wave.calculate()
		SYNCER.send_wave(wave)
	emit_signal("wave_calculated",curr_wave_ix)


func _on_Designer_gui_input(ev:InputEvent)->void:
	if ev is InputEventMouseButton and not ev.pressed and ev.button_index==2:
		new_menu.rect_position=ev.global_position
		new_menu.popup()
