extends Node

var watching:bool
var midi_open:bool
var thread:Thread

func _ready()->void:
	watching=true
	midi_open=false
	thread=Thread.new()
	thread.start(self,"_watchdog_thread",null)

func _notification(n:int)->void:
	if n==NOTIFICATION_PREDELETE:
		watching=false
		thread.wait_to_finish()
		OS.close_midi_inputs()

func _watchdog_thread(_args:Object)->void:
	while watching:
		if !midi_open:
			OS.open_midi_inputs()
			midi_open=true
		var mdl:PoolStringArray=OS.get_connected_midi_inputs()
		if mdl.empty():
			midi_open=false
		else:
			for md in mdl:
				if md.empty():
					midi_open=false
					break
		if !midi_open:
			OS.close_midi_inputs()
		OS.delay_msec(25)
