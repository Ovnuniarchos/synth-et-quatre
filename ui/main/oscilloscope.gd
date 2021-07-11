tool extends WavePlotter


var divider:int
var rate:int


func _ready()->void:
	if !Engine.editor_hint:
		rate=CONFIG.get_value(CONFIG.EDIT_OSCRATE)
	fft=AudioServer.get_bus_effect_instance(0,0)
	divider=0
	AUDIO.connect("buffer_sent",self,"draw_music")
	CONFIG.connect("config_changed",self,"on_config_changed")
	connect("gui_input",self,"_on_gui_input")


func on_config_changed(section:String,key:String,value)->void:
	if CONFIG.item_equals(section,key,CONFIG.EDIT_OSCRATE):
		rate=int(value)


func draw_music(buf:Array)->void:
	divider+=1
	if divider>=rate:
		divider=0
		buffer=buf
		update()


func _unhandled_input(ev:InputEvent)->void:
	if not(ev is InputEventKey):
		return
	if ev.scancode!=GKBD.OSCILLOSCOPE_TOGGLE:
		return
	accept_event()
	if ev.pressed:
		return
	visible=not visible


func _on_gui_input(ev:InputEvent)->void:
	if !(ev is InputEventMouseButton):
		return
	if ev.is_pressed():
		get_tree().set_input_as_handled()
		return
	if ev.button_index==3:
		y_scale=1.0
		get_tree().set_input_as_handled()
		update()
	elif ev.button_index==4:
		y_scale=min(y_scale+(1.0 if y_scale>=1.0 else 0.05),20.0)
		get_tree().set_input_as_handled()
		update()
	elif ev.button_index==5:
		y_scale=max(y_scale-(0.05 if y_scale<=1.0 else 1.0),0.05)
		get_tree().set_input_as_handled()
		update()
