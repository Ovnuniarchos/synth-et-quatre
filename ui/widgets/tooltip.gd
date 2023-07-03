extends PanelContainer
class_name Tooltip

var label:Label
var timer:Timer

func _ready()->void:
	label=Label.new()
	add_child(label)
	timer=Timer.new()
	timer.one_shot=true
	timer.connect("timeout",self,"_on_timeout")
	add_child(timer)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	visible=false
	var real_theme:Theme=THEME.get("theme")
	if real_theme!=null:
		add_stylebox_override("panel",real_theme.get_stylebox("panel","TooltipPanel"))

func show_at(t:String,p:Vector2)->void:
	label.text=t
	rect_position=p
	rect_size=Vector2.ZERO
	visible=true
	timer.paused=true

func fade()->void:
	timer.start(0.2)
	timer.paused=false

func _on_timeout()->void:
	visible=false
