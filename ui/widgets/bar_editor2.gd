extends HBoxContainer


signal macro_changed(parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)


enum{MODE_ABS,MODE_REL,MODE_SWABS,MODE_SWREL,MODE_MASK,MODE_SELECT}
enum{BIT_CLEAR,BIT_SWITCH,BIT_SET}

const MAX_STEPS:int=256


export (bool) var arpeggio:bool=false
export (String) var title:String="Macro" setget set_title
export (String) var parameter:String=""
export (int) var min_value_rel:int=-12.0
export (int) var max_value_rel:int=12.0
export (int) var center_value:int=0.0
export (int) var min_value_abs:int=0.0
export (int) var max_value_abs:int=48.0
export (int) var step:int=1.0
export (int) var big_step:int=4.0
export (int) var huge_step:int=16.0
export (int,"Absolute","Relative","SwitchAbs","SwitchRel","Mask","Select") var mode:int=MODE_SWREL
export (PoolStringArray) var labels:PoolStringArray=PoolStringArray()

var loop_start:int=-1
var loop_end:int=-1
var release_loop_start:int=-1
var values:Array
var values_abs:Array
var values_rel:Array
var relative:bool=true
var steps:int=0
var tick_div:int=1
var delay:int=0

var zoom:float=4.0

var values_graph:Control
var loop_graph:Control
var hscroll:HScrollBar
var vscroll:VScrollBar
var heights:PoolRealArray=PoolRealArray([160.0,240.0,320.0])
var height_sel:int=0
var hiddables:Array
var relative_button:Button

var is_ready:bool=false
var bar_width:float
var bar_height:float
var real_theme:Theme


func _ready()->void:
	if Engine.editor_hint:
		real_theme=Theme.new()
	else:
		real_theme=THEME.theme
	theme=real_theme
	init_node_caches()
	recalc_scrollbars()
	values_graph.get_parent().add_stylebox_override("panel",real_theme.get_stylebox("values","BarEditor"))
	loop_graph.get_parent().add_stylebox_override("panel",real_theme.get_stylebox("loop","BarEditor"))
	loop_graph.get_parent().rect_min_size.y=real_theme.get_constant("loop_height","BarEditor")
	is_ready=true
	values_abs.resize(MAX_STEPS)
	values_rel.resize(MAX_STEPS)
	if arpeggio:
		relative_button.visible=false
		$Params/GC/LDiv.visible=false
		$Params/GC/Div.visible=false
		relative=true
	else:
		relative=mode==MODE_REL or mode==MODE_SWREL
	init_values()
	if can_switch_modes():
		relative_button.set_pressed_no_signal(relative)
		relative_button.visible=true
	else:
		relative_button.visible=false
	set_title(title)



func init_node_caches()->void:
	values_graph=get_node("%VGraph")
	loop_graph=get_node("%LGraph")
	hscroll=get_node("%HScroll")
	vscroll=get_node("%VScroll")
	hiddables=[$Params/R,$Params/GC]
	relative_button=get_node("%Relative")


func init_values()->void:
	values_abs.fill(ParamMacro.PASSTHROUGH)
	values_rel.fill(ParamMacro.PASSTHROUGH)
	select_values()


func select_values()->void:
	if mode<MODE_MASK:
		values=values_rel if relative else values_abs
	else:
		values=values_abs


func get_bar_sizes()->void:
	bar_width=real_theme.get_constant("bar_size_x","BarEditor")
	bar_height=real_theme.get_constant("bar_size_y","BarEditor")


func _on_VScroll_visuals_changed()->void:
	if not is_ready:
		yield(self,"ready")
	var cf:ReferenceRect=get_node("%CornerFill")
	cf.rect_min_size.x=vscroll.rect_size.x


func get_VGraph_position(pos:Vector2)->Vector2:
	return Vector2(pos.x+hscroll.value,pos.y+vscroll.value)


func _on_VGraph_gui_input(ev:InputEvent)->void:
	if not ev is InputEventMouse:
		return
	var ym:float=values_graph.rect_size.y*zoom
	var vpos:Vector2=get_VGraph_position(ev.position)
	var ix:int=clamp(vpos.x/bar_width,0.0,MAX_STEPS-1)
	var yv:float=clamp(vpos.y/ym,0.0,1.0)
	var max_value:float=max_value_rel if relative else max_value_abs
	var min_value:float=min_value_rel if relative else min_value_abs
	if ev.button_mask==BUTTON_LEFT:
		if mode<MODE_MASK:
			values[ix]=round(lerp(max_value,min_value,yv))
		elif mode==MODE_SELECT:
			var d:float=abs(max_value_abs-min_value_abs)+1
			values[ix]=clamp(max_value_abs-(floor(yv*d)+min_value_abs),min_value_abs,max_value_abs)
		values_graph.update()


func _on_Steps_value_changed(value:int)->void:
	steps=value
	if not is_ready:
		yield(self,"ready")
	recalc_scrollbars()
	values_graph.update()
	emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)


func recalc_scrollbars()->void:
	get_bar_sizes()
	hscroll.page=min(values_graph.rect_size.x,steps*bar_width)
	hscroll.max_value=steps*bar_width
	vscroll.page=min(values_graph.rect_size.y,values_graph.rect_size.y*zoom)
	vscroll.max_value=values_graph.rect_size.y*zoom


func _on_VGraph_draw():
	if not is_ready:
		yield(self,"ready")
	values_graph.draw_set_transform(Vector2(-hscroll.value,-vscroll.value),0.0,Vector2.ONE)
	#
	if mode<MODE_MASK:
		if relative:
			draw_relative()
		else:
			draw_absolute()
	elif mode==MODE_SELECT:
		draw_select()


func draw_select()->void:
	var color:Color=real_theme.get_color("values_color","BarEditor")
	var ym:float=values_graph.rect_size.y*zoom
	var x0:float=0.0
	var yv:float
	var ys:float=ym/((max_value_abs-min_value_abs)+1)
	for i in steps:
		if values[i]!=ParamMacro.PASSTHROUGH:
			yv=ym-(values[i]*ys)
			values_graph.draw_rect(Rect2(x0,yv,bar_width-1.0,-ys),color)
		else:
			values_graph.draw_rect(Rect2(x0,0.0,bar_width-1.0,ym),color,false)
		x0+=bar_width


func draw_absolute()->void:
	var color:Color=real_theme.get_color("values_color","BarEditor")
	var ym:float=values_graph.rect_size.y*zoom
	var x0:float=0.0
	var yv:float
	for i in steps:
		if values[i]!=ParamMacro.PASSTHROUGH:
			yv=range_lerp(values[i],min_value_abs,max_value_abs,0.0,ym)
			values_graph.draw_rect(Rect2(x0,ym,bar_width-1.0,yv),color)
		else:
			values_graph.draw_rect(Rect2(x0,0.0,bar_width-1.0,ym),color,false)
		x0+=bar_width


func draw_relative()->void:
	var color:Color=real_theme.get_color("values_color","BarEditor")
	var ym:float=values_graph.rect_size.y*zoom
	var bh2:float=bar_height*0.5
	var yv:float=range_lerp(center_value,min_value_rel,max_value_rel,0.0,ym)
	values_graph.draw_line(
		Vector2(0.0,yv),Vector2(bar_width*steps,yv),
		real_theme.get_color("center_color","BarEditor")
	)
	var x0:float=0.0
	for i in steps:
		if values[i]!=ParamMacro.PASSTHROUGH:
			yv=range_lerp(values[i],max_value_rel,min_value_rel,0.0,ym)
			values_graph.draw_rect(Rect2(x0,yv-bh2,bar_width-1.0,bar_height),color)
		else:
			values_graph.draw_rect(Rect2(x0,0.0,bar_width-1.0,ym),color,false)
		x0+=bar_width


func _on_Scroll_value_changed(_v:float)->void:
	values_graph.update()
	loop_graph.update()


func set_title(t:String)->void:
	title=t
	if not is_ready:
		yield(self,"ready")
	get_node("%Title").text=t


func can_switch_modes()->bool:
	return mode>=MODE_SWABS and mode<MODE_MASK


func _on_Title_pressed(delta:int)->void:
	if heights.empty():
		return
	height_sel=(height_sel+delta)%(heights.size()+1)
	if height_sel==0:
		relative_button.visible=false
		for h in hiddables:
			h.visible=false
		rect_min_size.y=0.0
		rect_size.y=0.0
	else:
		relative_button.visible=can_switch_modes()
		for h in hiddables:
			h.visible=true
		rect_min_size.y=heights[height_sel-1]
		rect_size.y=heights[height_sel-1]


func _on_Relative_toggled(p:bool)->void:
	relative=p
	select_values()
	values_graph.update()
	# TODO: labels_point.update()
	emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)


func _on_Div_value_changed(v:float)->void:
	tick_div=v
	emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)


func _on_Delay_value_changed(v:float)->void:
	delay=v
	emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)

