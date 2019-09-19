extends Button
class_name OrderButton

var order:int=0
var channel:int=0
var clipper:Control=self

func _init()->void:
	mouse_filter=Control.MOUSE_FILTER_STOP
	button_mask=BUTTON_MASK_LEFT|BUTTON_MASK_RIGHT

func _input(ev:InputEvent)->void:
	ev=ev as InputEventMouseButton
	if ev==null:
		return
	if get_global_rect().clip(clipper.get_global_rect()).has_point(ev.global_position):
		set_block_signals(false)
		emit_signal("gui_input",ev)
		set_block_signals(true)

