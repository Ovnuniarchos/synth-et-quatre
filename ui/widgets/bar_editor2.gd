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

var zoom:float=1.0

var value_labels:Control
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
var bmode:int=BIT_SWITCH


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
	_on_Title_pressed(0)



func init_node_caches()->void:
	value_labels=get_node("%Labels")
	values_graph=get_node("%VGraph")
	loop_graph=get_node("%LGraph")
	hscroll=get_node("%HScroll")
	vscroll=get_node("%VScroll")
	hiddables=[$Params/R,$Params/GC]
	relative_button=get_node("%Relative")


func init_values()->void:
	values_abs.fill(ParamMacro.PASSTHROUGH if mode!=MODE_MASK else 0)
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
		var ym:float=values_graph.rect_size.y*zoom
		var vpos:Vector2=get_VGraph_position(ev.position)
		var ix:int=clamp(vpos.x/bar_width,0.0,MAX_STEPS-1)
		var yv:int=get_select_value(vpos.y/ym,0,max_value_abs)
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
	elif ev.button_mask==8 and ev.alt:
		zoom=min(zoom+1.0,16.0)
		recalc_scrollbars()
		values_graph.update()
		value_labels.update()
	elif ev.button_mask==16 and ev.alt:
		zoom=max(zoom-1.0,1.0)
		recalc_scrollbars()
		values_graph.update()
		value_labels.update()



func _on_VGraph_gui_input(ev:InputEvent)->void:
	if not ev is InputEventMouse:
		return
	if mode==MODE_MASK:
		process_mask_input(ev as InputEventMouse)
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
			values[ix]=get_select_value(yv,min_value_abs,max_value_abs)
		values_graph.update()
	elif ev.button_mask==8 and ev.alt:
		zoom=min(zoom+1.0,256.0)
		recalc_scrollbars()
		values_graph.update()
		value_labels.update()
	elif ev.button_mask==16 and ev.alt:
		zoom=max(zoom-1.0,1.0)
		recalc_scrollbars()
		values_graph.update()
		value_labels.update()


func get_select_value(yv:float,min_v:int,max_v:int)->int:
	var d:float=abs(max_v-min_v)+1
	return int(clamp(max_v-(floor(yv*d)+min_v),min_v,max_v))



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
	else:
		draw_mask()


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
			values_graph.draw_rect(Rect2(x0,ym,bar_width-1.0,-yv),color)
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


func draw_mask()->void:
	var ym:float=values_graph.rect_size.y*zoom
	var hb:float=ym/(max_value_abs+1.0)
	var color:Color=real_theme.get_color("mask_color","BarEditor")
	var j:int
	var yv:float
	var x0:float=0.0
	for i in steps:
		j=1<<max_value_abs
		yv=0.0
		while j>0:
			if values[i]&(j<<ParamMacro.MASK_PASSTHROUGH_SHIFT):
				values_graph.draw_rect(Rect2(x0,yv,bar_width-1.0,hb-1.0),color,bool(values[i]&j))
			j>>=1
			yv+=hb
		x0+=bar_width


func _on_Scroll_value_changed(_v:float)->void:
	values_graph.update()
	value_labels.update()
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
	value_labels.update()
	emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)


func _on_Div_value_changed(v:float)->void:
	tick_div=v
	emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)


func _on_Delay_value_changed(v:float)->void:
	delay=v
	emit_signal("macro_changed",parameter,values,steps,loop_start,loop_end,release_loop_start,relative,tick_div,delay)


func _on_Labels_draw()->void:
	if height_sel==0:
		return
	if not is_ready:
		yield(self,"ready")
	var texts:Array
	var font:Font=real_theme.get_font("font","BarEditorLabel")
	var color:Color=real_theme.get_color("font_color","BarEditorLabel")
	var ol_color:Color=real_theme.get_color("font_outline_modulate","BarEditorLabel")
	var s_color:Color=real_theme.get_color("font_color_shadow","BarEditorLabel")
	var s_ofs:Vector2=Vector2(
		real_theme.get_constant("shadow_offset_x","BarEditorLabel"),
		real_theme.get_constant("shadow_offset_y","BarEditorLabel")
	)
	var s_outline:bool=real_theme.get_constant("shadow_as_outline","BarEditorLabel")
	var my:Vector2=values_graph.rect_size*zoom
	var p0:Vector2
	var p1:Vector2
	var dp:Vector2
	if zoom>1.0:
		var txt:String="x%d "%zoom
		p0=Vector2(values_graph.rect_size.x-font.get_string_size(txt).x,font.get_ascent())
		draw_label(
			txt,p0,value_labels.get_canvas_item(),font,
			color,s_color,s_ofs,ol_color,s_outline
		)
	value_labels.draw_set_transform(Vector2(0.0,-vscroll.value),0.0,Vector2.ONE)
	if mode!=MODE_MASK and (relative or labels.empty()):
		p0=Vector2(0.0,font.get_ascent())
		p1=Vector2(0.0,my.y-font.get_descent())
		if relative:
			texts=[String(max_value_rel),String(center_value),String(min_value_rel)]
			dp=(p1-p0)*0.5
		else:
			texts=[String(max_value_abs),String(min_value_abs)]
			dp=p1-p0
	elif not labels.empty():
		texts=labels
		p0=Vector2.ZERO
		p1=Vector2(0.0,my.y)
		dp=(p1-p0)/texts.size()
		p0+=Vector2(0.0,dp.y+font.get_ascent())*0.5
	for t in texts:
		draw_label(
			t,p0,value_labels.get_canvas_item(),font,
			color,s_color,s_ofs,ol_color,s_outline
		)
		p0+=dp


func draw_label(
	text:String,pos:Vector2,canvas:RID,font:Font,
	color:Color,shadow_color:Color,shadow_offset:Vector2,outline_color:Color,outline:bool
)->void:
	if shadow_color!=Color.transparent:
		font.draw(canvas,pos+shadow_offset,text,shadow_color,-1,Color.transparent)
		if outline:
			font.draw(canvas,pos+Vector2(-shadow_offset.x,shadow_offset.y),text,shadow_color,-1,Color.transparent)
			font.draw(canvas,pos+Vector2(shadow_offset.x,-shadow_offset.y),text,shadow_color,-1,Color.transparent)
			font.draw(canvas,pos+Vector2(-shadow_offset.x,-shadow_offset.y),text,shadow_color,-1,Color.transparent)
	font.draw(canvas,pos,text,color,-1,outline_color)


func _on_LGraph_gui_input(ev:InputEvent)->void:
	if not ev is InputEventMouse:
		return
	get_bar_sizes()
	var ix:int=(ev.position.x+hscroll.value)/bar_width
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


func _on_LGraph_draw()->void:
	if not is_ready:
		yield(self,"ready")
	loop_graph.draw_set_transform(Vector2(-hscroll.value,0.0),0.0,Vector2.ONE)
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
