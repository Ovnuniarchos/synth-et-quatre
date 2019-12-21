tool extends Button
class_name CycleButton

signal cycled(status)

export (int) var status=0 setget set_status
export (PoolColorArray) var colors=PoolColorArray([Color.white]) setget set_colors

func _init()->void:
	toggle_mode=false

func _ready()->void:
	set_visuals()

func set_status(st:int)->void:
	status=st%colors.size()
	set_visuals()

func set_colors(c:PoolColorArray)->void:
	if c.size()==0:
		colors=PoolColorArray([Color.white])
		status=0
	else:
		colors=c
		status%=c.size()
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
	modulate=colors[status]
