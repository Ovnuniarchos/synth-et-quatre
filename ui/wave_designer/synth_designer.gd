extends VBoxContainer

signal wave_calculated(wave_ix)
signal name_changed(wave_ix,text)

enum WAVE_TYPES{SIN,TRI,SAW,RECT,NOISE,LPF,HPF,BPF,BRF,CLAMP,NORM,QUANT}
const WAVES=[
	["Sine",WAVE_TYPES.SIN,preload("wave_nodes/sine_wave.tscn")],
	["Triangle",WAVE_TYPES.TRI,preload("wave_nodes/triangle_wave.tscn")],
	["Saw",WAVE_TYPES.SAW,preload("wave_nodes/saw_wave.tscn")],
	["Rectangle",WAVE_TYPES.RECT,preload("wave_nodes/rect_wave.tscn")],
	["Noise",WAVE_TYPES.NOISE,preload("wave_nodes/noise_wave.tscn")],
	["Low Pass",WAVE_TYPES.LPF,preload("filter_nodes/lpf_filter.tscn")],
	["High Pass",WAVE_TYPES.HPF,preload("filter_nodes/hpf_filter.tscn")],
	["Band Pass",WAVE_TYPES.BPF,preload("filter_nodes/bpf_filter.tscn")],
	["Band Reject",WAVE_TYPES.BRF,preload("filter_nodes/brf_filter.tscn")],
	["Clamp",WAVE_TYPES.CLAMP,preload("filter_nodes/clamp_filter.tscn")],
	["Normalize",WAVE_TYPES.NORM,preload("filter_nodes/normalize_filter.tscn")],
	["Quantize",WAVE_TYPES.QUANT,preload("filter_nodes/quantize_filter.tscn")],
]

var curr_wave_ix:int=-1
var new_but:MenuButton
var components:HBoxContainer

func _ready():
	new_but=$Designer/SC/Components/New
	components=$Designer/SC/Components
	var pp:PopupMenu=new_but.get_popup()
	for sn in WAVES:
		pp.add_item(sn[0],sn[1])
	pp.connect("id_pressed",self,"_on_New_id_pressed")
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
	var w:SynthWave=GLOBALS.song.get_wave(curr_wave_ix) as SynthWave
	if w!=null:
		w.size_po2=value
		calculate()
	set_size_bytes(value)

func set_size_bytes(size:int)->void:
	if size>0:
		$Info/HBC/LabelSizeSamples.text="%d samples"%[1<<size]
	else:
		$Info/HBC/LabelSizeSamples.text="-- samples"

func _on_wave_selected(wave:int)->void:
	curr_wave_ix=wave
	var w:SynthWave=GLOBALS.song.get_wave(curr_wave_ix) as SynthWave
	if w==null:
		$Info/HBC/Name.editable=false
		$Info/HBC/Name.text=""
		$Info/HBC/Size.editable=false
		set_size_bytes(-1)
		$Designer/SC.visible=false
	else:
		$Info/HBC/Name.editable=true
		$Info/HBC/Name.text=w.name
		$Info/HBC/Size.editable=true
		$Info/HBC/Size.value=w.size_po2
		set_size_bytes(w.size_po2)
		$Designer/SC.visible=true
	if components!=null:
		regen_editor_nodes(w)
	calculate()

# warning-ignore:unused_argument
func _on_wave_deleted(wave:int)->void:
	curr_wave_ix=-1
	$Info/HBC/Name.editable=false
	$Info/HBC/Name.text=""
	$Info/HBC/Size.editable=false
	set_size_bytes(-1)
	regen_editor_nodes(null)
	calculate()

#

func regen_editor_nodes(wave:Waveform)->void:
	for n in components.get_children():
		if n is WaveController:
			n.queue_free()
	if !(wave is SynthWave):
		return
	for wc in (wave as SynthWave).components:
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
			insert_component(WAVE_TYPES.NORM,wave,wc)
	wave.readjust_inputs()
	calculate()

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
	wave.components.append(wc)
	insert_component(id,wave,wc)
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
		GLOBALS.song.send_wave(wave,SYNTH)
	emit_signal("wave_calculated",curr_wave_ix)
