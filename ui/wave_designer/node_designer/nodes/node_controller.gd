extends GraphNode
class_name NodeController

signal about_to_close(node)
signal params_changed(node)


var node:WaveNodeComponent

export (String) var base_title:String setget set_base_title


func _init()->void:
	connect("close_request",self,"_on_close_request")
	connect("resize_request",self,"_on_resize_request")
	connect("offset_changed",self,"_on_offset_changed")


func _ready()->void:
	if not Engine.editor_hint:
		var c:Color=ThemeHelper.get_color("port_color","GraphNode")
		for i in get_child_count():
			if is_slot_enabled_left(i):
				set_slot_color_left(i,c)
			if is_slot_enabled_right(i):
				set_slot_color_right(i,c)
	if node.viz_rect.is_equal_approx(Rect2(Vector2.ZERO,Vector2.ZERO)):
		node.viz_rect=Rect2(offset,rect_size)
	else:
		offset=node.viz_rect.position
		rect_size=node.viz_rect.size
	_notification(NOTIFICATION_TRANSLATION_CHANGED)


func _notification(n:int)->void:
	if n==NOTIFICATION_TRANSLATION_CHANGED:
		var min_width:float=0.0
		for n in get_children():
			if n is HBoxContainer:
				var l:Label=n.get_child(0)
				var f:Font=l.get_font("font")
				min_width=max(min_width,f.get_string_size(tr(l.text)).x)
		for n in get_children():
			if n is HBoxContainer:
				n.get_child(0).rect_min_size.x=min_width


func set_base_title(t:String)->void:
	base_title=t
	title=tr(t)


func _on_close_request()->void:
	emit_signal("about_to_close",self)


func _on_resize_request(sz:Vector2)->void:
	rect_size.x=sz.x
	node.viz_rect.size.x=sz.x


func _on_offset_changed()->void:
	node.viz_rect.position=offset


func invalidate()->void:
	node.invalidate()


func connect_node(from:NodeController,to:int)->void:
	node.connect_node(from.node,to)
	node.invalidate()


func disconnect_node(from:NodeController,to:int)->void:
	node.disconnect_node(from.node,to)
	node.invalidate()

