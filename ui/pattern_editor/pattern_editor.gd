extends PanelContainer

signal horizontal_scroll(offset)
signal step_changed(step)
signal velocity_changed(velocity)
signal pan_changed(pan)
signal invert_changed(invl,invr)
signal order_changed(order)
signal scroll_locked(lock)

const ATTRS=Pattern.ATTRS

const LEGATO:int=19
const STACCATO:int=21
const DOT:int=20
const SHARP:int=17
const MINUS:int=18
const PLUS:int=37
const OP_MASK:int=21
const SEMI2TILE:Array=[12,12,13,13,14,15,15,16,16,10,10,11]
const SHARP2TILE:Array=[DOT,SHARP,DOT,SHARP,DOT,DOT,SHARP,DOT,SHARP,DOT,SHARP,DOT]
const COL_WIDTH:Array=[1,4,2,2,1,1,2,2,1,2,2,1,2,2,1,2,2,1,2]
const COL_SPACE:Array=[0,1,1,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1]
const COLS:Array=[]
var FX_MINCOL:int=0

const KEYOFF:int=-1
const KEYCUT:int=-2

var is_ready:bool=false
var curr_order:int=0
var curr_row:int=0
var curr_channel:int=0
var curr_column:int=0
var step:int=1
var midi_note:int=-1
var midi_vel:int=127
var midi_vol:int=127

var song:Song
var editor:TileMap
var lines:TileMap
var sel_rect:Node2D
var cursor:Node2D
var background:Node2D
var ofs_chan:int=0
var container:Control
var container_size:Vector2
var channel_col0:Array
var focused:bool=false
var digit_ix:int=0
var dflt_velocity:int=128
var dflt_pan:int=128
var dflt_invl:bool=false
var dflt_invr:bool=false
var selection:Selection=Selection.new()
var copy_buffer:Selection=Selection.new()
var dragging:bool=false
var drag_start:Vector2
var kbd_drag:bool=false
var scroll_lock:bool=false
var last_entered:Array=[]


func _init()->void:
	var col:int=0
	for i in COL_WIDTH.size():
		if i==ATTRS.FX0:
			FX_MINCOL=col
		COLS.append(col)
		col+=COL_WIDTH[i]+COL_SPACE[i]


func _ready()->void:
	editor=$PatternOrg/Pattern
	lines=$Lines
	sel_rect=$PatternOrg/Selection
	cursor=$PatternOrg/Cursor
	background=$BG
	setup_styles()
	GKBD.connect("step_changed",self,"_on_Gkbd_step_changed")
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	AUDIO.tracker.connect("position_changed",self,"_on_playing_pos_changed")
	_on_song_changed()
	_on_resized()
	selection.active=false
	sel_rect.selection=selection
	last_entered.resize(ATTRS.MAX)
	is_ready=true


func setup_styles()->void:
	lines.tile_set=ThemeHelper.get_theme_meta("tileset")
	lines.cell_size=Vector2(ThemeHelper.get_constant("cell_w","Tracker"),ThemeHelper.get_constant("cell_h","Tracker"))
	editor.tile_set=lines.tile_set
	editor.cell_size=lines.cell_size
	cursor.cell_size=lines.cell_size
	sel_rect.cell_size=lines.cell_size
	sel_rect.set_arrays(COL_WIDTH,COLS,channel_col0)
	$PatternOrg.position.x=lines.cell_size.x*4.0
	editor.modulate=ThemeHelper.get_color("color","Tracker")
	background.color_base=ThemeHelper.get_color("background","Tracker")
	background.color_min=ThemeHelper.get_color("minor","Tracker")
	background.color_maj=ThemeHelper.get_color("major","Tracker")
	background.color_active=ThemeHelper.get_color("active","Tracker")


func _on_song_changed()->void:
	song=GLOBALS.song
	song.connect("channels_changed",self,"_on_channels_changed")
	song.connect("order_changed",self,"_on_order_changed")
	song.connect("highlights_changed",self,"_on_highlights_changed")
	curr_order=0
	set_row(0)
	set_channel(0)
	set_column(0)
	selection.active=false
	_on_channels_changed()
	_on_highlights_changed()
	emit_signal("step_changed",step)
	emit_signal("velocity_changed",dflt_velocity)
	emit_signal("pan_changed",dflt_pan)
	emit_signal("invert_changed",dflt_invl,dflt_invr)


func _gui_input(event:InputEvent)->void:
	if process_mouse_motion(event as InputEventMouseMotion):
		accept_event()
		return
	if process_keyboard(event as InputEventKey):
		accept_event()
		return
	if process_mouse_button(event as InputEventMouseButton):
		accept_event()
		return
	if process_midi(event as InputEventMIDI):
		accept_event()
		return


func process_midi(ev:InputEventMIDI)->bool:
	if ev==null:
		return false
	var velocity:int
	if ev.message==MIDI_MESSAGE_NOTE_ON and ev.pitch==midi_note and ev.velocity==0:
		midi_note=-1
		if CONFIG.get_value(CONFIG.MIDI_NOTEOFF):
			put_note(KEYOFF,0,null)
		IM_SYNTH.play_note(false,false,ev.pitch)
		return true
	if ev.message==MIDI_MESSAGE_NOTE_ON and midi_note==-1:
		midi_vel=ev.velocity
		midi_note=ev.pitch
		put_note(ev.pitch%12,ev.pitch/12,GLOBALS.curr_instrument)
		IM_SYNTH.play_note(true,false,ev.pitch)
		return true
	if ev.message==MIDI_MESSAGE_NOTE_OFF and ev.pitch==midi_note:
		midi_note=-1
		if CONFIG.get_value(CONFIG.MIDI_NOTEOFF):
			put_note(KEYOFF,0,null)
		IM_SYNTH.play_note(false,false,ev.pitch)
		return true
	if ev.message==MIDI_MESSAGE_AFTERTOUCH and CONFIG.get_value(CONFIG.MIDI_AFTERTOUCH)\
			and midi_note==ev.pitch:
		midi_vel=ev.pressure
		velocity=calculate_velocity(dflt_velocity,midi_vel,midi_vol)
		GLOBALS.song.set_note(curr_order,curr_channel,curr_row,ATTRS.VOL,velocity)
		set_2_digits(curr_row,COLS[ATTRS.VOL]+channel_col0[curr_channel],velocity)
		advance(1)
		return true
	if ev.message==MIDI_MESSAGE_CONTROL_CHANGE and ev.controller_number==7:
		midi_vol=ev.controller_value
		if CONFIG.get_value(CONFIG.MIDI_VOLUME):
			velocity=calculate_velocity(dflt_velocity,midi_vel if midi_note!=-1 else 127,midi_vol)
			GLOBALS.song.set_note(curr_order,curr_channel,curr_row,ATTRS.VOL,velocity)
			set_2_digits(curr_row,COLS[ATTRS.VOL]+channel_col0[curr_channel],velocity)
			advance(1)
		return true
	return false


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


func process_keyboard(ev:InputEventKey)->bool:
	if ev==null or !focused:
		return false
	var fscan:int=ev.get_scancode_with_modifiers()
	# Movement
	var moved:bool=false
	var old_channel:int=curr_channel
	var old_column:int=curr_column
	var old_row:int=curr_row
	if ev.scancode==GKBD.SCROLL_LOCK:
		if !ev.pressed:
			scroll_lock=not scroll_lock
			emit_signal("scroll_locked",scroll_lock)
		return true
	if ev.scancode==GKBD.DOWN:
		if ev.pressed:
			if ev.alt:
				GLOBALS.song.swap_notes(curr_order,curr_channel,curr_row,1)
				update_row(curr_row,curr_channel)
				update_row(curr_row+1,curr_channel)
			advance(1)
			moved=true
	elif ev.scancode==GKBD.UP:
		if ev.pressed:
			if ev.alt:
				GLOBALS.song.swap_notes(curr_order,curr_channel,curr_row,-1)
				update_row(curr_row,curr_channel)
				update_row(curr_row-1,curr_channel)
			advance(-1)
			moved=true
	elif ev.scancode==GKBD.STEP:
		if ev.pressed:
			advance(step)
			moved=true
	elif ev.scancode==GKBD.FAST_UP:
		if ev.control:
			if !ev.pressed:
				GLOBALS.goto_order(GLOBALS.curr_order-1)
				emit_signal("order_changed",GLOBALS.curr_order)
		elif ev.pressed:
			advance(-4*step)
			moved=true
	elif ev.scancode==GKBD.FAST_DOWN:
		if ev.control:
			if !ev.pressed:
				GLOBALS.goto_order(GLOBALS.curr_order+1)
				emit_signal("order_changed",GLOBALS.curr_order)
		elif ev.pressed:
			advance(4*step)
			moved=true
	elif ev.scancode==GKBD.HOME:
		if ev.pressed:
			set_row(0)
			moved=true
	elif ev.scancode==GKBD.END:
		if ev.pressed:
			set_row(GLOBALS.song.pattern_length-1)
			moved=true
	elif ev.scancode==GKBD.RIGHT:
		if ev.pressed:
			if ev.control or ev.command:
				set_channel(curr_channel+1)
			elif ev.alt:
				GLOBALS.song.swap_pattern(curr_order,curr_order,curr_channel,curr_channel+1)
			else:
				set_column(curr_column+1)
			moved=true
	elif ev.scancode==GKBD.LEFT:
		if ev.pressed:
			if ev.control or ev.command:
				set_channel(curr_channel-1)
			elif ev.alt:
				GLOBALS.song.swap_pattern(curr_order,curr_order,curr_channel,curr_channel-1)
			else:
				set_column(curr_column-1)
			moved=true
	# Selection
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
	elif !ev.shift:
		kbd_drag=false
	if selection.active:
		if ev.scancode==GKBD.CLEAR:
			if !ev.pressed:
				selection.clear(GLOBALS.song,curr_order)
			return true
		if fscan==GKBD.INTERPOLATE:
			if !ev.pressed:
				selection.interpolate(GLOBALS.song,curr_order)
			return true
		if fscan in GKBD.COPY:
			if !ev.pressed:
				selection.copy(GLOBALS.song,curr_order)
				copy_buffer=selection.duplicate()
			return true
		if fscan in GKBD.CUT:
			if !ev.pressed:
				selection.cut(GLOBALS.song,curr_order)
				copy_buffer=selection.duplicate()
			return true
		if ev.scancode in GKBD.VALUE_UP:
			if !ev.pressed:
				selection.add_values(GLOBALS.song,curr_order,1,ev.shift)
			return true
		if ev.scancode in GKBD.VALUE_DOWN:
			if !ev.pressed:
				selection.add_values(GLOBALS.song,curr_order,-1,ev.shift)
			return true
	# Ins/del, C/P
	if ev.scancode==GKBD.INSERT:
		if ev.pressed:
			GLOBALS.song.insert_row(curr_order,curr_channel,curr_row)
		return true
	if fscan==GKBD.DELETE:
		if ev.pressed:
			GLOBALS.song.delete_row(curr_order,curr_channel,curr_row)
		return true
	if fscan in GKBD.PASTE:
		if !ev.pressed:
			copy_buffer.paste(GLOBALS.song,curr_order,curr_channel,curr_row,curr_column,false)
		return true
	if fscan in GKBD.MIX_PASTE:
		if !ev.pressed:
			copy_buffer.paste(GLOBALS.song,curr_order,curr_channel,curr_row,curr_column,true)
		return true
	if fscan in GKBD.DUPLICATE_ENTERED:
		if ev.pressed and curr_row>0:
			copy_last(true)
		return true
	if fscan in GKBD.DUPLICATE_LAST:
		if ev.pressed and curr_row>0:
			copy_last(false)
		return true
	# Data input
	if curr_column==ATTRS.LG_MODE:
		if ev.scancode==GKBD.CLEAR:
			if ev.pressed:
				put_legato(Pattern.LEGATO_MODE.OFF)
			return true
		if ev.scancode in GKBD.VALUE_UP:
			if ev.pressed:
				put_legato(null,1,0)
			return true
		if ev.scancode in GKBD.VALUE_DOWN:
			if ev.pressed:
				put_legato(null,Pattern.LEGATO_MAX,0)
			return true
		if ev.scancode in GKBD.KEYBOARD:
			if !ev.pressed:
				var semi:int=GKBD.KEYBOARD.find(ev.scancode)
				if ev.shift:
					put_legato(Pattern.LEGATO_MODE.LEGATO,0,0)
				elif ev.control:
					put_legato(Pattern.LEGATO_MODE.STACCATO,0,0)
				put_note(semi%12,GLOBALS.curr_octave+(semi/12),GLOBALS.curr_instrument)
			return true
	if curr_column==ATTRS.NOTE:
		if ev.scancode in GKBD.KEYBOARD:
			if !ev.pressed:
				var semi:int=GKBD.KEYBOARD.find(ev.scancode)
				if ev.shift:
					put_legato(Pattern.LEGATO_MODE.LEGATO,0,0)
				elif ev.alt:
					put_legato(Pattern.LEGATO_MODE.STACCATO,0,0)
				put_note(semi%12,GLOBALS.curr_octave+(semi/12),GLOBALS.curr_instrument)
			return true
		if ev.scancode==GKBD.CLEAR:
			if ev.pressed:
				put_note(null,0,null)
			return true
		if ev.scancode==GKBD.NOTE_OFF:
			if !ev.pressed:
				put_note(KEYCUT if ev.shift else KEYOFF,0,null)
			return true
		if ev.scancode in GKBD.VALUE_UP:
			if ev.pressed:
				put_note(null,0,null,12 if ev.shift else 1,0)
			return true
		if ev.scancode in GKBD.VALUE_DOWN:
			if ev.pressed:
				put_note(null,0,null,-12 if ev.shift else -1,0)
			return true
	elif curr_column in [ATTRS.FM0,ATTRS.FM1,ATTRS.FM2,ATTRS.FM3]:
		if ev.scancode==GKBD.CLEAR:
			if !ev.pressed:
				put_opmask(0)
			return true
		elif ev.scancode in GKBD.HEX_INPUT:
			if !ev.pressed:
				put_opmask(GKBD.HEX_INPUT.find(ev.scancode))
			return true
		elif ev.scancode in GKBD.HEX_INPUT_KP:
			if !ev.pressed:
				put_opmask(GKBD.HEX_INPUT_KP.find(ev.scancode)/2)
			return true
		elif ev.scancode in GKBD.VALUE_UP:
			if ev.pressed:
				put_opmask(0,1)
			return true
		elif ev.scancode in GKBD.VALUE_DOWN:
			if ev.pressed:
				put_opmask(0,-1)
			return true
	elif curr_column in [ATTRS.INVL,ATTRS.INVR]:
		if ev.scancode==GKBD.CLEAR:
			if !ev.pressed:
				put_inverter(null)
			return true
		elif ev.scancode in GKBD.VALUE_UP:
			if ev.pressed:
				put_inverter(0)
			return true
		elif ev.scancode in GKBD.VALUE_DOWN:
			if ev.pressed:
				put_inverter(1)
			return true
	elif curr_column>ATTRS.NOTE:
		if ev.scancode==GKBD.CLEAR:
			if !ev.pressed:
				put_cmd_or_val(null)
			return true
		elif ev.scancode in GKBD.HEX_INPUT:
			if !ev.pressed:
				put_cmd_or_val(GKBD.HEX_INPUT.find(ev.scancode))
			return true
		elif ev.scancode in GKBD.HEX_INPUT_KP:
			if !ev.pressed:
				put_cmd_or_val(GKBD.HEX_INPUT_KP.find(ev.scancode))
			return true
		elif ev.scancode in GKBD.VALUE_UP:
			if ev.pressed:
				put_cmd_or_val(0,16 if ev.shift else 1)
			return true
		elif ev.scancode in GKBD.VALUE_DOWN:
			if ev.pressed:
				put_cmd_or_val(0,-16 if ev.shift else -1)
			return true
	return false


#


func find_last():
	var row:int=curr_row-1
	var data
	while row>-1:
		data=song.get_note(curr_order,curr_channel,row,curr_column)
		if data!=null:
			return data
		row-=1
	return null

func copy_last(entered:bool)->void:
	var val=last_entered[curr_column] if entered else find_last()
	song.set_note(curr_order,curr_channel,curr_row,curr_column,val)
	if curr_column==ATTRS.LG_MODE:
		set_legato_cell(curr_row,channel_col0[curr_channel],val)
	elif curr_column==ATTRS.NOTE:
		set_note_cells(curr_row,channel_col0[curr_channel],val)
	elif curr_column in [ATTRS.FM0,ATTRS.FM1,ATTRS.FM2,ATTRS.FM3]:
		set_opmask(curr_row,COLS[curr_column],val)
	else:
		set_2_digits(curr_row,COLS[curr_column]+channel_col0[curr_channel],val)
	advance(step)


func put_opmask(val:int,add:int=0)->void:
	if add!=0:
		val=(GLOBALS.nvl(song.get_note(curr_order,curr_channel,curr_row,curr_column),0)+add)&0xf
	song.set_note(curr_order,curr_channel,curr_row,curr_column,val)
	last_entered[curr_column]=val
	set_opmask(curr_row,channel_col0[curr_channel]+COLS[curr_column],val)
	if add==0 and CONFIG.get_value(CONFIG.EDIT_HORIZ_FX):
		set_column(curr_column+1)
		return
	advance(step if add==0 else 0)


func put_cmd_or_val(val,add:int=0)->void:
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
		add=1
	else:
		var n_val=GLOBALS.nvl(song.get_note(curr_order,curr_channel,curr_row,curr_column),0)<<4
		val=(n_val|(val&0xf))&0xff
		digit_ix=(digit_ix+1)%2
		song.set_note(curr_order,curr_channel,curr_row,curr_column,val)
		last_entered[curr_column]=val
	set_2_digits(curr_row,channel_col0[curr_channel]+COLS[curr_column],val)
	if digit_ix==0 and add==0:
		if CONFIG.get_value(CONFIG.EDIT_HORIZ_FX):
			if curr_column<ATTRS.FX0+(GLOBALS.song.num_fxs[curr_channel]*3)-1:
				set_column(curr_column+1)
			elif !CONFIG.get_value(CONFIG.EDIT_FX_CRLF):
				set_column(curr_column-2)
		else:
			advance(step)


func put_legato(lm,add:int=1,adv:int=step)->void:
	var legato:int
	if lm==null:
		legato=(GLOBALS.nvl(song.get_note(curr_order,curr_channel,curr_row,ATTRS.LG_MODE),0)+add)%(Pattern.LEGATO_MAX+1)
	else:
		legato=clamp(lm,Pattern.LEGATO_MIN,Pattern.LEGATO_MAX)
	song.set_note(curr_order,curr_channel,curr_row,ATTRS.LG_MODE,legato)
	last_entered[ATTRS.LG_MODE]=legato
	set_legato_cell(curr_row,channel_col0[curr_channel],legato)
	advance(adv)


func put_note(semitone,octave:int,instrument,add:int=0,adv:int=step)->void:
	var note
	if add!=0:
		note=song.get_note(curr_order,curr_channel,curr_row,ATTRS.NOTE)
		if note!=null:
			if note!=KEYCUT and note!=KEYOFF:
				note=clamp(note+add,0,143)
		else:
			note=null
		instrument=song.get_note(curr_order,curr_channel,curr_row,ATTRS.INSTR)
	elif semitone==null:
		note=null
		instrument=null
	else:
		if semitone<0:
			note=KEYCUT if semitone==KEYCUT else KEYOFF
			instrument=null
		else:
			note=semitone+(octave*12)
	song.set_note(curr_order,curr_channel,curr_row,ATTRS.NOTE,note)
	last_entered[ATTRS.NOTE]=note
	if add!=0:
		set_note_cells(curr_row,channel_col0[curr_channel],note)
		advance(adv)
		return
	song.set_note(curr_order,curr_channel,curr_row,ATTRS.INSTR,instrument)
	last_entered[ATTRS.INSTR]=instrument
# warning-ignore:incompatible_ternary
# warning-ignore:incompatible_ternary
	var velocity:int=calculate_velocity(dflt_velocity,midi_vel,midi_vol)
	song.set_note(curr_order,curr_channel,curr_row,ATTRS.VOL,velocity if instrument!=null else null)
# warning-ignore:incompatible_ternary
	last_entered[ATTRS.VOL]=velocity if instrument!=null else null
	set_note_cells(curr_row,channel_col0[curr_channel],note)
	set_2_digits(curr_row,COLS[ATTRS.INSTR]+channel_col0[curr_channel],instrument)
	if instrument==null:
		set_2_digits(curr_row,COLS[ATTRS.VOL]+channel_col0[curr_channel],null)
	else:
		set_2_digits(curr_row,COLS[ATTRS.VOL]+channel_col0[curr_channel],velocity)
	song.set_note(curr_order,curr_channel,curr_row,ATTRS.INVL,int(dflt_invl))
	song.set_note(curr_order,curr_channel,curr_row,ATTRS.INVR,int(dflt_invr))
	song.set_note(curr_order,curr_channel,curr_row,ATTRS.PAN,dflt_pan)
	set_inverter(curr_row,COLS[ATTRS.INVL]+channel_col0[curr_channel],int(dflt_invl))
	set_inverter(curr_row,COLS[ATTRS.INVR]+channel_col0[curr_channel],int(dflt_invr))
	set_2_digits(curr_row,COLS[ATTRS.PAN]+channel_col0[curr_channel],dflt_pan)
	advance(adv)


func calculate_velocity(base:int,vel:int,vol:int)->int:
	var vel_mode:int=CONFIG.get_value(CONFIG.MIDI_VELOCITYSRC)
	if vel_mode==CONFIG.VELMODE_SE4:
		return base
	if vel_mode==CONFIG.VELMODE_VEL:
		return int(floor(vel*2.008))
	elif vel_mode==CONFIG.VELMODE_VOL:
		return int(floor(vol*2.008))
	elif vel_mode==CONFIG.VELMODE_SE4VEL:
		return (base*vel)/127
	elif vel_mode==CONFIG.VELMODE_SE4VOL:
		return (base*vol)/127
	elif vel_mode==CONFIG.VELMODE_VELVOL:
		return int(floor((vel*vol)/63.25))
	return (base*vel*vol)/16129


func put_inverter(val)->void:
	song.set_note(curr_order,curr_channel,curr_row,curr_column,val)
	set_inverter(curr_row,COLS[curr_column]+channel_col0[curr_channel],val)
	if CONFIG.get_value(CONFIG.EDIT_HORIZ_FX):
		set_column(curr_column+1)
	else:
		advance(step)

#


func _on_channels_changed()->void:
	channel_col0.resize(song.num_channels)
	var col0:int=0
	for i in range(channel_col0.size()):
		channel_col0[i]=col0
		col0+=FX_MINCOL+song.num_fxs[i]*6
	channel_col0.append(col0)
	update_tilemap()
	set_channel(curr_channel)
	set_column(curr_column)
	sel_rect.update()


func _on_playing_pos_changed(order:int,row:int)->void:
	if scroll_lock:
		return
	if order!=curr_order:
		curr_order=order
		update_tilemap()
	set_row(row)


func _on_order_changed(order_ix:int,channel_ix:int)->void:
	if order_ix==curr_order or order_ix<0:
		update_tilemap(channel_ix)


func update_tilemap(channel:int=-1)->void:
	var col:int=0
	lines.clear()
	for i in range(song.pattern_length):
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
		for i in song.pattern_length:
			var note:Array=pat.notes[i]
			set_legato_cell(row,col,note[ATTRS.LG_MODE])
			set_note_cells(row,col,note[ATTRS.NOTE])
			set_2_digits(row,col+COLS[ATTRS.VOL],note[ATTRS.VOL])
			set_inverter(row,col+COLS[ATTRS.INVL],note[ATTRS.INVL])
			set_inverter(row,col+COLS[ATTRS.INVR],note[ATTRS.INVR])
			set_2_digits(row,col+COLS[ATTRS.PAN],note[ATTRS.PAN])
			set_2_digits(row,col+COLS[ATTRS.INSTR],note[ATTRS.INSTR])
			for fx in range(0,song.num_fxs[chan]*3,3):
				set_2_digits(row,col+COLS[ATTRS.FX0+fx],note[ATTRS.FX0+fx])
				set_opmask(row,col+COLS[ATTRS.FM0+fx],note[ATTRS.FM0+fx])
				set_2_digits(row,col+COLS[ATTRS.FV0+fx],note[ATTRS.FV0+fx])
			row+=1


func update_row(row:int,channel:int=-1)->void:
	if row<0 or row>=song.pattern_length:
		return
	var col:int
	var ch_min:int=0
	var ch_max:int=song.num_channels
	if channel>=0:
		ch_min=channel
		ch_max=channel+1
	for chan in range(ch_min,ch_max):
		var pat:Pattern=song.get_order_pattern(curr_order,chan)
		col=channel_col0[chan]
		var note:Array=pat.notes[row]
		set_legato_cell(row,col,note[ATTRS.LG_MODE])
		set_note_cells(row,col,note[ATTRS.NOTE])
		set_2_digits(row,col+COLS[ATTRS.VOL],note[ATTRS.VOL])
		set_inverter(row,col+COLS[ATTRS.INVL],note[ATTRS.INVL])
		set_inverter(row,col+COLS[ATTRS.INVR],note[ATTRS.INVR])
		set_2_digits(row,col+COLS[ATTRS.PAN],note[ATTRS.PAN])
		set_2_digits(row,col+COLS[ATTRS.INSTR],note[ATTRS.INSTR])
		for fx in range(0,song.num_fxs[chan]*3,3):
			set_2_digits(row,col+COLS[ATTRS.FX0+fx],note[ATTRS.FX0+fx])
			set_opmask(row,col+COLS[ATTRS.FM0+fx],note[ATTRS.FM0+fx])
			set_2_digits(row,col+COLS[ATTRS.FV0+fx],note[ATTRS.FV0+fx])


func set_inverter(row:int,col:int,value)->void:
	if value==null:
		editor.set_cell(col,row,DOT)
	elif value==0:
		editor.set_cell(col,row,PLUS)
	else:
		editor.set_cell(col,row,MINUS)


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
	if note==null or note==KEYOFF or note==KEYCUT:
		var ch:int=DOT if note==null else MINUS if note==KEYOFF else SHARP
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


func set_bg_rows(rows:int)->void:
	background.rows=rows


func advance(f:int)->void:
	set_row(curr_row+f)


func set_row(r:int)->void:
	var sz:int=GLOBALS.song.pattern_length
	curr_row=clamp(r,0,sz-1)
	var dy:float=(rect_size.y*0.5)-(curr_row*16.0)
	digit_ix=0
	background.row=curr_row
	background.position.y=dy
	lines.position.y=dy
	editor.position.y=dy
	sel_rect.position.y=dy


func set_channel(c:int)->void:
	var nc:int=GLOBALS.song.num_channels-1
	curr_channel=0 if c<0 else nc if c>nc else c
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
		if curr_channel<GLOBALS.song.num_channels-1:
			curr_column=0
			set_channel(curr_channel+1)
		else:
			curr_column=5
	else:
		curr_column=c
	set_cursor()


func set_cursor()->void:
	if !focused:
		cursor.hide()
		return
	var x:float=((channel_col0[curr_channel]+COLS[curr_column])*lines.cell_size.x)+ofs_chan
	var c:float=22.0*lines.cell_size.x
	while x+(COL_WIDTH[curr_column]*lines.cell_size.x)>container_size.x:
		x-=c
		ofs_chan-=c
	while x<0.0:
		x+=c
		ofs_chan+=c
	emit_signal("horizontal_scroll",ofs_chan)
	editor.position.x=ofs_chan
	sel_rect.position.x=ofs_chan
	cursor.position=Vector2(x,rect_size.y*0.5)
	cursor.cell_size=editor.cell_size*Vector2(COL_WIDTH[curr_column],1.0)
	cursor.show()


#


func _on_focus_entered()->void:
	grab_focus()
	focused=true
	cursor.show()
	set_cursor()


func _on_focus_exited()->void:
	release_focus()
	focused=false
	cursor.hide()


func _on_container_resized(cont:Control)->void:
	container=cont
	container_size=cont.rect_size-Vector2(lines.cell_size.x*4.0,0.0)
	set_cursor()


func _on_resized()->void:
	container_size=rect_size if container==null else container.rect_size
	set_row(curr_row)
	set_cursor()


func _on_order_selected(order:int)->void:
	curr_order=order
	update_tilemap()


func _on_Gkbd_step_changed(delta:int)->void:
	_on_Info_step_changed(step+delta)


func _on_Info_step_changed(s:int)->void:
	step=max(0.0,s)
	emit_signal("step_changed",step)


func _on_Info_velocity_changed(vel:int)->void:
	dflt_velocity=vel
	emit_signal("velocity_changed",dflt_velocity)


func _on_highlights_changed()->void:
	background.every_min=GLOBALS.song.minor_highlight
	background.every_maj=GLOBALS.song.major_highlight


func _on_Info_pan_changed(pan:int)->void:
	dflt_pan=pan
	emit_signal("pan_changed",pan)


func _on_Info_invert_changed(invl:bool,invr:bool)->void:
	dflt_invl=invl
	dflt_invr=invr
	emit_signal("invert_changed",invl,invr)
