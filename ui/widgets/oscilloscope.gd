tool extends Panel

var buffer:Array
var channels:int
var points:PoolVector2Array=PoolVector2Array()

export (Color) var bg_color=Color8(0,0,32) setget set_bg_color
export (Color) var left_color=Color8(255,0,0) setget set_left_color
export (Color) var right_color=Color8(0,255,0) setget set_right_color
export (bool) var dc_line=false setget set_dc_line
export (Color) var dc_line_color=Color8(255,255,255,64) setget set_dc_line_color

func plot_stereo_buffer(buf:PoolVector2Array)->void:
	buffer=Array(buf)
	channels=2
	update()

func plot_mono_buffer(buf:PoolRealArray)->void:
	buffer=Array(buf)
	channels=1
	update()

func _draw()->void:
	draw_rect(Rect2(Vector2(),rect_size),bg_color)
	draw_set_transform(Vector2(0,rect_size.y*0.5),0.0,Vector2(1.0,rect_size.y*-0.5))
	if dc_line:
		draw_line(Vector2(),Vector2(rect_size.x,0.0),dc_line_color)
	if buffer==null or buffer.size()==0:
		return
	var step:float=buffer.size()/rect_size.x
	points.resize(rect_size.x)
	var i:float=0.0
	if channels==2:
		for x in range(points.size()):
			points[x]=Vector2(x,buffer[floor(i)].x)
			i+=step
	else:
		for x in range(points.size()):
			points[x]=Vector2(x,buffer[floor(i)])
			i+=step
	draw_polyline(points,left_color)
	if channels==2:
		i=0.0
		for x in range(points.size()):
			points[x]=Vector2(x,buffer[floor(i)].y)
			i+=step
		draw_polyline(points,right_color)

func set_bg_color(c:Color)->void:
	bg_color=c
	update()

func set_left_color(c:Color)->void:
	left_color=c
	update()

func set_right_color(c:Color)->void:
	right_color=c
	update()

func set_dc_line(b:bool)->void:
	dc_line=b
	update()

func set_dc_line_color(c:Color)->void:
	dc_line_color=c
	update()
