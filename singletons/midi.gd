extends Node

signal midi_on(on)

var midi_open:bool
var midi_on:bool
var watchdog:Timer

func _ready()->void:
	set_midi_open(false)
	watchdog=Timer.new()
	watchdog.one_shot=false
	watchdog.wait_time=0.2
	watchdog.autostart=true
	watchdog.connect("timeout",self,"_watchdog_thread")
	add_child(watchdog)

func _notification(n:int)->void:
	if n==NOTIFICATION_PREDELETE:
		set_midi_open(false)

func _watchdog_thread()->void:
	if !midi_open:
		OS.open_midi_inputs()
		midi_open=true
	var mdl:Array=[]
	for md in OS.get_connected_midi_inputs():
		if md.to_lower().find("virtual")==-1: # Ignore ALSA virtual devices
			mdl.append(md)
	var on:bool=false
	if not mdl.empty():
		on=true
		for md in mdl:
			if md.empty():
				on=false
				break
	set_midi_open(on)

func set_midi_open(on:bool)->void:
	if not on:
		OS.close_midi_inputs()
		midi_open=false
	if on!=midi_on:
		emit_signal("midi_on",on)
	midi_on=on
