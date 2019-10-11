extends Reference
class_name Selection

signal selection_changed

var start_chan:int
var end_chan:int
var start_col:int
var end_col:int
var start_row:int
var end_row:int
var active:bool setget set_active
var data:Array

func _init()->void:
	active=false

func set_active(act:bool)->void:
	active=act
	emit_signal("selection_changed")

func set_start(chan:int,col:int,row:int)->void:
	start_chan=chan
	start_col=col
	start_row=row
	emit_signal("selection_changed")

func set_end(chan:int,col:int,row:int)->void:
	end_chan=chan
	end_col=col
	end_row=row
	emit_signal("selection_changed")
