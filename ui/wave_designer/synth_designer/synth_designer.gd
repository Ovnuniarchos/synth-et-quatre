extends VBoxContainer

signal wave_calculated(wave_ix)
signal name_changed(wave_ix,text)

enum WAVE_TYPES{SIN,TRI,SAW,RECT,NOISE,LPF,HPF,BPF,BRF,CLAMP,NORM,QUANT,POWER,DECAY}
const WAVES=[
	["WAVED_SYN_SINE",WAVE_TYPES.SIN,preload("nodes/wave_nodes/sine_wave.tscn")],
	["WAVED_SYN_TRIANGLE",WAVE_TYPES.TRI,preload("nodes/wave_nodes/triangle_wave.tscn")],
	["WAVED_SYN_SAW",WAVE_TYPES.SAW,preload("nodes/wave_nodes/saw_wave.tscn")],
	["WAVED_SYN_RECTANGLE",WAVE_TYPES.RECT,preload("nodes/wave_nodes/rect_wave.tscn")],
	["WAVED_SYN_NOISE",WAVE_TYPES.NOISE,preload("nodes/wave_nodes/noise_wave.tscn")],
["WAVED_SYN_LOWPASS",WAVE_TYPES.LPF,preload("nodes/filter_nodes/lpf_filter.tscn")],
	["WAVED_SYN_HIGHPASS",WAVE_TYPES.HPF,preload("nodes/filter_nodes/hpf_filter.tscn")],
	["WAVED_SYN_BANDPASS",WAVE_TYPES.BPF,preload("nodes/filter_nodes/bpf_filter.tscn")],
	["WAVED_SYN_BANDREJECT",WAVE_TYPES.BRF,preload("nodes/filter_nodes/brf_filter.tscn")],
	["WAVED_SYN_CLAMP",WAVE_TYPES.CLAMP,preload("nodes/filter_nodes/clamp_filter.tscn")],
	["WAVED_SYN_NORMALIZE",WAVE_TYPES.NORM,preload("nodes/filter_nodes/normalize_filter.tscn")],
	["WAVED_SYN_QUANTIZE",WAVE_TYPES.QUANT,preload("nodes/filter_nodes/quantize_filter.tscn")],
	["WAVED_SYN_POWER",WAVE_TYPES.POWER,preload("nodes/filter_nodes/power_filter.tscn")],
	["WAVED_SYN_DECAY",WAVE_TYPES.DECAY,preload("nodes/filter_nodes/decay_filter.tscn")],
]

var curr_wave_ix:int=-1
var new_but:Button
var new_menu:PopupMenu
var components:HBoxContainer

func _ready():
	new_but=$Designer/SC/Components/New
	components=$Designer/SC/Components
	new_menu=$Designer/NewMenu
	for sn in WAVES:
		new_menu.add_item(sn[0],sn[1])
	new_menu.connect("id_pressed",self,"_on_New_id_pressed")
	update_ui()
	ThemeHelper.apply_styles(THEME.get("theme"),"Button",new_but)

func update_ui()->void:
	_on_wave_selected(curr_wave_ix)

#

func _on_Name_changed(text:String)->void:
	var w:Waveform=GLOBALS.song.get_wave(curr_wave_ix)
	if w!=null:
		w.name=text
		emit_signal("name_changed",curr_wave_ix,text)

func _on_Size_changed(value:float)->void:
	var w:SynthWave=GLOBALS.song.get_wave(curr_wave_ix) as SynthWave
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
	var w:SynthWave=GLOBALS.song.get_wave(curr_wave_ix) as SynthWave
	if w==null:
		$Info/HBC/Name.editable=false
		$Info/HBC/Name.text=""
		set_size_bytes(-1)
		$Designer/SC.visible=false
	else:
		$Info/HBC/Name.editable=true
		$Info/HBC/Name.text=w.name
		$Info/HBC/Size.value=w.size_po2
		set_size_bytes(w.size)
		$Designer/SC.visible=true
	if components!=null:
		regen_editor_nodes(w)
	calculate()

func _on_wave_deleted(_wave:int)->void:
	curr_wave_ix=-1
	$Info/HBC/Name.editable=false
	$Info/HBC/Name.text=""
	set_size_bytes(-1)
	regen_editor_nodes(null)
	calculate()

#

func regen_editor_nodes(wave:SynthWave)->void:
	for n in components.get_children():
		if n is WaveController:
			n.queue_free()
	if wave==null:
		return
	for wc in wave.components:
		if wc is SineWave:
			insert_component(WAVE_TYPES.SIN,wave,wc)
		elif wc is TriangleWave:
			insert_component(WAVE_TYPES.TRI,wave,wc)
		elif wc is SawWave:
			insert_component(WAVE_TYPES.SAW,wave,wc)
		elif wc is RectangleWave:
			insert_component(WAVE_TYPES.RECT,wave,wc)
		elif wc is NoiseWave:
			insert_component(WAVE_TYPES.NOISE,wave,wc)
		elif wc is LpfFilter:
			insert_component(WAVE_TYPES.LPF,wave,wc)
		elif wc is HpfFilter:
			insert_component(WAVE_TYPES.HPF,wave,wc)
		elif wc is BpfFilter:
			insert_component(WAVE_TYPES.BPF,wave,wc)
		elif wc is BrfFilter:
			insert_component(WAVE_TYPES.BRF,wave,wc)
		elif wc is ClampFilter:
			insert_component(WAVE_TYPES.CLAMP,wave,wc)
		elif wc is NormalizeFilter:
			insert_component(WAVE_TYPES.NORM,wave,wc)
		elif wc is QuantizeFilter:
			insert_component(WAVE_TYPES.QUANT,wave,wc)
		elif wc is PowerFilter:
			insert_component(WAVE_TYPES.POWER,wave,wc)
		elif wc is DecayFilter:
			insert_component(WAVE_TYPES.DECAY,wave,wc)
	wave.readjust_inputs()
	calculate()

func insert_component(type:int,wave:SynthWave,wc:WaveComponent)->void:
	var new_node:WaveController=WAVES[type][2].instance()
	new_node.wave=wave
	new_node.component=wc
	new_node.designer=self
	new_node.connect("params_changed",self,"calculate")
	components.add_child(new_node)
	new_but.raise()

func _on_New_id_pressed(id:int)->void:
	var wave:Waveform=GLOBALS.song.get_wave(curr_wave_ix)
	if wave==null:
		return
	var wc:WaveComponent=null
	if id==WAVE_TYPES.SIN:
		wc=SineWave.new()
	elif id==WAVE_TYPES.TRI:
		wc=TriangleWave.new()
	elif id==WAVE_TYPES.SAW:
		wc=SawWave.new()
	elif id==WAVE_TYPES.RECT:
		wc=RectangleWave.new()
	elif id==WAVE_TYPES.NOISE:
		wc=NoiseWave.new()
	elif id==WAVE_TYPES.LPF:
		wc=LpfFilter.new()
	elif id==WAVE_TYPES.HPF:
		wc=HpfFilter.new()
	elif id==WAVE_TYPES.BPF:
		wc=BpfFilter.new()
	elif id==WAVE_TYPES.BRF:
		wc=BrfFilter.new()
	elif id==WAVE_TYPES.CLAMP:
		wc=ClampFilter.new()
	elif id==WAVE_TYPES.NORM:
		wc=NormalizeFilter.new()
	elif id==WAVE_TYPES.QUANT:
		wc=QuantizeFilter.new()
	elif id==WAVE_TYPES.POWER:
		wc=PowerFilter.new()
	elif id==WAVE_TYPES.DECAY:
		wc=DecayFilter.new()
	wave.components.append(wc)
	insert_component(id,wave,wc)
	wave.readjust_inputs()
	calculate()

func _on_delete_requested(control:WaveController)->void:
	var wave:SynthWave=control.wave
	var cmp_ix:int=control.get_component_index(control.component)
	wave.components.remove(cmp_ix)
	regen_editor_nodes(wave)

func _on_move_requested(control:WaveController,direction:int)->void:
	var wave:SynthWave=control.wave
	var cmp_ix0:int=control.get_component_index(control.component)
	var cmp_ix1:int=cmp_ix0+direction
	if cmp_ix1<0 or cmp_ix1>=wave.components.size():
		return
	var tmp:WaveComponent=wave.components[cmp_ix1]
	wave.components[cmp_ix1]=wave.components[cmp_ix0]
	wave.components[cmp_ix0]=tmp
	regen_editor_nodes(wave)

#

func calculate()->void:
	var wave:Waveform=GLOBALS.song.get_wave(curr_wave_ix)
	if wave!=null:
		wave.calculate()
		SYNCER.send_wave(wave)
	emit_signal("wave_calculated",curr_wave_ix)


func _on_Designer_gui_input(ev:InputEvent)->void:
	if curr_wave_ix==-1 or not (ev is InputEventMouseButton and ev.is_released()):
		return
	if ev.button_index==BUTTON_RIGHT:
		accept_event()
		new_menu.rect_position=ev.position+$Designer.rect_global_position
		new_menu.popup()


func _on_New_pressed()->void:
	var ev:InputEventMouseButton=InputEventMouseButton.new()
	var d:Control=$Designer
	var n:Control=new_but
	ev.position=(new_but.rect_size*0.5)
	while n!=d:
		ev.position+=n.rect_position
		n=n.get_parent()
	ev.button_index=BUTTON_RIGHT
	ev.pressed=false
	_on_Designer_gui_input(ev)
