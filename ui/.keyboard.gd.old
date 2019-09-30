tool extends Control


export (Color) var flats_color:Color=Color.white
export (Color) var sharps_color:Color=Color.black
export (Color) var separation_color:Color=Color.black


var flat_rects:Array
var flats:Array=[0,2,4,5,7,9,11]
var sharp_rects:Array
var sharps:Array=[1,3,6,8,10]
var pressed:bool=false


func _init()->void:
	flat_rects=[]
	flat_rects.resize(77)
	sharp_rects=[]
	sharp_rects.resize(55)


func _ready()->void:
# warning-ignore:return_value_discarded
	connect("gui_input",self,"_on_gui_input")
# warning-ignore:return_value_discarded
	connect("mouse_exited",self,"_on_mouse_exited")


func _draw()->void:
	var kw:float=rect_size.x/77.0
	for i in range(0,77):
		flat_rects[i]=Rect2(i*kw,0.0,kw,rect_size.y)
		draw_rect(flat_rects[i],flats_color)
	for i in range(1,78):
		draw_line(Vector2(i*kw,0.0),Vector2(i*kw,rect_size.y),separation_color)
	var j:int=0
	for i in range(0,77):
		if (i%7)==0 or (i%7)==3:
			continue
		var x:float=i*kw
		sharp_rects[j]=Rect2(x-(kw*0.3),0.0,kw*0.6,rect_size.y*0.67)
		draw_rect(sharp_rects[j],sharps_color)
		draw_rect(sharp_rects[j],separation_color,false)
		j+=1


func _on_mouse_exited():
	pressed=false
	"""AUDIO.generator.key_off()"""


func _on_gui_input(event:InputEvent)->void:
	if !(event is InputEventMouse):
		return
	if event is InputEventMouseMotion and !pressed:
		return
	pressed=event.button_mask!=0
	for i in range(0,55):
		if (sharp_rects[i] as Rect2).has_point(event.position):
# warning-ignore:integer_division
			send_note(sharps[i%5]+((i/5)*12),event.shift)
			return
	for i in range(0,77):
		if (flat_rects[i] as Rect2).has_point(event.position):
# warning-ignore:integer_division
			send_note(flats[i%7]+((i/7)*12),event.shift)
			return


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func send_note(n:int,legato:bool)->void:
	pass
	"""if pressed:
		if legato:
			AUDIO.generator.set_note(n*100)
		else:
			AUDIO.generator.key_on(n*100)
	else:
		AUDIO.generator.key_off()"""

