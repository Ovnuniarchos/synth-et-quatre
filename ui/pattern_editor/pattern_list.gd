extends PanelContainer

signal order_selected(ix)

onready var list_scroll:ScrollContainer=$VBC/SC
onready var list:GridContainer=$VBC/SC/List
var order_labels:Array

func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	_on_song_changed()

func _on_song_changed()->void:
	GLOBALS.song.connect("order_changed",self,"_on_order_changed")
	update_list()

func update_list(from:int=0,to:int=-1)->void:
	var song:Song=GLOBALS.song
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
		l=Label.new()
		l.name="ord%03d"%[order]
		l.text="%03d"%[order]
		l.modulate=Color8(0,255,0) if order==GLOBALS.curr_order else Color8(255,255,255)
		list.add_child(l)
		order_labels[order]=l
		for chn in range(0,song.num_channels):
			l=OrderButton.new(list_scroll)
			l.name="ord%03dchn%02d"%[order,chn]
			l.text="%03d"%[song.orders[order][chn]]
			l.connect("gui_input",self,"_on_button_gui_input",[order,chn,l])
			list.add_child(l)

func highlight_current_order()->void:
	var song:Song=GLOBALS.song
	for i in range(0,song.orders.size()):
		list.get_child(i*list.columns).modulate=Color8(0,255,0) if i==GLOBALS.curr_order else Color8(255,255,255)

func _on_order_changed(order:int,channel:int)->void:
	if channel==-1:
		update_list(order)

func _on_button_gui_input(ev:InputEvent,order:int,channel:int,button:Button)->void:
	ev=ev as InputEventMouseButton
	if ev==null or ev.is_pressed() or\
			(ev.button_index!=BUTTON_MASK_LEFT and ev.button_index!=BUTTON_MASK_RIGHT):
		return
	if order!=GLOBALS.curr_order:
		GLOBALS.goto_order(order)
		highlight_current_order()
		emit_signal("order_selected",order)
		return
	var song:Song=GLOBALS.song
	if ev.button_index==BUTTON_LEFT:
		var o:int=song.orders[order][channel]+1
		if ev.shift:
			o=song.add_pattern(channel,-1)
		elif ev.control:
			o=song.add_pattern(channel,song.orders[order][channel])
		song.set_pattern(order,channel,o)
		button.text="%03d"%[song.orders[order][channel]]
		return
	else:
		song.set_pattern(order,channel,song.orders[order][channel]-1)
		button.text="%03d"%[song.orders[order][channel]]
		return

#

func _on_Add_pressed():
	GLOBALS.song.add_order()

func _on_Copy_pressed():
	GLOBALS.song.add_order(GLOBALS.curr_order)

func _on_Del_pressed():
	var order:int=GLOBALS.curr_order
	if order==GLOBALS.song.orders.size()-1:
		GLOBALS.curr_order-=1
	GLOBALS.song.delete_order(order)
