tool extends HBoxContainer
class_name BarEditor

signal macro_changed(parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)

enum{MODE_ABS,MODE_REL,MODE_SWABS,MODE_SWREL,MODE_MASK}
enum{BIT_CLEAR,BIT_SWITCH,BIT_SET}

const MAX_STEPS:int=256

var loop_start:int=-1
var loop_end:int=-1
var release_loop_start:int=-1
var values:Array
var relative:bool=true
var steps:int=0
var tick_div:int=1
var delay:int=0

var height_sel:int=0
var line_start:Vector2=Vector2.INF
var line_end:Vector2
var line_buffer:Array
var bmode:int=BIT_SWITCH

var title_button:Button
var step_bar:SpinBar
var div_bar:SpinBar
var delay_bar:SpinBar
var values_graph:Control
var loop_graph:Control
var val_tooltip:Tooltip
var rel_button:Button
var real_theme:Theme
var editor:Control
var scroll:ScrollBar
var labels_point:Control

var bar_width:float
var bar_height:float
var hiddables:Array
var heights:PoolRealArray=PoolRealArray([160.0,240.0,320.0])

export (String) var title:String="Macro" setget set_title
export (String) var parameter:String=""
export (float) var title_width:float=128.0 setget set_title_width
export (int) var min_value_rel:int=-12.0
export (int) var max_value_rel:int=12.0
export (int) var center_value:int=0.0
export (int) var min_value_abs:int=0.0 setget set_min_value_abs
export (int) var max_value_abs:int=48.0 setget set_max_value_abs
export (int) var step:int=1.0
export (int) var big_step:int=4.0
export (int) var huge_step:int=16.0
export (int,"Absolute","Relative","SwitchAbs","SwitchRel","Mask") var mode:int=MODE_SWREL setget set_mode
export (PoolStringArray) var labels:PoolStringArray=PoolStringArray()


func _init()->void:
	values.resize(MAX_STEPS)
	init_values()

func _ready()->void:
	if Engine.editor_hint:
		real_theme=Theme.new()
	else:
		real_theme=THEME.theme
	theme=real_theme
	title_button=$Params/Title
	step_bar=$Params/HBC/Steps
	div_bar=$Params/HBC/Div
	delay_bar=$Params/HBC/Delay
	values_graph=$Editor/Values/Graph
	loop_graph=$Editor/LoopRange/Graph
	labels_point=$Editor/Values/Labels
	$Editor/Values.add_stylebox_override("panel",real_theme.get_stylebox("values","BarEditor"))
	$Editor/LoopRange.add_stylebox_override("panel",real_theme.get_stylebox("loop","BarEditor"))
	$Editor/LoopRange.rect_min_size.y=real_theme.get_constant("loop_height","BarEditor")
	val_tooltip=$Editor/Values/Graph/Value
	bar_width=real_theme.get_constant("bar_size_x","BarEditor")
	bar_height=real_theme.get_constant("bar_size_y","BarEditor")
	editor=$Editor
	editor.add_constant_override("separation",real_theme.get_constant("separation","BarEditor"))
	scroll=$Editor/HScrollBar
	rel_button=$Params/Relative
	hiddables=[$Params/R,$Params/HBC]
	relative=mode==MODE_REL or mode==MODE_SWREL
	if can_switch_modes():
		rel_button.set_pressed_no_signal(mode==MODE_SWREL)
		rel_button.visible=true
	else:
		rel_button.visible=false
	set_title(title)
	set_title_width(title_width)
	_on_Title_pressed(0)

func can_switch_modes()->bool:
	return mode>=MODE_SWABS and mode<MODE_MASK

func set_title(t:String)->void:
	title=t
	if title_button==null:
		yield(self,"ready")
	title_button.text=t

func set_title_width(w:float)->void:
	title_width=w
	if title_button==null:
		yield(self,"ready")
	title_button.rect_min_size.x=w

func set_min_value_abs(v:int)->void:
	if mode==MODE_MASK:
		v=clamp(v,0.0,31.0)
	min_value_abs=v

func set_max_value_abs(v:int)->void:
	if mode==MODE_MASK:
		v=clamp(v,0.0,31.0)
	max_value_abs=v

func set_mode(m:int)->void:
	mode=m
	if mode==MODE_MASK:
		min_value_abs=clamp(min_value_abs,0.0,31.0)
		max_value_abs=clamp(max_value_abs,0.0,31.0)
		property_list_changed_notify()

func init_values()->void:
	if mode<MODE_MASK:
		values.fill(center_value)
	else:
		values.fill(0)

func set_values(v:Array)->void:
	var sz:int=min(MAX_STEPS,v.size())
	for i in sz:
		values[i]=v[i]
	if values_graph==null:
		yield(self,"ready")
	values_graph.update()

func bit(ix:int,bit_n:int,bit_op:int)->bool:
	var mask:int=1<<bit_n
	if bit_op==BIT_SWITCH:
		values[ix]^=mask
		return bool(values[ix]&mask)
	elif bit_op==BIT_SET:
		values[ix]|=mask
		return true
	values[ix]&=~mask
	return false

func process_mask_input(ev:InputEventMouse)->void:
	if ev.button_mask==BUTTON_MASK_LEFT:
		var ym:float=values_graph.rect_size.y
		var ix:int=clamp(ev.position.x/bar_width,0.0,MAX_STEPS-1)
		var yv:int=max_value_abs-clamp(floor((ev.position.y/ym)*(max_value_abs+1)),0.0,max_value_abs)
		var enop:int=BIT_SET
		if ev.shift:
			bit(ix,yv,BIT_CLEAR)
			enop=BIT_CLEAR
		elif bmode==BIT_SWITCH:
			bmode=BIT_SET if bit(ix,yv,bmode) else BIT_CLEAR
		else:
			bit(ix,yv,bmode)
		bit(ix,yv+ParamMacro.MASK_PASSTHROUGH_SHIFT,enop)
		values_graph.update()
		emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)
	elif ev.button_mask==0:
		bmode=BIT_SWITCH

func _on_ValuesGraph_gui_input(ev:InputEvent)->void:
	if not ev is InputEventMouse:
		return
	if mode==MODE_MASK:
		process_mask_input(ev as InputEventMouse)
		return
	var st:float=step*(big_step if ev.shift else 1)*(huge_step if ev.control else 1)
	var ym:float=values_graph.rect_size.y
	var ix:int=clamp((ev.position.x+scroll.value)/bar_width,0.0,MAX_STEPS-1)
	var miv:float=min_value_rel if relative else min_value_abs
	var mxv:float=max_value_rel if relative else max_value_abs
	var yv:int=int(clamp(stepify(range_lerp(ev.position.y,0.0,ym,mxv,miv),st),miv,mxv))
	var redraw:bool=false
	if ev.button_mask==BUTTON_MASK_LEFT:
		if ev.shift and mode!=MODE_MASK:
			yv=ParamMacro.PASSTHROUGH
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
		accept_event()
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
					values[i]=int(range_lerp(i,ls.x,le.x,ls.y,le.y))
			else:
				values[ls.x]=int(le.y)
		values_graph.update()
		val_tooltip.show_at(String(yv) if yv!=ParamMacro.PASSTHROUGH else "Passthrough",ev.position-Vector2(0.0,val_tooltip.rect_size.y*0.5))
		emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)

func _on_LoopRangeGraph_gui_input(ev:InputEvent)->void:
	if not ev is InputEventMouse:
		return
	var ix:int=(ev.position.x+scroll.value)/bar_width
	var redraw:bool=false
	if ev.button_mask==BUTTON_MASK_LEFT:
		if ev.shift:
			ix=max(ix,loop_end+1)
			release_loop_start=ix if ix<steps else -1
		else:
			ix=clamp(ix,0,steps-1)
			if loop_start<0:
				loop_start=ix
				loop_end=loop_start
			elif abs(ix-loop_end)<=abs(ix-loop_start):
				loop_end=ix
				loop_start=min(loop_start,loop_end)
			else:
				loop_start=ix
				loop_end=max(loop_start,loop_end)
			if release_loop_start>-1:
				release_loop_start=-1 if loop_end>=steps-1 else int(clamp(release_loop_start,loop_end+1,steps))
		redraw=true
	elif ev.button_mask==BUTTON_MASK_RIGHT:
		if ev.shift:
			release_loop_start=-1
		else:
			loop_start=-1
			loop_end=-1
		redraw=true
	if redraw:
		loop_graph.update()
		emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)

func _on_Steps_value_changed(s:int)->void:
	steps=s
	if s>0:
		loop_start=min(s-1,loop_start)
		loop_end=min(s-1,loop_end)
		release_loop_start=min(s-1,release_loop_start)
	else:
		loop_start=-1
		loop_end=-1
		release_loop_start=-1
	values_graph.update()
	loop_graph.update()
	_on_item_rect_changed()
	emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)

func _on_Labels_draw()->void:
	if height_sel==0:
		return
	if labels_point==null:
		yield(self,"ready")
	var texts:Array
	var font:Font=real_theme.get_font("font","BarEditorLabel")
	var color:Color=real_theme.get_color("font_color","BarEditorLabel")
	var ol_color:Color=real_theme.get_color("font_outline_modulate","BarEditorLabel")
	var s_color:Color=real_theme.get_color("font_color_shadow","BarEditorLabel")
	var s_ofs:Vector2=Vector2(real_theme.get_constant("shadow_offset_x","BarEditorLabel"),
		real_theme.get_constant("shadow_offset_y","BarEditorLabel")
	)
	var s_outline:bool=real_theme.get_constant("shadow_as_outline","BarEditorLabel")
	var p0:Vector2
	var p1:Vector2
	var dp:Vector2
	var dp2:Vector2
	if mode!=MODE_MASK and (relative or labels.empty()):
		p0=Vector2(labels_point.rect_position)+Vector2(0.0,font.get_ascent())
		p1=Vector2(labels_point.rect_position)+Vector2(0.0,values_graph.rect_size.y-font.get_descent())
		if relative:
			texts=[String(max_value_rel),String(center_value),String(min_value_rel)]
			dp=(p1-p0)*0.5
		else:
			texts=[String(max_value_abs),String(min_value_abs)]
			dp=p1-p0
		dp2=Vector2.ZERO
	elif not labels.empty():
		texts=labels
		p0=Vector2(labels_point.rect_position)
		p1=Vector2(labels_point.rect_position)+Vector2(0.0,values_graph.rect_size.y)
		dp=(p1-p0)/texts.size()
		dp2=Vector2(0.0,dp.y+font.get_ascent())*0.5
	for t in texts:
		if s_color!=Color.transparent:
			font.draw(labels_point.get_canvas_item(),p0+dp2+s_ofs,t,s_color,-1,Color.transparent)
			if s_outline:
				font.draw(labels_point.get_canvas_item(),p0+dp2+Vector2(-s_ofs.x,s_ofs.y),t,s_color,-1,Color.transparent)
				font.draw(labels_point.get_canvas_item(),p0+dp2+Vector2(s_ofs.x,-s_ofs.y),t,s_color,-1,Color.transparent)
				font.draw(labels_point.get_canvas_item(),p0+dp2+Vector2(-s_ofs.x,-s_ofs.y),t,s_color,-1,Color.transparent)
		font.draw(labels_point.get_canvas_item(),p0+dp2,t,color,-1,ol_color)
		p0+=dp

func _on_ValuesGraph_draw()->void:
	if values_graph==null:
		yield(self,"ready")
	values_graph.draw_set_transform(Vector2(-scroll.value,0.0),0.0,Vector2.ONE)
	var ym:float=values_graph.rect_size.y
	var y0:float=range_lerp(center_value,min_value_rel,max_value_rel,ym,0.0)
	var x0:float=0.0
	var yv:float
	var color:Color
	if mode==MODE_MASK:
		var hb:float=ym/(max_value_abs+1.0)
		var j:int
		color=real_theme.get_color("mask_color","BarEditor")
		for i in steps:
			j=1<<max_value_abs
			yv=0.0
			while j>0:
				if values[i]&(j<<ParamMacro.MASK_PASSTHROUGH_SHIFT):
					values_graph.draw_rect(Rect2(x0,yv,bar_width-1.0,hb-1.0),color,bool(values[i]&j))
				j>>=1
				yv+=hb
			x0+=bar_width
	elif relative:
		color=real_theme.get_color("relative_color","BarEditor")
		values_graph.draw_line(Vector2(0.0,y0),Vector2(steps*bar_width,y0),
			real_theme.get_color("center_color","BarEditor")
		)
		var dy:float=bar_height*0.5
		for i in steps:
			if values[i]!=ParamMacro.PASSTHROUGH:
				yv=range_lerp(values[i],min_value_rel,max_value_rel,ym,0.0)
				values_graph.draw_rect(Rect2(x0,yv-dy,bar_width-1.0,bar_height),color)
			else:
				values_graph.draw_rect(Rect2(x0,0,bar_width-1.0,ym-1),color,false)
			x0+=bar_width
	else:
		color=real_theme.get_color("values_color","BarEditor")
		for i in steps:
			if values[i]!=ParamMacro.PASSTHROUGH:
				yv=-range_lerp(values[i],min_value_abs,max_value_abs,0.0,ym)
				values_graph.draw_rect(Rect2(x0,ym,bar_width-1.0,yv),color)
			else:
				values_graph.draw_rect(Rect2(x0,0,bar_width-1.0,ym-1),color,false)
			x0+=bar_width

func _on_LoopRangeGraph_draw()->void:
	if loop_graph==null:
		yield(self,"ready")
	loop_graph.draw_set_transform(Vector2(-scroll.value,0.0),0.0,Vector2.ONE)
	var loop_color:Color=real_theme.get_color("loop_color","BarEditor")
	var release_color:Color=real_theme.get_color("release_color","BarEditor")
	var x0:float
	var h:float=loop_graph.rect_size.y*0.5
	if loop_start>-1 and loop_end>-1:
		x0=loop_start*bar_width
		for _i in range(loop_start,loop_end+1):
			loop_graph.draw_rect(Rect2(x0,0.0,bar_width-1.0,h),loop_color)
			x0+=bar_width
	if release_loop_start>-1:
		x0=release_loop_start*bar_width
		for _i in range(release_loop_start,steps):
			loop_graph.draw_rect(Rect2(x0,h,bar_width-1.0,h),release_color)
			x0+=bar_width

func _on_ValuesGraph_mouse_exited()->void:
	val_tooltip.fade()

func _on_Relative_toggled(p:bool)->void:
	relative=p
	var v00:float=min_value_abs if relative else min_value_rel
	var v01:float=max_value_abs if relative else max_value_rel
	var v10:float=min_value_rel if relative else min_value_abs
	var v11:float=max_value_rel if relative else max_value_abs
	for i in MAX_STEPS:
		if values[i]!=ParamMacro.PASSTHROUGH:
			values[i]=stepify(range_lerp(values[i],v00,v01,v10,v11),step)
	if values_graph==null:
		yield(self,"ready")
	values_graph.update()
	labels_point.update()
	emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)

func _on_Title_pressed(delta:int)->void:
	if heights.empty():
		return
	height_sel=(height_sel+delta)%(heights.size()+1)
	if height_sel==0:
		rel_button.visible=false
		for h in hiddables:
			h.visible=false
		rect_min_size.y=0.0
		rect_size.y=0.0
	else:
		rel_button.visible=can_switch_modes()
		for h in hiddables:
			h.visible=true
		rect_min_size.y=heights[height_sel-1]
		rect_size.y=heights[height_sel-1]

func _on_Div_value_changed(v:float)->void:
	tick_div=v
	emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)

func _on_Delay_value_changed(v:float)->void:
	delay=v
	emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)

func set_macro(m:ParamMacro)->void:
	set_block_signals(true)
	loop_start=m.loop_start
	loop_end=m.loop_end
	release_loop_start=m.release_loop_start
	relative=m.relative
	init_values()
	set_values(m.values)
	steps=m.steps
	tick_div=m.tick_div
	delay=m.delay
	values_graph.update()
	loop_graph.update()
	rel_button.set_pressed_no_signal(relative)
	step_bar.value=steps
	div_bar.value=tick_div
	delay_bar.value=delay
	set_block_signals(false)

func _on_item_rect_changed()->void:
	if scroll==null:
		yield(self,"ready")
	scroll.max_value=steps*bar_width
	scroll.page=editor.rect_size.x
	scroll.visible=scroll.max_value>scroll.page
	_on_scrolling()

func _on_scrolling()->void:
	if values_graph==null:
		yield(self,"ready")
	values_graph.update()
	loop_graph.update()
