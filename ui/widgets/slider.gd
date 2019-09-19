extends Slider

export (NodePath) var label:NodePath
var _label:Label
export (String) var mask:String="%3d" setget set_mask

func _ready():
	_label=get_node(label)
	_on_value_changed(value)
# warning-ignore:return_value_discarded
	connect("value_changed",self,"_on_value_changed")
	connect("gui_input",self,"_on_gui_input")

func _on_value_changed(v:float)->void:
	value=v
	if _label!=null:
		_label.text=mask%value

func set_mask(m:String)->void:
	mask=m
	_on_value_changed(value)

func _on_gui_input(ev:InputEvent)->void:
	ev=ev as InputEventMouseButton
	if ev==null:
		return
	var mult:float=1.0
	if ev.shift:
		mult*=10.0
	if ev.control:
		mult*=100.0
	if ev.button_index==BUTTON_WHEEL_DOWN:
		if !ev.pressed:
			value-=step*mult
			_on_value_changed(value)
		accept_event()
	elif ev.button_index==BUTTON_WHEEL_UP:
		if !ev.pressed:
			value+=step*mult
			_on_value_changed(value)
		accept_event()
