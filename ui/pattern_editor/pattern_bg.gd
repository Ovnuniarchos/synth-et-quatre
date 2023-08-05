extends Node2D

export (Color) var color_base:Color=Color("202020")
export (Color) var color_min:Color=Color("404040")
export (Color) var color_maj:Color=Color("606060")
export (Color) var color_active:Color=Color("807060")
export (int) var rows:int=64 setget set_rows
export (int) var row:int=0 setget set_row
export (int) var every_min:int=4 setget set_every_min
export (int) var every_maj:int=16 setget set_every_maj


func set_rows(r:int)->void:
	rows=r
	update()

func set_row(r:int)->void:
	row=r
	update()

func set_every_min(e:int)->void:
	every_min=e
	update()

func set_every_maj(e:int)->void:
	every_maj=e
	update()

func _draw():
	var y:float=0.0
	var c:Color
	for i in range(rows):
		if i==row:
			c=color_active
		elif (i%every_maj)==0:
			c=color_maj
		elif (i%every_min)==0:
			c=color_min
		else:
			c=color_base
		draw_rect(Rect2(0,y,16384,16),c)
		y+=16.0
