tool extends ProgressBar
class_name SpinBar


export (float) var big_step:float=10.0
export (float) var huge_step:float=100.0
export (int,0,4) var _decimals:int=0

var dragging:bool=false
var pressed:bool=false
var label:Label
var __setting:bool=false


func _init()->void:
	percent_visible=false
	size_flags_horizontal=SIZE_EXPAND_FILL|SIZE_SHRINK_CENTER
	size_flags_vertical=SIZE_EXPAND_FILL|SIZE_SHRINK_CENTER
	label=Label.new()
	label.align=HALIGN_CENTER
	label.valign=VALIGN_CENTER
	label.clip_text=true
	label.set_anchors_preset(Control.PRESET_WIDE)
	label.size_flags_horizontal=SIZE_EXPAND_FILL|SIZE_SHRINK_CENTER
	label.size_flags_vertical=SIZE_EXPAND_FILL|SIZE_SHRINK_CENTER
	label.text=format_value()


func _ready()->void:
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


func set_value(v:float)->void:
	value=clamp(v,min_value,max_value)
	if label!=null:
		label.text=format_value()


func format_value()->String:
	var f:String
	if _decimals==0:
		f="%d"
	else:
		f="%."+String(_decimals)+"f"
	return f%value


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
	elif ev.button_index in [BUTTON_WHEEL_DOWN,BUTTON_WHEEL_UP] and not ev.is_pressed():
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
