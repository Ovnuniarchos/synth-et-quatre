extends PanelContainer

signal horizontal_scroll(offset)

const ATTRS=Pattern.ATTRS

const LEGATO:int=19
const STACCATO:int=21
const DOT:int=20
const SHARP:int=17
const MINUS:int=18
const OP_MASK:int=21
const SEMI2TILE:Array=[12,12,13,13,14,15,15,16,16,10,10,11]
const SHARP2TILE:Array=[DOT,SHARP,DOT,SHARP,DOT,DOT,SHARP,DOT,SHARP,DOT,SHARP,DOT]
const COL_WIDTH:Array=[1,4,2,2,2,2,1,2,2,1,2,2,1,2,2,1,2]
const COLS:Array=[0,1,6,9,12,15,17,18,21,23,24,27,29,30,33,35,36]

var curr_order:int=0
var curr_row:int=0
var curr_channel:int=0
var curr_column:int=0
var step:int=1

onready var editor:TileMap=$Pattern
onready var lines:TileMap=$Lines
onready var sel_rect:Node2D=$Selection
var ofs_chan:int=0
var container:Control
var container_size:Vector2
var channel_col0:Array
var focused:bool=false
var digit_ix:int=0
var dflt_velocity:int=128
var selection:Selection=Selection.new()
var dragging:bool=false
var drag_start:Vector2
var kbd_drag:bool=false


func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	AUDIO.tracker.connect("position_changed",self,"_on_playing_pos_changed")
	_on_song_changed()
	_on_resized()
	selection.active=false
	sel_rect.selection=selection

func _on_song_changed()->void:
	GLOBALS.song.connect("channels_changed",self,"_on_channels_changed")
	GLOBALS.song.connect("order_changed",self,"_on_order_changed")
	curr_order=0
	set_row(0)
	set_channel(0)
	set_column(0)
	selection.active=false
	_on_channels_changed()

func _input(event:InputEvent)->void:
	if !is_visible_in_tree() or ALERT.active:
		return
	if process_mouse_motion(event as InputEventMouseMotion):
		accept_event()
		return
	if process_keyboard(event as InputEventKey):
		accept_event()
		return
	if process_mouse_button(event as InputEventMouseButton):
		accept_event()
		return

func process_mouse_motion(ev:InputEventMouseMotion)->bool:
	if ev==null:
		return false
	if dragging and (ev.global_position-drag_start).abs()>Vector2(8.0,16.0):
		selection.active=true
		var pos:Vector2=editor.world_to_map(ev.global_position-editor.global_position)
		if pos.x<0.0 or pos.y<0.0 or pos.y>=GLOBALS.song.pattern_length:
			return false
		var chan:int=-1
		for i in range(channel_col0.size()):
			if channel_col0[i]>pos.x:
				chan=i-1
				break
		if chan<0:
			return false
		var col:int=ATTRS.PAN+(GLOBALS.song.num_fxs[chan]*3)
		for i in range(col+1):
			if (COLS[i]+channel_col0[chan])>pos.x:
				col=i-1
				break
		if col<0:
			return false
		set_channel(chan)
		set_column(col)
		set_row(pos.y)
		selection.set_end(curr_channel,curr_column,curr_row)
		sel_rect.update()
		return true
	return false

func process_mouse_button(ev:InputEventMouseButton)->bool:
	if ev==null:
		return false
	if !Rect2(rect_global_position,rect_size).has_point(ev.global_position):
		_on_focus_exited()
		release_focus()
		return false
	_on_focus_entered()
	grab_focus()
	if ev.button_index==BUTTON_LEFT:
		var pos:Vector2
		dragging=ev.pressed
		drag_start=ev.global_position
		pos=editor.world_to_map(ev.global_position-editor.global_position)
		if !ev.pressed:
			if pos.x<0.0 or pos.y<0.0 or pos.y>=GLOBALS.song.pattern_length:
				return false
			var chan:int=-1
			for i in range(channel_col0.size()):
				if channel_col0[i]>pos.x:
					chan=i-1
					break
			if chan<0:
				return false
			var col:int=ATTRS.PAN+(GLOBALS.song.num_fxs[chan]*3)
			for i in range(col+1):
				if (COLS[i]+channel_col0[chan])>pos.x:
					col=i-1
					break
			if col<0:
				return false
			set_channel(chan)
			set_column(col)
			set_row(pos.y)
		else:
			selection.set_start(curr_channel,curr_column,curr_row)
			selection.set_end(curr_channel,curr_column,curr_row)
			selection.active=false
		return true
	if ev.button_index==BUTTON_WHEEL_DOWN:
		if !ev.pressed:
			advance(4*step if ev.shift else 1)
		return true
	if ev.button_index==BUTTON_WHEEL_UP:
		if !ev.pressed:
			advance(-4*step if ev.shift else -1)
		return true
	return false

func collect_patterns()->Array:
	var pats:Array=[]
	var song:Song=GLOBALS.song
	if selection.start_chan>selection.end_chan:
		for i in range(selection.end_chan,selection.start_chan+1):
			pats.append(song.get_order_pattern(curr_order,i))
	else:
		for i in range(selection.start_chan,selection.end_chan+1):
			pats.append(song.get_order_pattern(curr_order,i))
	return pats

func process_keyboard(ev:InputEventKey)->bool:
	if ev==null or !focused:
		return false
	var fscan:int=ev.get_scancode_with_modifiers()
	#
	var moved:bool=false
	var old_channel:int=curr_channel
	var old_column:int=curr_column
	var old_row:int=curr_row
	if ev.scancode==GKBD.DOWN:
		if ev.pressed:
			advance(1)
		moved=true
	if ev.scancode==GKBD.UP:
		if ev.pressed:
			advance(-1)
		moved=true
	if ev.scancode==GKBD.FAST_UP:
		if ev.pressed:
			advance(-4*step)
		moved=true
	if ev.scancode==GKBD.FAST_DOWN:
		if ev.pressed:
			advance(4*step)
		moved=true
	if ev.scancode==GKBD.HOME:
		if ev.pressed:
			set_row(0)
		moved=true
	if ev.scancode==GKBD.END:
		if ev.pressed:
			set_row(GLOBALS.song.pattern_length-1)
		moved=true
	if ev.scancode==GKBD.RIGHT:
		if ev.pressed:
			if ev.control or ev.command:
				set_channel(curr_channel+1)
			else:
				set_column(curr_column+1)
		moved=true
	if ev.scancode==GKBD.LEFT:
		if ev.pressed:
			if ev.control or ev.command:
				set_channel(curr_channel-1)
			else:
				set_column(curr_column-1)
		moved=true
	if moved:
		if ev.shift:
			if !kbd_drag:
				selection.set_start(old_channel,old_column,old_row)
				kbd_drag=true
			selection.set_end(curr_channel,curr_column,curr_row)
			selection.active=true
		else:
			kbd_drag=false
			selection.active=false
		return true
	#
	if ev.scancode==GKBD.DELETE and selection.active:
		if ev.pressed:
			selection.clear(collect_patterns(),curr_order,curr_channel)
		return true
	if ev.scancode==GKBD.INSERT:
		if ev.pressed:
			GLOBALS.song.insert_row(curr_order,curr_channel,curr_row)
		return true
	if fscan in GKBD.COPY:
		if ev.pressed and selection.active:
			selection.copy(collect_patterns())
		return true
	if fscan in GKBD.CUT:
		if ev.pressed and selection.active:
			selection.cut(collect_patterns(),curr_order,curr_channel)
		return true
	if fscan in GKBD.PASTE:
		if ev.pressed:
			selection.paste(GLOBALS.song,curr_order,curr_channel,curr_row,curr_column,false)
		return true
	if fscan in GKBD.MIX_PASTE:
		if ev.pressed:
			selection.paste(GLOBALS.song,curr_order,curr_channel,curr_row,curr_column,true)
		return true
	#
	if curr_column==ATTRS.LG_MODE:
		if ev.is_action_released("ui_select"):
			if !ev.pressed:
				put_legato(null)
			return true
		if ev.scancode==GKBD.DELETE:
			if ev.pressed:
				put_legato(Pattern.LEGATO_MODE.OFF)
			return true
		if ev.scancode in GKBD.VALUE_UP:
			if !ev.pressed:
				put_legato(null,1,0)
			return true
		if ev.scancode in GKBD.VALUE_DOWN:
			if !ev.pressed:
				put_legato(null,Pattern.LEGATO_MAX,0)
			return true
	if curr_column==ATTRS.NOTE:
		if ev.scancode in GKBD.KEYBOARD:
			if !ev.pressed:
				var semi:int=GKBD.KEYBOARD.find(ev.scancode)
				put_note(semi%12,GLOBALS.curr_octave+(semi/12),GLOBALS.curr_instrument)
			return true
		if ev.scancode==GKBD.DELETE:
			if ev.pressed:
				put_note(null,0,null)
			return true
		if ev.scancode==GKBD.NOTE_OFF:
			if !ev.pressed:
				put_note(-2 if ev.shift else -1,0,null)
			return true
		if ev.scancode in GKBD.VALUE_UP:
			if !ev.pressed:
				put_note(null,0,null,12 if ev.shift else 1,0)
			return true
		if ev.scancode in GKBD.VALUE_DOWN:
			if !ev.pressed:
				put_note(null,0,null,-12 if ev.shift else -1,0)
			return true
	if curr_column in [ATTRS.FM0,ATTRS.FM1,ATTRS.FM2,ATTRS.FM3]:
		if ev.scancode==GKBD.DELETE:
			if ev.pressed:
				put_opmask(0)
			return true
		if ev.scancode in GKBD.HEX_INPUT:
			if !ev.pressed:
				put_opmask(GKBD.HEX_INPUT.find(ev.scancode))
			return true
		if ev.scancode in GKBD.HEX_INPUT_KP:
			if !ev.pressed:
				put_opmask(GKBD.HEX_INPUT_KP.find(ev.scancode)/2)
			return true
		if ev.scancode in GKBD.VALUE_UP:
			if !ev.pressed:
				put_opmask(0,1)
			return true
		if ev.scancode in GKBD.VALUE_DOWN:
			if !ev.pressed:
				put_opmask(0,-1)
			return true
	if curr_column>ATTRS.NOTE:
		if ev.scancode==GKBD.DELETE:
			if ev.pressed:
				put_2_digits(null)
			return true
		if ev.scancode in GKBD.HEX_INPUT:
			if !ev.pressed:
				put_2_digits(GKBD.HEX_INPUT.find(ev.scancode))
			return true
		if ev.scancode in GKBD.HEX_INPUT_KP:
			if !ev.pressed:
				put_2_digits(GKBD.HEX_INPUT_KP.find(ev.scancode))
			return true
		if ev.scancode in GKBD.VALUE_UP:
			if !ev.pressed:
				put_2_digits(0,16 if ev.shift else 1)
			return true
		if ev.scancode in GKBD.VALUE_DOWN:
			if !ev.pressed:
				put_2_digits(0,-16 if ev.shift else -1)
			return true
	return false

#

func put_opmask(val:int,add:int=0)->void:
	var song:Song=GLOBALS.song
	if add!=0:
		val=(GLOBALS.nvl(song.get_note(curr_order,curr_channel,curr_row,curr_column),0)+add)&0xf
	song.set_note(curr_order,curr_channel,curr_row,curr_column,val)
	set_opmask(curr_row,channel_col0[curr_channel]+COLS[curr_column],val)
	advance(step if add==0 else 0)

func put_2_digits(val,add:int=0)->void:
	var song:Song=GLOBALS.song
	if add!=0:
		val=song.get_note(curr_order,curr_channel,curr_row,curr_column)
		if val==null:
			return
		val=(val+add)&0xff
		song.set_note(curr_order,curr_channel,curr_row,curr_column,val)
		digit_ix=0
	elif val==null:
		song.set_note(curr_order,curr_channel,curr_row,curr_column,null)
		digit_ix=0
	else:
		var n_val=GLOBALS.nvl(song.get_note(curr_order,curr_channel,curr_row,curr_column),0)<<4
		val=(n_val|(val&0xf))&0xff
		song.set_note(curr_order,curr_channel,curr_row,curr_column,val)
		digit_ix=(digit_ix+1)%2
	set_2_digits(curr_row,channel_col0[curr_channel]+COLS[curr_column],val)
	if digit_ix==0 and add==0:
		advance(step)

func put_legato(lm,add:int=1,adv:int=step)->void:
	var song:Song=GLOBALS.song
	var legato:int
	if lm==null:
		legato=(GLOBALS.nvl(song.get_note(curr_order,curr_channel,curr_row,ATTRS.LG_MODE),0)+add)%(Pattern.LEGATO_MAX+1)
	else:
		legato=clamp(lm,Pattern.LEGATO_MIN,Pattern.LEGATO_MAX)
	song.set_note(curr_order,curr_channel,curr_row,ATTRS.LG_MODE,legato)
	set_legato_cell(curr_row,channel_col0[curr_channel],legato)
	advance(adv)

func put_note(semitone,octave:int,instrument,add:int=0,adv:int=step)->void:
	var song:Song=GLOBALS.song
	var note
	if add!=0:
		note=song.get_note(curr_order,curr_channel,curr_row,ATTRS.NOTE)
		if note!=null:
			note=clamp(note+add,0,143)
		else:
			note=null
		instrument=song.get_note(curr_order,curr_channel,curr_row,ATTRS.INSTR)
	elif semitone==null:
		note=null
		instrument=null
	else:
		if semitone<0:
			note=-2 if semitone==-2 else -1
			instrument=null
		else:
			note=semitone+(octave*12)
	song.set_note(curr_order,curr_channel,curr_row,ATTRS.NOTE,note)
	song.set_note(curr_order,curr_channel,curr_row,ATTRS.INSTR,instrument)
	song.set_note(curr_order,curr_channel,curr_row,ATTRS.VOL,dflt_velocity)
	set_note_cells(curr_row,channel_col0[curr_channel],note)
	set_2_digits(curr_row,COLS[ATTRS.INSTR]+channel_col0[curr_channel],instrument)
	if note==null:
		set_2_digits(curr_row,COLS[ATTRS.VOL]+channel_col0[curr_channel],null)
	else:
		set_2_digits(curr_row,COLS[ATTRS.VOL]+channel_col0[curr_channel],dflt_velocity)
	advance(adv)

#

func _on_channels_changed()->void:
	var song:Song=GLOBALS.song
	channel_col0.resize(song.num_channels)
	var col0:int=0
	for i in range(0,song.num_channels):
		channel_col0[i]=col0
		col0+=16+song.num_fxs[i]*6
	update_tilemap()
	$Selection.update()

func _on_playing_pos_changed(order:int,row:int)->void:
	if order!=curr_order:
		curr_order=order
		update_tilemap()
	set_row(row)

func _on_order_changed(order_ix:int,channel_ix:int)->void:
	if order_ix==curr_order or order_ix<0:
		update_tilemap(channel_ix)

func update_tilemap(channel:int=-1)->void:
	var song:Song=GLOBALS.song
	if curr_order>=song.orders.size():
		curr_order=GLOBALS.curr_order
	var col:int=0
	lines.clear()
	for i in range(0,song.pattern_length):
		lines.set_cell(0,i,i/100)
		lines.set_cell(1,i,(i/10)%10)
		lines.set_cell(2,i,i%10)
	var ch_min:int=0
	var ch_max:int=song.num_channels
	if channel>=0 and channel<song.num_channels:
		ch_min=channel
		ch_max=channel+1
	else:
		editor.clear()
	for chan in range(ch_min,ch_max):
		var row:int=0
		var pat:Pattern=song.get_order_pattern(curr_order,chan)
		col=channel_col0[chan]
		for i in range(0,song.pattern_length):
			var note:Array=pat.notes[i]
			set_legato_cell(row,col,note[ATTRS.LG_MODE])
			set_note_cells(row,col,note[ATTRS.NOTE])
			set_2_digits(row,col+COLS[ATTRS.VOL],note[ATTRS.VOL])
			set_2_digits(row,col+COLS[ATTRS.PAN],note[ATTRS.PAN])
			set_2_digits(row,col+COLS[ATTRS.INSTR],note[ATTRS.INSTR])
			for fx in range(0,song.num_fxs[chan]*3,3):
				set_2_digits(row,col+COLS[ATTRS.FX0+fx],note[ATTRS.FX0+fx])
				set_opmask(row,col+COLS[ATTRS.FM0+fx],note[ATTRS.FM0+fx])
				set_2_digits(row,col+COLS[ATTRS.FV0+fx],note[ATTRS.FV0+fx])
			row+=1

func set_opmask(row:int,col:int,value)->void:
	if value==null or value==0:
		editor.set_cell(col,row,DOT)
	else:
		editor.set_cell(col,row,OP_MASK+(value&15))

func set_2_digits(row:int,col:int,value)->void:
	if value==null:
		editor.set_cell(col,row,DOT)
		editor.set_cell(col+1,row,DOT)
	else:
		editor.set_cell(col,row,value>>4)
		editor.set_cell(col+1,row,value&15)

func set_legato_cell(row:int,col:int,legato)->void:
	legato=legato if legato!=null else 0
	editor.set_cell(col,row,[DOT,LEGATO,STACCATO][legato])

func set_note_cells(row:int,col:int,note)->void:
	if note==null or note==-1 or note==-2:
		var ch:int=DOT if note==null else MINUS if note==-1 else SHARP
		editor.set_cell(col+1,row,ch)
		editor.set_cell(col+2,row,ch)
		editor.set_cell(col+3,row,ch)
		editor.set_cell(col+4,row,ch)
	else:
		editor.set_cell(col+1,row,SEMI2TILE[note%12])
		editor.set_cell(col+2,row,SHARP2TILE[note%12])
		var oc:int=(note/12)-1
		editor.set_cell(col+3,row,MINUS if oc<0 else (oc/10))
		editor.set_cell(col+4,row,int(abs(oc))%10)

#

func advance(f:int)->void:
	set_row(curr_row+f)

func set_row(r:int)->void:
	var sz:int=GLOBALS.song.pattern_length
	curr_row=clamp(r,0,sz-1)
	var dy:float=(rect_size.y*0.5)-(curr_row*16.0)
	digit_ix=0
	$BG.row=curr_row
	$BG.position.y=dy
	lines.position.y=dy
	editor.position.y=dy
	sel_rect.position.y=dy

func set_channel(c:int)->void:
	curr_channel=0 if c<0 else 31 if c>31 else c
	set_cursor()

func set_column(c:int)->void:
	digit_ix=0
	if c<0:
		if curr_channel>0:
			curr_column=ATTRS.FX0+(GLOBALS.song.num_fxs[curr_channel-1]*3)-1
			set_channel(curr_channel-1)
		else:
			curr_column=0
	elif c>ATTRS.FX0+(GLOBALS.song.num_fxs[curr_channel]*3)-1:
		if curr_channel<31:
			curr_column=0
			set_channel(curr_channel+1)
		else:
			curr_column=5
	else:
		curr_column=c
	set_cursor()

func set_cursor()->void:
	var c:Polygon2D=$Cursor
	if !focused:
		c.hide()
		return
	c.show()
	var x:float=32+((channel_col0[curr_channel]+COLS[curr_column])*8.0)+ofs_chan
	while x+(COL_WIDTH[curr_column]*8.0)>container_size.x:
		x-=144.0
		ofs_chan-=144.0
	while x<32.0:
		x+=144.0
		ofs_chan+=144.0
	emit_signal("horizontal_scroll",ofs_chan)
	editor.position.x=ofs_chan+32.0
	sel_rect.position.x=ofs_chan+32.0
	c.position=Vector2(x,rect_size.y*0.5)
	c.scale.x=COL_WIDTH[curr_column]

#

func _on_focus_entered()->void:
	grab_focus()
	focused=true
	$Cursor.show()
	set_cursor()

func _on_focus_exited()->void:
	release_focus()
	focused=false
	$Cursor.hide()

func _on_container_resized(cont:Control)->void:
	container=cont
	container_size=cont.rect_size
	set_cursor()

func _on_resized()->void:
	container_size=rect_size if container==null else container.rect_size
	set_row(curr_row)
	set_cursor()

func _on_order_selected(order:int)->void:
	curr_order=order
	update_tilemap()

func _on_Info_step_changed(s:int)->void:
	step=max(0.0,s)

func _on_Info_dflt_velocity_changed(vel:int):
	dflt_velocity=vel

func _on_Editor_mouse_entered():
	_on_focus_entered()

func _on_Editor_mouse_exited():
	_on_focus_exited()

func _on_Selection_ready():
	$Selection.set_arrays(COL_WIDTH,COLS,channel_col0)
