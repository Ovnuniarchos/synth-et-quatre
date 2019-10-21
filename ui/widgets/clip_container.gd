tool extends Container
class_name ClipContainer

func _ready()->void:
	rect_clip_content=true
	size_flags_horizontal=SIZE_EXPAND_FILL
	size_flags_vertical=SIZE_EXPAND_FILL
	connect("sort_children",self,"_on_sort_children")

func _on_sort_children()->void:
	for c in get_children():
		fit_child_in_rect(c,Rect2(Vector2(),rect_size))

func _clips_input()->bool:
	return true
