extends Node2D

export (Vector2) var cell_size=Vector2(8.0,16.0) setget set_cell_size
export (float) var thickness=2.0 setget set_thickness

func set_cell_size(s:Vector2)->void:
	cell_size=s
	update()

func set_thickness(t:float)->void:
	thickness=t
	update()

func _draw()->void:
	draw_rect(Rect2(Vector2(),cell_size),Color.white,false,thickness)
