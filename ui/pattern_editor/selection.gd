extends Reference
class_name Selection

signal selection_changed

const ATTRS=Pattern.ATTRS
const MAX_ATTR=Pattern.MAX_ATTR
const MIN_FX_COL=Pattern.MIN_FX_COL

var start_chan:int
var end_chan:int
var start_col:int
var end_col:int
var start_row:int
var end_row:int
var active:bool setget set_active
var data_col0:int
var data_col1:int
var data:Array

func _init()->void:
	active=false

func set_active(act:bool)->void:
	active=act
	emit_signal("selection_changed")

func set_start(chan:int,col:int,row:int)->void:
	start_chan=chan
	start_col=col
	start_row=row
	emit_signal("selection_changed")

func set_end(chan:int,col:int,row:int)->void:
	end_chan=chan
	end_col=col
	end_row=row
	emit_signal("selection_changed")

func correct_limits()->Array:
	var rows:Array=[start_row,end_row]
	if start_col>end_col:
		data_col0=end_col
		data_col1=start_col
	else:
		data_col0=start_col
		data_col1=end_col
	if start_row>end_row:
		rows[0]=end_row
		rows[1]=start_row
	return rows

func copy(pats:Array)->void:
	var rows:Array=correct_limits()
	data=[]
	for pat in pats:
		data.append(pat.notes.slice(rows[0],rows[1],1,true))
	set_active(false)

func cut(pats:Array,order:int,channel:int)->void:
	copy(pats)
	clear(pats,order,channel)

func clear(pats:Array,order:int,channel:int)->void:
	var rows:Array=correct_limits()
	var p_ix:int=0
	var p_end:int=pats.size()-1
	for pat in pats:
		if p_end==0:
			for i in range(rows[0],rows[1]+1):
				for j in range(data_col0,data_col1+1):
					pat.notes[i][j]=null
		elif p_ix==0:
			for i in range(rows[0],rows[1]+1):
				for j in range(data_col0,MAX_ATTR+1):
					pat.notes[i][j]=null
		elif p_ix==p_end:
			for i in range(rows[0],rows[1]+1):
				for j in range(0,data_col1+1):
					pat.notes[i][j]=null
		else:
			for i in range(rows[0],rows[1]+1):
				for j in range(0,MAX_ATTR+1):
					pat.notes[i][j]=null
		GLOBALS.song.emit_signal("order_changed",order,channel)
		p_ix+=1
	set_active(false)

func paste_loop(pat:Pattern,pat_len:int,chn:int,row:int,col0:int,col1:int,mix:bool,dcol:int=0)->void:
	for col in range(col0,col1+1):
		if col+dcol>MAX_ATTR:
			break
		var r0:int=0
		var r1:int=row
		while r1<pat_len and r0<data[chn].size():
			if mix and data[chn][r0][col]==null\
					and not(col in [ATTRS.LG_MODE,ATTRS.FM0,ATTRS.FM1,ATTRS.FM2,ATTRS.FM3]):
				r1+=1
				r0+=1
				continue
			pat.notes[r1][col+dcol]=data[chn][r0][col]
			r1+=1
			r0+=1

func paste(song:Song,order:int,channel:int,row:int,column:int,mix:bool)->void:
	var pat:Pattern=song.get_order_pattern(order,channel)
	if data.size()==1 and data_col0>=MIN_FX_COL:
		if column<MIN_FX_COL:
			paste_loop(pat,song.pattern_length,0,row,data_col0,data_col1,mix)
		else:
			var dcol:int=floor((column-MIN_FX_COL)/3)*3
			paste_loop(pat,song.pattern_length,0,row,data_col0,data_col1,mix,dcol)
		song.emit_signal("order_changed",order,channel)
		return
	var chn:int=0
	while channel<song.num_channels and chn<data.size():
		if chn==0:
			pat=song.get_order_pattern(order,channel)
			paste_loop(pat,song.pattern_length,chn,row,data_col0,min(data_col1,MAX_ATTR),mix)
		elif chn==data.size()-1:
			pat=song.get_order_pattern(order,channel)
			paste_loop(pat,song.pattern_length,chn,row,0,data_col1,mix)
		else:
			pat=song.get_order_pattern(order,channel)
			paste_loop(pat,song.pattern_length,chn,row,0,min(data_col1,MAX_ATTR),mix)
		song.emit_signal("order_changed",order,channel)
		channel+=1
		chn+=1
