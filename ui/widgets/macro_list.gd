extends VBoxContainer

func _ready()->void:
	var w:float=128.0
	for c in get_children():
		w=max(w,c.get_node("Params").rect_size.x)
	for c in get_children():
		c.get_node("Params").rect_min_size.x=w
