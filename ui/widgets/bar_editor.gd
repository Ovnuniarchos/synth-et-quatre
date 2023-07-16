tool extends HBoxContainer
class_name BarEditor

signal macro_changed(parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)

enum{MODE_ABS,MODE_REL,MODE_SWABS,MODE_SWREL,MODE_MASK}

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
var bset:int=0
var bclr:int=0
var bmode:int=0

var title_button:Button
var step_bar:SpinBar
var div_bar:SpinBar
var delay_bar:SpinBar
var values_graph:Control
var loop_graph:Control
var val_tooltip:Tooltip
var rel_button:Button
var real_theme:Theme
var editor:ScrollContainer
var hiddables:Array
var heights:PoolRealArray=PoolRealArray([160.0,240.0,320.0])

export (String) var title:String="Macro" setget set_title
export (String) var parameter:String=""
export (float) var title_width:float=128.0 setget set_title_width
export (int) var min_value_rel:int=-12.0
export (int) var max_value_rel:int=12.0
export (int) var center_value:int=0.0
export (int) var min_value_abs:int=0.0
export (int) var max_value_abs:int=48.0
export (int) var step:int=1.0
export (int) var big_step:int=4.0
export (int) var huge_step:int=16.0
export (int,"Absolute","Relative","SwitchAbs","SwitchRel","Mask") var mode:int=0


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
	div_bar=$Params/HBC/Div
	delay_bar=$Params/HBC/Delay
	values_graph=$Editor/Origin/HBC/Values
	loop_graph=$Editor/Origin/HBC/LoopRange
	val_tooltip=$Editor/Origin/Value
	editor=$Editor
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
	values_graph.update()
	loop_graph.update()

func can_switch_modes()->bool:
	return mode>=MODE_SWABS and mode<MODE_MASK

func set_title(t:String)->void:
	title=t
	if title_button!=null:
		title_button.text=t

func set_title_width(w:float)->void:
	title_width=w
	if title_button!=null:
		title_button.rect_min_size.x=w

func init_values()->void:
	if mode<MODE_MASK:
		values.fill(center_value)
	else:
		values.fill(0)

func set_values(v:Array)->void:
	var sz:int=min(MAX_STEPS,v.size())
	for i in sz:
		values[i]=v[i]

func process_mask_input(ev:InputEventMouse)->void:
	if ev.button_mask==BUTTON_MASK_LEFT:
		var ym:float=values_graph.rect_size.y
		var ix:int=clamp(ev.position.x/16.0,0.0,MAX_STEPS-1)
		var yv:int=max_value_abs-clamp(floor((ev.position.y/ym)*(max_value_abs+1)),0.0,max_value_abs)
		if bmode==0:
			bset=1<<yv
			values[ix]^=bset
			bmode=1 if bset&values[ix] else -1
		bclr=~(1<<yv)
		bset=1<<yv if bmode==1 else 0
		values[ix]=(values[ix]&bclr)|bset
		values_graph.update()
		emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)
	elif ev.button_mask==0:
		bmode=0

func _on_Values_gui_input(ev:InputEvent)->void:
	if not ev is InputEventMouse:
		return
	if mode==MODE_MASK:
		process_mask_input(ev as InputEventMouse)
		return
	var st:float=step*(big_step if ev.shift else 1)*(huge_step if ev.control else 1)
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
		accept_event()
		redraw=true
	elif ev.button_mask==0 and ev is InputEventMouseMotion:
		val_tooltip.fade()
		if line_start!=Vector2.INF:
			line_start=Vector2.INF
	if redraw:
		if line_start==Vector2.INF:
			values[ix]=int(yv)
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
		val_tooltip.show_at(String(yv),ev.position-Vector2(0.0,val_tooltip.rect_size.y*0.5))
		emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)

func _on_LoopRange_gui_input(ev:InputEvent)->void:
	if not ev is InputEventMouse:
		return
	var ix:int=ev.position.x/16.0
	var redraw:bool=false
	if ev.button_mask==BUTTON_MASK_LEFT:
		if ev.shift:
			ix=clamp(ix,loop_end+1,steps)
			release_loop_start=ix
		else:
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
	$Editor/Origin.rect_min_size.x=steps*16.0
	values_graph.update()
	loop_graph.update()
	emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)

func _on_Values_draw()->void:
	if values_graph==null:
		return
	values_graph.rect_min_size.x=steps*16.0
	var ym:float=values_graph.rect_size.y
	var y0:float=range_lerp(center_value,min_value_rel,max_value_rel,ym,0.0)
	var x0:float=0.0
	var yv:float
	if mode==MODE_MASK:
		var hb:float=ym/(max_value_abs+1.0)
		var j:int
		for i in steps:
			j=1<<int(max_value_abs)
			yv=0.0
			while j>0:
				if values[i]&j:
					values_graph.draw_rect(Rect2(x0,yv,15.0,hb-1.0),Color.white)
				j>>=1
				yv+=hb
			
			x0+=16.0
	elif relative:
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
	if loop_graph==null:
		return
	var x0:float
	var h:float=loop_graph.rect_size.y*0.5
	if loop_start>-1 and loop_end>-1:
		x0=loop_start*16.0
		for _i in range(loop_start,loop_end+1):
			loop_graph.draw_rect(Rect2(x0,0.0,15.0,h),Color.white)
			x0+=16.0
	if release_loop_start>-1:
		x0=release_loop_start*16.0
		for _i in range(release_loop_start,steps):
			loop_graph.draw_rect(Rect2(x0,h,15.0,h),Color.white)
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
