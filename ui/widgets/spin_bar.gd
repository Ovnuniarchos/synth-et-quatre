tool extends ProgressBar
class_name SpinBar


export (float) var big_step:float=10.0
export (float) var huge_step:float=100.0

var dragging:bool=false
var pressed:bool=false


func _init()->void:
	percent_visible=false


func _get_property_list()->Array:
	var props:Array=get_script().get_script_property_list()
	for p in props:
		if p["name"] in ["Percent","percent_visible"]:
			print(p)
			p["usage"]=0
	return props


func set_value(v:float)->void:
	value=clamp(v,min_value,max_value)
	$Label.text=String(value)


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
