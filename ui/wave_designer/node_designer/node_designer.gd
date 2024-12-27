extends VBoxContainer

signal wave_calculated(wave_ix)
signal name_changed(wave_ix,text)


var curr_wave_ix:int=-1


func _ready():
	update_ui()


func update_ui()->void:
	$Designer.size_po2=$Info/HBC/Size.value
	_on_wave_selected(curr_wave_ix)


#


func _on_Name_changed(text:String)->void:
	var w:NodeWave=GLOBALS.song.get_wave(curr_wave_ix)
	if w!=null:
		w.name=text
		emit_signal("name_changed",curr_wave_ix,text)


func _on_Size_changed(value:float)->void:
	var w:NodeWave=GLOBALS.song.get_wave(curr_wave_ix) as NodeWave
	if w!=null:
		$Designer.size_po2=value
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
	$Designer.regen_editor_nodes(w)
	calculate()


func _on_wave_deleted(_wave:int)->void:
	curr_wave_ix=-1
	$Info/HBC/Name.editable=false
	$Info/HBC/Name.text=""
	set_size_bytes(-1)
	$Designer.regen_editor_nodes(null)
	calculate()


#


func calculate()->void:
	var wave:NodeWave=GLOBALS.song.get_wave(curr_wave_ix) as NodeWave
	if wave!=null:
		wave.calculate()
		SYNCER.send_wave(wave)
		emit_signal("wave_calculated",curr_wave_ix)


func _on_Designer_node_deleted(node:WaveNodeComponent)->void:
	var wave:NodeWave=GLOBALS.song.get_wave(curr_wave_ix) as NodeWave
	if wave==null:
		return
	wave.remove_component(node)
	calculate()


func _on_Designer_node_added(node:WaveNodeComponent)->void:
	var wave:NodeWave=GLOBALS.song.get_wave(curr_wave_ix) as NodeWave
	if wave==null:
		return
	wave.add_component(node)


func _on_Designer_connections_changed(connections:Array)->void:
	var wave:NodeWave=GLOBALS.song.get_wave(curr_wave_ix) as NodeWave
	if wave==null:
		return
	for comp in wave.components:
		for inp in comp.inputs:
			inp[WaveNodeComponent.SLOT_IN].clear()
	for conn in connections:
		conn.to.inputs[conn.to_port][WaveNodeComponent.SLOT_IN].append(conn.from)
	calculate()


func _on_Designer_params_changed()->void:
	calculate()
