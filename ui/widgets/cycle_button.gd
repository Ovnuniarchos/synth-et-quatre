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

func _pressed()->void:
	status=(status+1)%colors.size()
	set_visuals()
	emit_signal("cycled",status)

func set_visuals()->void:
	modulate=colors[status]
