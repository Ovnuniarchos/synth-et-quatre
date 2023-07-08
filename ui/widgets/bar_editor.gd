tool extends HBoxContainer
class_name BarEditor

signal values_changed(values,steps)
signal loop_changed(start,end)
signal mode_changed(relative)
signal divisor_changed(divisor)
signal delay_changed(divisor)

enum{MODE_ABS,MODE_REL,MODE_SWABS,MODE_SWREL}

const MAX_STEPS:int=256

var loop_start:int=-1
var loop_end:int=-1
var values:Array setget set_values
var relative:bool=true
var steps:int=0
var tick_div:int=1
var delay:int=0

var height_sel:int=1
var line_start:Vector2=Vector2.INF
var line_end:Vector2
var line_buffer:Array

var title_button:Button
var step_bar:SpinBar
var values_graph:Control
var loop_graph:Control
var val_tooltip:Tooltip
var rel_button:Button
var real_theme:Theme
var editor:ScrollContainer

export (String) var title:String="Macro" setget set_title
export (float) var title_width:float=128.0 setget set_title_width
export (PoolRealArray) var heights:PoolRealArray=PoolRealArray([64.0,128.0,256.0])
export (float) var min_value_rel:float=-12.0
export (float) var max_value_rel:float=12.0
export (float) var center_value:float=0.0
export (float) var min_value_abs:float=0.0
export (float) var max_value_abs:float=48.0
export (float) var step:float=1.0
export (float) var big_step:float=4.0
export (float) var huge_step:float=16.0
export (int,"Absolute","Relative","SwitchAbs","SwitchRel") var mode:int=0


func _init()->void:
	values.resize(MAX_STEPS)
	init_values()

func _ready()->void:
	if Engine.editor_hint:
		real_theme=Theme.new()
	else:
		real_theme=THEME.theme
	title_button=$Params/Title
	step_bar=$Params/HBC/Steps
	values_graph=$Editor/Origin/HBC/Values
	loop_graph=$Editor/Origin/HBC/LoopRange
	val_tooltip=$Editor/Origin/Value
	editor=$Editor
	rel_button=$Params/Relative
	relative=mode==MODE_REL or mode==MODE_SWREL
	if mode>=MODE_SWABS:
		rel_button.pressed=mode==MODE_SWREL
		rel_button.visible=true
	else:
		rel_button.visible=false
	set_title(title)
	set_title_width(title_width)
	_on_Title_pressed(0)
	values_graph.update()
	loop_graph.update()

func set_title(t:String)->void:
	title=t
	if title_button!=null:
		title_button.text=t

func set_title_width(w:float)->void:
	title_width=w
	if title_button!=null:
		title_button.rect_min_size.x=w

func init_values()->void:
	values.fill(center_value)

func set_values(v:Array)->void:
	steps=min(MAX_STEPS,v.size())
	for i in steps:
		values[i]=v[i]
	values_graph.update()

func set_steps(s:int)->void:
	$Params/Steps.value=s

func _on_Values_gui_input(ev:InputEvent)->void:
	if not ev is InputEventMouse:
		return
	var st:float=step*(big_step if ev.shift else 1.0)*(huge_step if ev.control else 1.0)
	var ym:float=values_graph.rect_size.y
	var ix:int=clamp(ev.position.x/16.0,0.0,MAX_STEPS-1)
	var miv:float=min_value_rel if relative else min_value_abs
	var mxv:float=max_value_rel if relative else max_value_abs
	var yv:float=clamp(stepify(range_lerp(ev.position.y,0.0,ym,mxv,miv),st),miv,mxv)
	var redraw:bool=false
	if ev.button_mask==BUTTON_MASK_LEFT:
		redraw=true
	elif ev.button_mask==BUTTON_MASK_RIGHT:
		if line_start==Vector2.INF:
			line_start=Vector2(ix,yv)
			line_end=line_start
			line_buffer=values.duplicate()
		else:
			line_end=Vector2(ix,yv)
		redraw=true
	elif ev.button_mask==8 or ev.button_mask==16:
		st*=(-1.0 if ev.button_mask==16 else 1.0)
		yv=clamp(values[ix]+st,miv,mxv)
		redraw=true
	elif ev.button_mask==0 and ev is InputEventMouseMotion:
		val_tooltip.fade()
		if line_start!=Vector2.INF:
			line_start=Vector2.INF
	if redraw:
		if line_start==Vector2.INF:
			values[ix]=yv
		else:
			values=line_buffer.duplicate()
			var ls:Vector2=line_start
			var le:Vector2=line_end
			if ls.x>le.x:
				ls=line_end
				le=line_start
			if ls.x!=le.x:
				for i in range(ls.x,le.x+1):
					values[i]=range_lerp(i,ls.x,le.x,ls.y,le.y)
			else:
				values[ls.x]=le.y
		values_graph.update()
		val_tooltip.show_at(String(yv),ev.position-Vector2(0.0,val_tooltip.rect_size.y*0.5))
		emit_signal("values_changed",values,steps)

func _on_LoopRange_gui_input(ev:InputEvent)->void:
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
		emit_signal("loop_changed",loop_start,loop_end)

func _on_Steps_value_changed(s:int)->void:
	steps=s
	if s>0:
		loop_start=min(s-1,loop_start)
		loop_end=min(s-1,loop_end)
	else:
		loop_start=-1
		loop_end=-1
	$Editor/Origin.rect_min_size.x=steps*16.0
	values_graph.update()
	loop_graph.update()
	emit_signal("values_changed",values,steps)

func _on_Values_draw()->void:
	if values_graph==null:
		return
	values_graph.rect_min_size.x=steps*16.0
	var ym:float=values_graph.rect_size.y
	var y0:float=range_lerp(center_value,min_value_rel,max_value_rel,ym,0.0)
	var x0:float=0.0
	var yv:float
	if relative:
		for i in steps:
			values_graph.draw_line(Vector2(x0,y0),Vector2(x0+15.0,y0),Color.white)
			yv=range_lerp(values[i],min_value_rel,max_value_rel,ym,0.0)
			values_graph.draw_rect(Rect2(x0,yv-4.0,15.0,8.0),Color.white)
			x0+=16.0
	else:
		for i in steps:
			yv=-range_lerp(values[i],min_value_abs,max_value_abs,0.0,ym)
			values_graph.draw_rect(Rect2(x0,ym,15.0,yv),Color.white)
			x0+=16.0

func _on_LoopRange_draw()->void:
	if loop_start<0 or loop_end<0 or loop_graph==null:
		return
	var x0:float=loop_start*16.0
	for _i in range(loop_start,loop_end+1):
		loop_graph.draw_rect(Rect2(x0,0.0,15.0,loop_graph.rect_size.y),Color.white)
		x0+=16.0

func _on_Editor_draw():
	if editor==null or values_graph==null or loop_graph==null:
		return
	if Engine.editor_hint:
		editor.draw_rect(Rect2(Vector2.ZERO,editor.rect_size),Color.red,false)
		return
	var sb:=real_theme.get_stylebox("panel","PanelContainer")
	editor.draw_style_box(sb,Rect2(Vector2.ZERO,Vector2(editor.rect_size.x,values_graph.rect_size.y)))
	editor.draw_style_box(sb,Rect2(loop_graph.rect_position,Vector2(editor.rect_size.x,loop_graph.rect_size.y)))


func _on_Values_mouse_exited():
	val_tooltip.fade()

func _on_Relative_toggled(p:bool)->void:
	relative=p
	var v00:float=min_value_abs if relative else min_value_rel
	var v01:float=max_value_abs if relative else max_value_rel
	var v10:float=min_value_rel if relative else min_value_abs
	var v11:float=max_value_rel if relative else max_value_abs
	for i in MAX_STEPS:
		values[i]=stepify(range_lerp(values[i],v00,v01,v10,v11),step)
	values_graph.update()
	emit_signal("values_changed",values,steps)
	emit_signal("mode_changed",relative)

func _on_Title_pressed(delta:int)->void:
	if heights.size()<1:
		return
	height_sel=(height_sel+delta)%heights.size()
	rect_size.y=heights[height_sel]

func _on_Div_value_changed(v:float)->void:
	tick_div=v
	emit_signal("divisor_changed",tick_div)

func _on_Delay_value_changed(v:float)->void:
	delay=v
	emit_signal("delay_changed",delay)
