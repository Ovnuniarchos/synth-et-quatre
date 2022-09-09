extends PanelContainer

signal order_selected(ix)

onready var list_scroll:ScrollContainer=$VBC/SC
onready var list:GridContainer=$VBC/SC/List
var order_labels:Array
var curr_highlight:int
var scroll_lock:bool=false

func _ready()->void:
	theme=THEME.get("theme")
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	AUDIO.tracker.connect("position_changed",self,"_on_playing_pos_changed")
	_on_song_changed()

func _on_song_changed()->void:
	GLOBALS.song.connect("order_changed",self,"_on_order_changed")
	GLOBALS.song.connect("channels_changed",self,"update_list")
	update_list()

func update_list(from:int=0,to:int=-1)->void:
	list.add_constant_override("hseparation",theme.get_constant("margin_x","OrderMatrix"))
	list.add_constant_override("vseparation",theme.get_constant("margin_y","OrderMatrix"))
	var song:Song=GLOBALS.song
	curr_highlight=GLOBALS.curr_order
	from=clamp(from,0,song.orders.size()-1)
	if to<0:
		to=song.orders.size()
	else:
		to=clamp(to,from+1,song.orders.size())
	list.columns=song.num_channels+1
	var l:Control
	for i in range(from*list.columns,list.get_child_count()):
		list.get_child(i).queue_free()
	order_labels.resize(to)
	for order in range(from,to):
		l=Button.new()
		l.focus_mode=FOCUS_NONE
		l.mouse_filter=Control.MOUSE_FILTER_STOP
		l.name="ord%03d"%[order]
		l.text="%03d"%[order]
		set_row_style(l,order==GLOBALS.curr_order)
		list.add_child(l)
		l.connect("gui_input",self,"_on_order_gui_input",[order])
		order_labels[order]=l
		for chn in range(song.num_channels):
			l=Button.new()
			l.focus_mode=FOCUS_NONE
			l.mouse_filter=Control.MOUSE_FILTER_STOP
			l.button_mask=BUTTON_MASK_LEFT|BUTTON_MASK_RIGHT
			l.name="ord%03dchn%02d"%[order,chn]
			l.text="%03d"%[song.orders[order][chn]]
			l.connect("gui_input",self,"_on_button_gui_input",[order,chn,l])
			ThemeHelper.apply_styles(theme,"OrderButton",l)
			list.add_child(l)
	highlight_current_order(true)

func set_row_style(row:Button,current:bool)->void:
	if not row.has_meta("styled"):
		row.set_meta("styled",true)
		ThemeHelper.apply_styles(theme,"RowButton",row)
	row.add_stylebox_override("normal",theme.get_stylebox("normal_on" if current else "normal","RowButton"))
	row.add_stylebox_override("hover",theme.get_stylebox("hover_on" if current else "hover","RowButton"))
	row.add_color_override("font_color",theme.get_color("font_color_on" if current else "font_color","RowButton"))
	row.add_color_override("font_color_hover",theme.get_color("font_color_hover_on" if current else "font_color_hover","RowButton"))

func highlight_current_order(full:bool)->void:
	var order:int=GLOBALS.curr_order
	if full:
		var song:Song=GLOBALS.song
		for i in range(song.orders.size()):
			set_row_style(list.get_child(i*list.columns),i==order)
	else:
		set_row_style(order_labels[curr_highlight],false)
		set_row_style(order_labels[order],true)
		curr_highlight=order

func _on_playing_pos_changed(order:int,_row:int)->void:
	if scroll_lock:
		return
	GLOBALS.curr_order=order
	highlight_current_order(false)

func _on_order_gui_input(ev:InputEvent,order:int)->void:
	ev=ev as InputEventMouseButton
	if ev==null or ev.button_index!=BUTTON_LEFT:
		return
	accept_event()
	if not ev.pressed:
		GLOBALS.curr_order=order
		highlight_current_order(false)
		emit_signal("order_selected",order)

func _on_order_changed(order:int,channel:int)->void:
	if order>=GLOBALS.song.orders.size():
		GLOBALS.curr_order=GLOBALS.song.orders.size()-1
		order=GLOBALS.curr_order
	elif order>=0:
		GLOBALS.curr_order=order
	if channel==-1:
		update_list(GLOBALS.curr_order)
	emit_signal("order_selected",GLOBALS.curr_order)

func _on_button_gui_input(ev:InputEvent,order:int,channel:int,button:Button)->void:
	ev=ev as InputEventMouseButton
	if ev==null or not(ev.button_index in [
				BUTTON_LEFT,BUTTON_RIGHT,BUTTON_WHEEL_UP,BUTTON_WHEEL_DOWN
			]):
		return
	if ev.button_index in [BUTTON_LEFT,BUTTON_RIGHT] or ev.shift or ev.control or ev.alt:
		accept_event()
	if not ev.is_pressed():
		return
	if order!=GLOBALS.curr_order and ev.button_index in [BUTTON_LEFT,BUTTON_RIGHT]:
		GLOBALS.goto_order(order)
		_on_playing_pos_changed(order,0)
		emit_signal("order_selected",order)
		return
	var song:Song=GLOBALS.song
	if order!=GLOBALS.curr_order:
		song.set_block_signals(true)
	if ev.button_index==BUTTON_LEFT:
		var o:int=song.orders[order][channel]+1
		if ev.shift:
			o=song.add_pattern(channel,-1)
		elif ev.control:
			o=song.add_pattern(channel,song.orders[order][channel])
		song.set_pattern(order,channel,o)
		button.text="%03d"%[song.orders[order][channel]]
	elif ev.button_index==BUTTON_WHEEL_UP:
		var o:int=song.orders[order][channel]
		if ev.shift:
			o=song.add_pattern(channel,-1)
		elif ev.control:
			o=song.add_pattern(channel,song.orders[order][channel])
		elif ev.alt:
			o+=1
		song.set_pattern(order,channel,o)
		button.text="%03d"%[song.orders[order][channel]]
	elif ev.button_index==BUTTON_RIGHT or (ev.button_index==BUTTON_WHEEL_DOWN and ev.alt):
		song.set_pattern(order,channel,song.orders[order][channel]-1)
		button.text="%03d"%[song.orders[order][channel]]
	song.set_block_signals(false)

#

func _on_Add_pressed()->void:
	GLOBALS.song.add_order()

func _on_Copy_pressed()->void:
	GLOBALS.song.add_order(GLOBALS.curr_order)

func _on_Del_pressed()->void:
	var order:int=GLOBALS.curr_order
	if order>=GLOBALS.song.orders.size()-1:
		GLOBALS.curr_order=max(0,GLOBALS.song.orders.size()-2)
		curr_highlight=GLOBALS.curr_order
		emit_signal("order_selected",GLOBALS.curr_order)
	GLOBALS.song.delete_order(order)

func _on_Up_pressed()->void:
	if GLOBALS.curr_order==0:
		return
	GLOBALS.song.swap_orders(GLOBALS.curr_order-1,GLOBALS.curr_order)

func _on_Down_pressed()->void:
	if GLOBALS.curr_order>=GLOBALS.song.orders.size()-2:
		return
	GLOBALS.song.swap_orders(GLOBALS.curr_order+1,GLOBALS.curr_order)

func _on_Editor_scroll_locked(lock:bool)->void:
	scroll_lock=lock
