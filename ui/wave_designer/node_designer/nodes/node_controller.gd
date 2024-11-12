tool extends GraphNode
class_name NodeController

signal about_to_close(node)
signal params_changed(node)


enum {SLOT_VALUE,SLOT_DIFF_BOOL,SLOT_BOOL}
const SLOT_COLORS:Array=[
	Color("ffffff"),
	Color("00ffff"),
	Color("00ff00")
]


var node:WaveNodeComponent

export (String) var base_title:String setget set_base_title


func _init()->void:
	if not is_connected("close_request",self,"_on_close_request"):
		connect("close_request",self,"_on_close_request")
	if not is_connected("resize_request",self,"_on_resize_request"):
		connect("resize_request",self,"_on_resize_request")
	if not is_connected("offset_changed",self,"_on_offset_changed"):
		connect("offset_changed",self,"_on_offset_changed")
	if not is_connected("slot_updated",self,"_on_slot_updated"):
		connect("slot_updated",self,"_on_slot_updated")


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
	for i in get_child_count():
		_on_slot_updated(i)
	_notification(NOTIFICATION_TRANSLATION_CHANGED)


func _notification(n:int)->void:
	if n==NOTIFICATION_TRANSLATION_CHANGED:
		var min_width:float=0.0
		var l:Label
		var f:Font
		for n in get_children():
			if n is HBoxContainer:
				l=n.get_child(0)
			elif n.has_method("get_label_control"):
				l=n.get_label()
			else:
				continue
			f=l.get_font("font")
			min_width=max(min_width,f.get_string_size(tr(l.text)).x)
		for n in get_children():
			if n is HBoxContainer:
				n.get_child(0).rect_min_size.x=min_width
			elif n.has_method("get_label_control"):
				n.get_label_control().rect_min_size.x=min_width


func set_base_title(t:String)->void:
	base_title=t
	title=tr(t)
	property_list_changed_notify()


func set_size_po2(s:int)->void:
	node.size_po2=s


func _on_close_request()->void:
	emit_signal("about_to_close",self)


func _on_resize_request(sz:Vector2)->void:
	rect_size.x=sz.x
	node.viz_rect.size.x=sz.x


func _on_offset_changed()->void:
	node.viz_rect.position=offset


func _on_slot_updated(slot:int)->void:
	var c_l:int
	var c_r:int
	c_l=get_slot_type_left(slot)
	c_r=get_slot_type_right(slot)
	set_block_signals(true)
	if is_slot_enabled_left(slot):
		set_slot_color_left(slot,SLOT_COLORS[c_l if c_l>=0 and c_l<=2 else 0])
	if is_slot_enabled_right(slot):
		set_slot_color_right(slot,SLOT_COLORS[c_r if c_r>=0 and c_r<=2 else 0])
	set_block_signals(false)
	property_list_changed_notify()


func invalidate()->void:
	node.invalidate()


func connect_node(from:NodeController,to:int)->void:
	node.connect_node(from.node,to)
	node.invalidate()


func disconnect_node(from:NodeController,to:int)->void:
	node.disconnect_node(from.node,to)
	node.invalidate()

