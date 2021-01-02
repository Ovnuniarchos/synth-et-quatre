tool extends ProgressBar
class_name SpinBar


export (float) var big_step:float=10.0
export (float) var huge_step:float=100.0
export (int,0,4) var _decimals:int=0 setget set_decimals
export (String) var suffix:String="" setget set_suffix


var real_theme:Theme
var dragging:bool=false
var pressed:bool=false
var label:Label
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
	label.text=format_value(value)


func _ready()->void:
	real_theme=THEME.get("theme")
	for c in get_children():
		remove_child(c)
	ThemeParser.set_styles(real_theme,"SpinBar",label)
	ThemeParser.set_styles(real_theme,"SpinBar",self)
	var sb:StyleBox=real_theme.get_stylebox("bg","SpinBar")
	var f:Font=get_font("font")
	var s0:Vector2=f.get_string_size(format_value(min_value)+"  ")
	var s1:Vector2=f.get_string_size(format_value(max_value)+"  ")
	rect_min_size=Vector2(max(max(s0.x,s1.x),rect_min_size.x),max(max(s0.y,s1.y),rect_min_size.y))
	rect_min_size+=Vector2(sb.content_margin_left+sb.content_margin_right,sb.content_margin_top+sb.content_margin_bottom)
	add_child(label)


func _set(prop:String,val)->bool:
	if __setting:
		__setting=false
		return false
	__setting=true
	if prop=="value":
		set_value(val)
	else:
		set(prop,val)
	return true


func set_decimals(v:int)->void:
	_decimals=v
	set_value(value)


func set_suffix(v:String)->void:
	suffix=v
	set_value(value)


func set_value(v:float)->void:
	value=clamp(v,min_value,max_value)
	if label!=null:
		label.text=format_value(value)


func format_value(v:float)->String:
	var f:String
	if _decimals==0:
		f="%d %s"
	else:
		f="%."+String(_decimals)+"f %s"
	return f%[v,suffix]


func _gui_input(ev:InputEvent)->void:
	if process_clicks(ev as InputEventMouseButton):
		accept_event()
	elif process_motion(ev as InputEventMouseMotion):
		accept_event()


func process_clicks(ev:InputEventMouseButton)->bool:
	if ev==null:
		return false
	if ev.button_index==BUTTON_LEFT:
		pressed=ev.is_pressed()
		set_value(lerp(min_value,max_value,ev.position.x/rect_size.x))
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
	set_value(lerp(min_value,max_value,ev.position.x/rect_size.x))
	return true
