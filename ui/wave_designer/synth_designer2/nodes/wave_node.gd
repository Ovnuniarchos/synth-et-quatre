extends GraphNode
class_name WaveNode


export (String) var base_title:String setget set_base_title

var min_size:Vector2


func _ready()->void:
	min_size=rect_size
	if not Engine.editor_hint:
		var c:Color=ThemeHelper.get_color("port_color","GraphNode")
		for i in get_child_count():
			set_slot_color_left(i,c)
			set_slot_color_right(i,c)


func set_base_title(t:String)->void:
	base_title=t
	title=tr(t)


func _on_close_request()->void:
	breakpoint


func _on_resize_request(sz:Vector2)->void:
	rect_size=sz
