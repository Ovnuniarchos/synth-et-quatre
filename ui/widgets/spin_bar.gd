tool extends ProgressBar
class_name SpinBar


const MIN_DRAG_DIST:float=8.0
const MODE_NORMAL:String="normal"
const MODE_DISABLED:String="disabled"
const MODE_HOVER:String="hover"


export (float) var big_step:float=10.0
export (float) var huge_step:float=100.0
export (int,0,4) var _decimals:int=0 setget set_decimals
export (String) var suffix:String="" setget set_suffix
export (bool) var editable:bool=true setget set_editable


var dragging:bool=false
var pressed:bool=false
var press_pos:Vector2
var label:Label
var input:NumberEdit
var mode:String=MODE_NORMAL
var __setting:bool=false


func _init()->void:
	percent_visible=false
	label=Label.new()
	label.align=HALIGN_CENTER
	label.valign=VALIGN_CENTER
	label.clip_text=true
	label.set_anchors_preset(Control.PRESET_WIDE)
	label.size_flags_horizontal=SIZE_EXPAND_FILL|SIZE_SHRINK_CENTER
	label.size_flags_vertical=SIZE_EXPAND_FILL|SIZE_SHRINK_CENTER
	label.text=format_value(value)+" "+suffix
	input=NumberEdit.new()
	input.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	input.align=LineEdit.ALIGN_CENTER
	input.editable=false
	input.visible=true
	input.context_menu_enabled=false
	if !Engine.editor_hint:
		input.connect("text_entered",self,"_on_text_entered")
		input.connect("value_changed",self,"_on_value_changed")
		input.connect("focus_exited",self,"_on_text_canceled")
		input.connect("gui_input",self,"_gui_input")
		if not is_connected("mouse_entered",self,"_on_mouse_enter"):
			connect("mouse_entered",self,"_on_mouse_enter")
		if not is_connected("mouse_exited",self,"_on_mouse_exit"):
			connect("mouse_exited",self,"_on_mouse_exit")
		if not is_connected("value_changed",self,"_on_value_changed"):
			connect("value_changed",self,"_on_value_changed")


func _ready()->void:
	for c in get_children():
		remove_child(c)
	ThemeHelper.apply_styles(ThemeHelper.get_theme(),"SpinBar",label)
	ThemeHelper.apply_styles(ThemeHelper.get_theme(),"SpinBar",input)
	ThemeHelper.apply_styles(ThemeHelper.get_theme(),"SpinBar",self)
	input.add_constant_override("minimum_spaces",0)
	input.add_stylebox_override("read_only",ThemeHelper.get_stylebox("empty_panel",""))
	input.add_stylebox_override("focus",ThemeHelper.get_stylebox("empty_panel",""))
	input.add_stylebox_override("normal",ThemeHelper.get_stylebox("empty_panel",""))
	var sb:StyleBox=get_stylebox("bg")
	var f:Font=get_font("font")
	var s0:Vector2=f.get_string_size(format_value(min_value)+"   "+suffix)
	var s1:Vector2=f.get_string_size(format_value(max_value)+"   "+suffix)
	rect_min_size=Vector2(max(max(s0.x,s1.x),rect_min_size.x),max(max(s0.y,s1.y),rect_min_size.y))
	rect_min_size+=Vector2(sb.content_margin_left+sb.content_margin_right,sb.content_margin_top+sb.content_margin_bottom)
	add_child(label)
	input.set_min_val(min_value)
	input.set_max_val(max_value)
	input.set_decimals(_decimals)
	input.set_negative(min_value<0)
	add_child(input)
	switch_input(false)


func set_value(f:float)->void:
	.set_value(f)
	_on_value_changed(f)


func set_value_no_signal(f:float)->void:
	.set_value_no_signal(f)
	_on_value_changed(f)
	update()

func set_max(f:float)->void:
	.set_max(f)
	input.set_max_val(f)
	update()

func set_min(f:float)->void:
	.set_min(f)
	input.set_min_val(f)
	update()

func set_decimals(v:int)->void:
	step=pow(10.0,-v)
	_decimals=v
	input.set_decimals(v)
	set_value(value)


func set_suffix(v:String)->void:
	suffix=v
	set_value(value)


func set_editable(e:bool)->void:
	editable=e
	set_mode(mode)


func _on_value_changed(v:float)->void:
	if allow_greater and allow_lesser:
		.set_value_no_signal(v)
	elif allow_greater:
		.set_value_no_signal(max(min_value,v))
	elif allow_lesser:
		.set_value_no_signal(min(max_value,v))
	else:
		.set_value_no_signal(clamp(v,min_value,max_value))
	input.set_value_no_signal(value)
	if label!=null:
		label.text=format_value(value)+" "+suffix


func format_value(v:float)->String:
	var f:String
	if _decimals==0:
		f="%d"
	else:
		f="%."+String(_decimals)+"f"
	return f%v


func _gui_input(ev:InputEvent)->void:
	if not editable:
		return
	if process_clicks(ev as InputEventMouseButton):
		accept_event()
	elif process_motion(ev as InputEventMouseMotion):
		accept_event()
	elif process_keyboard(ev as InputEventKey):
		accept_event()


func process_clicks(ev:InputEventMouseButton)->bool:
	if ev==null:
		return false
	if input.visible:
		return true
	if ev.button_index==BUTTON_LEFT:
		pressed=ev.is_pressed()
		if pressed:
			press_pos=ev.position
		elif abs(ev.position.x-press_pos.x)<MIN_DRAG_DIST:
			switch_input(true)
		else:
			set_value(lerp(min_value,max_value,ev.position.x/rect_size.x))
			set_mode(MODE_HOVER if Rect2(Vector2(),rect_size).has_point(get_local_mouse_position()) else MODE_NORMAL)
		return true
	elif ev.button_index in [BUTTON_WHEEL_DOWN,BUTTON_WHEEL_UP]:
		if not ev.is_pressed():
			var delta:float=step
			if ev.shift:
				delta*=big_step
			if ev.control:
				delta*=huge_step
			set_value(value+delta*(1.0 if ev.button_index==BUTTON_WHEEL_UP else -1.0))
		return true
	return false


func process_motion(ev:InputEventMouseMotion)->bool:
	if ev==null or not pressed:
		return false
	if input.visible:
		return true
	if abs(ev.position.x-press_pos.x)>=MIN_DRAG_DIST:
		press_pos.x=-1e10
		set_mode(MODE_HOVER)
		set_value(lerp(min_value,max_value,ev.position.x/rect_size.x))
	return true


func process_keyboard(ev:InputEventKey)->bool:
	if ev==null:
		return false
	if ev.scancode==KEY_ESCAPE:
		if not ev.pressed:
			switch_input(false)
	return true


func switch_input(on:bool)->void:
	if on:
		set_mode(MODE_NORMAL)
		input.rect_size=rect_size
		input.rect_position=Vector2.ZERO
		input.text=format_value(value)
		input.grab_focus()
	else:
		set_mode(MODE_HOVER if Rect2(Vector2(),rect_size).has_point(get_local_mouse_position()) else MODE_NORMAL)
		input.set_block_signals(true)
		input.release_focus()
		input.set_block_signals(false)
		if !Engine.editor_hint:
			emit_signal("focus_exited")
	input.editable=on
	input.visible=on
	label.visible=not on


func _on_text_entered(t:String)->void:
	set_value(float(t))
	switch_input(false)


func _on_text_canceled()->void:
	switch_input(false)


func _on_mouse_enter()->void:
	set_mode(MODE_HOVER)


func _on_mouse_exit()->void:
	set_mode(MODE_NORMAL)


func set_mode(s:String)->void:
	mode=s
	if not editable:
		s=MODE_DISABLED
	add_stylebox_override("fg",ThemeHelper.get_stylebox("fg_"+s,"SpinBar"))
	add_stylebox_override("bg",ThemeHelper.get_stylebox("bg_"+s,"SpinBar"))
	label.add_color_override("font_color",ThemeHelper.get_color("font_color_"+s,"SpinBar"))
	label.add_font_override("font",ThemeHelper.get_font("font_"+s,"SpinBar"))
	input.add_color_override("font_color",ThemeHelper.get_color("font_color_"+s,"SpinBar"))
	input.add_font_override("font",ThemeHelper.get_font("font_"+s,"SpinBar"))
