extends Button
class_name OrderButton

var clipper:Control=self

func _init(clip:Control)->void:
	clipper=clip
	focus_mode=FOCUS_NONE
	mouse_filter=Control.MOUSE_FILTER_STOP
	button_mask=BUTTON_MASK_LEFT|BUTTON_MASK_RIGHT

func _input(ev:InputEvent)->void:
	ev=ev as InputEventMouseButton
	if ev==null or GLOBALS.is_any_dialog_open():
		return
	if is_visible_in_tree() and get_global_rect().clip(clipper.get_global_rect()).has_point(ev.global_position):
		set_block_signals(false)
		emit_signal("gui_input",ev)
		set_block_signals(true)

