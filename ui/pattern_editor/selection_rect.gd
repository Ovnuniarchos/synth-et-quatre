extends Node2D

export (Vector2) var cell_size:Vector2=Vector2(8.0,16.0) setget set_cell_size
export (Color) var color:Color=Color(1.0,1.0,1.0,0.5)
export (int) var line_width:int=0

var selection:Selection setget set_selection

var col_width:Array
var cols:Array
var channel_col0:Array
var ch0:int
var ch1:int
var co0:int
var co1:int
var ro0:int
var ro1:int

func set_arrays(cw:Array,cs:Array,c0:Array)->void:
	col_width=cw
	cols=cs
	channel_col0=c0

func set_cell_size(cs:Vector2)->void:
	cell_size=cs.abs()
	update()

func set_selection(s:Selection)->void:
	if s!=selection:
		selection=s
		selection.connect("selection_changed",self,"_on_selection_changed")

func _on_selection_changed()->void:
	visible=selection.active
	ro0=selection.start_row
	ro1=selection.end_row
	var t:int
	if selection.start_chan>selection.end_chan:
		ch0=selection.end_chan
		ch1=selection.start_chan
		co0=selection.end_col
		co1=selection.start_col
	else:
		ch0=selection.start_chan
		ch1=selection.end_chan
		co0=selection.start_col
		co1=selection.end_col
	if co0>co1 and ch0==ch1:
		t=co0
		co0=co1
		co1=t
	if selection.start_row>selection.end_row:
		ro0=selection.end_row
		ro1=selection.start_row
	else:
		ro0=selection.start_row
		ro1=selection.end_row
	update()

func column_to_tile(channel:int,column:int,row:int,end:bool)->Vector2:
	if end:
		return Vector2(channel_col0[channel]+cols[column]+col_width[column],row)
	return Vector2(channel_col0[channel]+cols[column],row)

func _draw()->void:
	if selection==null or !selection.active:
		return
	var r:Rect2=Rect2(column_to_tile(ch0,co0,ro0,false)*cell_size,Vector2())
	r.end=column_to_tile(ch1,co1,ro1+1,true)*cell_size
	if line_width==0:
		draw_rect(r,color,true)
	else:
		draw_rect(r,color,false,line_width)
