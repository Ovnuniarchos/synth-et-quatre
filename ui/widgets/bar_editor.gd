tool extends HBoxContainer
class_name BarEditor

signal values_changed(values,steps)

var loop_start:int=-1
var loop_end:int=-1
var values:Array setget set_values
var steps:int=0

var step_bar:SpinBar
var values_graph:Control
var loop_graph:Control
var val_tooltip:Tooltip
var real_theme:Theme

export (float) var min_value:float=-12.0
export (float) var max_value:float=12.0
export (float) var center_value:float=0.0
export (float) var step:float=1.0
export (float) var big_step:float=4.0
export (float) var huge_step:float=16.0
export (bool) var relative:bool=true


func _init()->void:
	values.resize(256)
	init_values()
	
func _ready()->void:
	real_theme=THEME.theme
	step_bar=$Params/Steps
	values_graph=$Editor/HBC/Values
	loop_graph=$Editor/HBC/LoopRange
	val_tooltip=$Editor/HBC/Values/Value
	values_graph.connect("gui_input",self,"on_Values_gui_input")
	loop_graph.connect("gui_input",self,"on_LoopRange_gui_input")

func init_values()->void:
	values.fill(center_value)

func set_values(v:Array)->void:
	steps=min(256,v.size())
	for i in steps:
		values[i]=v[i]
	values_graph.update()

func set_steps(s:int)->void:
	$Params/Steps.value=s

func on_Values_gui_input(ev:InputEvent)->void:
	if not ev is InputEventMouse:
		return
	var st:float=step*(big_step if ev.shift else 1.0)*(huge_step if ev.control else 1.0)
	var ym:float=values_graph.rect_size.y
	var ix:int=ev.position.x/16.0
	var yv:float
	var redraw:bool=false
	if ev.button_mask==BUTTON_MASK_LEFT:
		if relative:
			yv=range_lerp(ev.position.y,0.0,ym,max_value,min_value)
		else:
			yv=range_lerp(ev.position.y,0.0,ym,max_value,min_value)
		if ix<steps:
			redraw=true
			yv=clamp(stepify(yv,st),min_value,max_value)
	elif ev.button_mask==8 or ev.button_mask==16:
		st*=(-1.0 if ev.button_mask==16 else 1.0)
		if ix<steps:
			redraw=true
			yv=clamp(values[ix]+st,min_value,max_value)
	elif ev.button_mask==0 and ev is InputEventMouseMotion:
		val_tooltip.fade()
	if redraw:
		values[ix]=yv
		values_graph.update()
		val_tooltip.show_at(String(yv),ev.position-Vector2(0.0,val_tooltip.rect_size.y*0.5))

func on_LoopRange_gui_input(ev:InputEvent)->void:
	if not ev is InputEventMouse:
		return
	var ix:int=ev.position.x/16.0
	var redraw:bool=false
	if ev.button_mask==BUTTON_MASK_LEFT:
		ix=clamp(ix,0,steps)
		if loop_start<0:
			loop_start=ix
			loop_end=loop_start
		elif abs(ix-loop_end)<=abs(ix-loop_start):
			loop_end=ix
			loop_start=min(loop_start,loop_end)
		else:
			loop_start=ix
			loop_end=max(loop_start,loop_end)
		redraw=true
	elif ev.button_mask==BUTTON_MASK_RIGHT:
		loop_start=-1
		loop_end=-1
		redraw=true
	if redraw:
		loop_graph.update()

func _on_Steps_value_changed(s:int)->void:
	steps=s
	if s>0:
		loop_start=min(s-1,loop_start)
		loop_end=min(s-1,loop_end)
	else:
		loop_start=-1
		loop_end=-1
	$Editor/HBC.rect_size.x=steps*16.0
	emit_signal("values_changed",values,steps)
	values_graph.update()
	loop_graph.update()

func _on_Values_draw()->void:
	values_graph.rect_min_size.x=steps*16.0
	var ym:float=values_graph.rect_size.y
	var y0:float=range_lerp(center_value,min_value,max_value,ym,0.0)
	var x0:float=0.0
	var yv:float
	if relative:
		for i in steps:
			values_graph.draw_line(Vector2(x0,y0),Vector2(x0+15.0,y0),Color.white)
			yv=range_lerp(values[i],min_value,max_value,ym,0.0)
			values_graph.draw_rect(Rect2(x0,yv-4.0,15.0,8.0),Color.white)
			x0+=16.0
	else:
		for i in steps:
			yv=-range_lerp(values[i],min_value,max_value,0.0,ym)
			values_graph.draw_rect(Rect2(x0,ym,15.0,yv),Color.white)
			x0+=16.0

func _on_LoopRange_draw()->void:
	if loop_start<0 or loop_end<0:
		return
	var x0:float=loop_start*16.0
	for _i in range(loop_start,loop_end+1):
		loop_graph.draw_rect(Rect2(x0,0.0,15.0,loop_graph.rect_size.y),Color.white)
		x0+=16.0


func _on_Editor_draw():
	var e:Control=$Editor
	var sb:=real_theme.get_stylebox("panel","PanelContainer")
	e.draw_style_box(sb,Rect2(Vector2.ZERO,Vector2(e.rect_size.x,values_graph.rect_size.y)))
	e.draw_style_box(sb,Rect2(loop_graph.rect_position,Vector2(e.rect_size.x,loop_graph.rect_size.y)))
