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

func correct_limits()->void:
	if end_chan>=start_chan:
		if start_col>end_col:
			data_col0=end_col
			data_col1=start_col
		else:
			data_col0=start_col
			data_col1=end_col
	else:
		var t:int=end_chan
		end_chan=start_chan
		start_chan=t
	if start_row>end_row:
		var t:int=end_row
		end_row=start_row
		start_row=t

func get_affected_cols()->Array:
	correct_limits()
	var chan_cols:Array=[]
	if start_chan==end_chan:
		for i in range(data_col0,data_col1+1):
			chan_cols.append([start_chan,i])
	else:
		var rng:Array
		for i in range(start_chan,end_chan+1):
			if i==start_chan:
				rng=range(data_col0,MAX_ATTR+1)
			elif i==end_chan:
				rng=range(data_col1+1)
			else:
				rng=range(0,MAX_ATTR+1)
			for j in rng:
				chan_cols.append([i,j])
			i+=1
	return chan_cols

func copy(pats:Array)->void:
	correct_limits()
	data=[]
	for pat in pats:
		data.append(pat.notes.slice(start_row,end_row,1,true))
	set_active(false)

func cut(pats:Array,order:int,channel:int)->void:
	copy(pats)
	clear(pats,order,channel)

func clear(pats:Array,order:int,channel:int)->void:
	correct_limits()
	var p_ix:int=0
	var p_end:int=pats.size()-1
	for pat in pats:
		if p_end==0:
			for i in range(start_row,end_row+1):
				for j in range(data_col0,data_col1+1):
					pat.notes[i][j]=null
		elif p_ix==0:
			for i in range(start_row,end_row+1):
				for j in range(data_col0,MAX_ATTR+1):
					pat.notes[i][j]=null
		elif p_ix==p_end:
			for i in range(start_row,end_row+1):
				for j in range(0,data_col1+1):
					pat.notes[i][j]=null
		else:
			for i in range(start_row,end_row+1):
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

func add_values(order:int,delta:int,fast:bool)->void:
	var chan_col:Array=get_affected_cols()
	var chan:int
	var col:int
	var oc:int=-1
	var pat:Array
	var delta_note:int=delta*(12 if fast else 1)
	var delta_num:int=delta*(16 if fast else 1)
	var d
	for cc in chan_col:
		chan=cc[0]
		col=cc[1]
		if chan!=oc:
			oc=chan
			pat=GLOBALS.song.get_order_pattern(order,chan).notes
		if col==ATTRS.LG_MODE:
			continue
		for i in range(start_row,end_row+1):
			d=pat[i][col]
			if d==null and col!=ATTRS.FM0 and col!=ATTRS.FM1 and col!=ATTRS.FM2\
					and col!=ATTRS.FM3:
				continue
			if col==ATTRS.NOTE and d>=0:
				d=clamp(d+delta_note,0,143)
			elif col==ATTRS.PAN:
				d=clamp((d&63)+delta_num,0,63)|(d&192)
			elif col==ATTRS.FM0 or col==ATTRS.FM1 or col==ATTRS.FM2 or col==ATTRS.FM3:
				if d==null:
					d=0
				d=(d+delta)&15
			elif col==ATTRS.INSTR or col==ATTRS.VOL or col>=ATTRS.FX0:
				d=clamp(d+delta_num,0,255)
			pat[i][col]=d
	oc=-1
	for cc in chan_col:
		if oc!=cc[0]:
			oc=cc[0]
			GLOBALS.song.emit_signal("order_changed",order,cc[0])
