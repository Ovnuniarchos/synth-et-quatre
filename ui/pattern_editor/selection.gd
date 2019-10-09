extends Reference
class_name Selection

signal selection_changed

var rect:Rect2
var active:bool setget set_active
var data:Array

func _init()->void:
	active=false

func set_active(act:bool)->void:
	active=act
	emit_signal("selection_changed")

func set_start(p:Vector2)->void:
	rect.position=p
	rect=rect.abs()
	emit_signal("selection_changed")

func set_end(p:Vector2)->void:
	rect.end=p
	rect=rect.abs()
	emit_signal("selection_changed")
