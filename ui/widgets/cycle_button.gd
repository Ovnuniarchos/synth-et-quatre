tool extends Button
class_name CycleButton

signal cycled(status)

export (int) var status=0 setget set_status
export (PoolColorArray) var colors=PoolColorArray([Color.white]) setget set_colors
export (PoolStringArray) var texts=PoolStringArray() setget set_texts
export (PoolStringArray) var tooltips=PoolStringArray() setget set_tooltips

var _def_color:Color
var _def_text:String
var _def_tooltip:String

func _init()->void:
	toggle_mode=false
	_def_color=modulate
	_def_text=text
	_def_tooltip=hint_tooltip

func _ready()->void:
	set_visuals()

func set_status(st:int)->void:
	status=st%colors.size()
	set_visuals()

func set_colors(c:PoolColorArray)->void:
	if c.size()==0:
		colors=PoolColorArray()
		status=0
	else:
		colors=c
		status%=c.size()
	property_list_changed_notify()
	set_visuals()

func set_modulate(c:Color)->void:
	.set_modulate(c)
	_def_color=c
	set_visuals()

func set_texts(t:PoolStringArray)->void:
	if t.size()==0:
		texts=PoolStringArray()
		status=0
	else:
		texts=t
		status%=t.size()
	property_list_changed_notify()
	set_visuals()

func set_text(t:String)->void:
	.set_text(t)
	_def_text=t
	set_visuals()

func set_tooltips(t:PoolStringArray)->void:
	if t.size()==0:
		tooltips=PoolStringArray()
		status=0
	else:
		tooltips=t
		status%=t.size()
	property_list_changed_notify()
	set_visuals()

func set_hint_tooltip(t:String)->void:
	.set_hint_tooltip(t)
	_def_tooltip=t
	set_visuals()

func cycle(dir:int)->void:
	status=(status+dir+colors.size())%colors.size()
	set_visuals()
	emit_signal("cycled",status)

func _gui_input(ev:InputEvent)->void:
	if !(ev is InputEventMouseButton):
		return
	if ev.button_index==BUTTON_LEFT or ev.button_index==BUTTON_RIGHT:
		if !ev.pressed:
			cycle(1 if ev.button_index==BUTTON_LEFT else -1)
		accept_event()

func set_visuals()->void:
	modulate=colors[status] if status<colors.size() else _def_color
	text=tr(texts[status] if status<texts.size() else _def_text)
	hint_tooltip=tr(tooltips[status] if status<tooltips.size() else _def_tooltip)
