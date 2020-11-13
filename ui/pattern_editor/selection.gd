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
var data_chan0:int
var data_chan1:int
var data_col0:int
var data_col1:int
var data_row0:int
var data_row1:int
var data:Array
var data_cols:Array

func _init()->void:
	active=false

func duplicate()->Selection:
	var ns:Selection=get_script().new()
	ns.start_chan=start_chan
	ns.end_chan=end_chan
	ns.start_col=start_col
	ns.end_col=end_col
	ns.start_row=start_row
	ns.end_row=end_row
	ns.active=active
	ns.data_chan0=data_chan0
	ns.data_chan1=data_chan1
	ns.data_col0=data_col0
	ns.data_col1=data_col1
	ns.data_row0=data_row0
	ns.data_row1=data_row1
	ns.data=data.duplicate(true)
	ns.data_cols=data_cols.duplicate()
	return ns

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
	if start_chan>end_chan:
		data_chan0=end_chan
		data_chan1=start_chan
		data_col0=end_col
		data_col1=start_col
	else:
		data_chan0=start_chan
		data_chan1=end_chan
		data_col0=start_col
		data_col1=end_col
	if data_chan0==data_chan1 and data_col0>data_col1:
		var t:int=data_col0
		data_col0=data_col1
		data_col1=t
	if start_row>end_row:
		data_row0=end_row
		data_row1=start_row
	else:
		data_row0=start_row
		data_row1=end_row

func get_affected_cols(song:Song)->void:
	correct_limits()
	data_cols=[]
	if data_chan0==data_chan1:
		for i in range(data_col0,data_col1+1):
			data_cols.append([data_chan0,i])
	else:
		var rng:Array
		for i in range(data_chan0,data_chan1+1):
			if i==data_chan0:
				rng=range(data_col0,ATTRS.FX0+(song.num_fxs[i]*3))
			elif i==data_chan1:
				rng=range(data_col1+1)
			else:
				rng=range(ATTRS.FX0+(song.num_fxs[i]*3))
			for j in rng:
				data_cols.append([i,j])
			i+=1

func copy(song:Song,order:int)->void:
	get_affected_cols(song)
	var pat:Pattern
	var chan:int=-1
	data=[]
	for col in data_cols:
		if chan!=col[0]:
			chan=col[0]
			pat=song.get_order_pattern(order,chan)
		data.append([])
		data[-1].resize((data_row1-data_row0)+1)
		for r in range(data_row0,data_row1+1):
			data[-1][r-data_row0]=pat.notes[r][col[1]]

func cut(song:Song,order:int)->void:
	copy(song,order)
	clear(song,order)
	set_active(false)

func clear(song:Song,order:int)->void:
	get_affected_cols(song)
	var pat:Pattern
	var chan:int=-1
	for col in data_cols:
		if chan!=col[0]:
			chan=col[0]
			pat=song.get_order_pattern(order,chan)
		for r in range(data_row0,data_row1+1):
			pat.notes[r][col[1]]=null
	chan=-1
	for col in data_cols:
		if chan!=col[0]:
			chan=col[0]
			GLOBALS.song.emit_signal("order_changed",order,chan)

func paste(song:Song,order:int,channel:int,row:int,column:int,mix:bool)->void:
	if data_cols.empty():
		return
	if data_cols[0][1]>=ATTRS.FX0:
		column=floor(max(0.0,column-ATTRS.FX0)/3.0)*3.0
	else:
		column=0
	var pat:Pattern
	var chan:int=-1
	var chan1:bool=true
	channel-=1
	var col:int
	for i in range(data_cols.size()):
		col=data_cols[i][1]+column
		if chan!=data_cols[i][0]:
			channel+=1
			chan=data_cols[i][0]
			pat=song.get_order_pattern(order,channel)
			if not chan1:
				column=0
			else:
				chan1=false
		if col>=ATTRS.FX0+(song.num_fxs[channel]*3):
			continue
		for r in range(data[i].size()):
			if r+row>=song.pattern_length:
				break
			if not mix or data[i][r]!=null\
					or col in [ATTRS.LG_MODE,ATTRS.FM0,ATTRS.FM1,ATTRS.FM2,ATTRS.FM3]:
				pat.notes[r+row][col]=data[i][r]
	#
	chan=-1
	for c in data_cols:
		if chan!=c[0]:
			chan=c[0]
			GLOBALS.song.emit_signal("order_changed",order,chan)

func add_values(song:Song,order:int,delta:int,fast:bool)->void:
	get_affected_cols(song)
	var delta_note:int=delta*(12 if fast else 1)
	var delta_num:int=delta*(16 if fast else 1)
	var pat:Pattern
	var chan:int=-1
	var col:int
	var d
	for dc in data_cols:
		col=dc[1]
		if chan!=dc[0]:
			chan=dc[0]
			pat=song.get_order_pattern(order,chan)
		if col==ATTRS.LG_MODE:
			continue
		for r in range(data_row0,data_row1+1):
			d=pat.notes[r][col]
			if d==null and (col<ATTRS.FX0 or (col-ATTRS.FX0)%3!=1):
				continue
			elif col==ATTRS.NOTE and d>=0:
				d=clamp(d+delta_note,0,143)
			elif col==ATTRS.PAN:
				d=clamp((d&63)+delta_num,0,63)|(d&192)
			elif col>=ATTRS.FX0 and (col-ATTRS.FX0)%3==1:
				if d==null:
					d=0
				d=(d+delta)&15
			elif col==ATTRS.INSTR or col==ATTRS.VOL or col>=ATTRS.FX0:
				d=clamp(d+delta_num,0,255)
			pat.notes[r][col]=d
	chan=-1
	for dc in data_cols:
		if chan!=dc[0]:
			chan=dc[0]
			GLOBALS.song.emit_signal("order_changed",order,chan)
