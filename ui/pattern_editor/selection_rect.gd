extends Node2D

export (Vector2) var cell_size:Vector2=Vector2(8.0,16.0) setget set_cell_size

var selection:Selection setget set_selection

func set_cell_size(cs:Vector2)->void:
	cell_size=cs.abs()
	update()

func set_selection(s:Selection)->void:
	if s!=selection:
		selection=s
		selection.connect("selection_changed",self,"_on_selection_changed")

func _on_selection_changed()->void:
	visible=selection.active
	update()


func _draw()->void:
	if selection==null or !selection.active:
		return
	var r:Rect2=Rect2(selection.rect.position*cell_size,selection.rect.size*cell_size)
	draw_rect(r,Color(1.0,1.0,1.0),false)
