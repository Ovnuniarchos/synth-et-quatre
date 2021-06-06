extends Node

signal midi_on(on)

var midi_open:bool
var watchdog:Timer

func _ready()->void:
	set_midi_open(false)
	watchdog=Timer.new()
	watchdog.one_shot=false
	watchdog.wait_time=0.02
	watchdog.autostart=true
	watchdog.connect("timeout",self,"_watchdog_thread")
	#add_child(watchdog)

func _notification(n:int)->void:
	if n==NOTIFICATION_PREDELETE:
		OS.close_midi_inputs()

func _watchdog_thread()->void:
	if !midi_open:
		OS.open_midi_inputs()
		midi_open=true
	var mdl:Array=[]
	for md in OS.get_connected_midi_inputs():
		if md.to_lower().find("virtual")==-1: # Ignore ALSA virtual devices
			mdl.append(md)
	if mdl.empty():
		midi_open=false
	else:
		for md in mdl:
			if md.empty():
				midi_open=false
				break
	set_midi_open(midi_open)
	if !midi_open:
		OS.close_midi_inputs()
		DEBUG.set_var("MIDI","off")
	else:
		DEBUG.set_var("MIDI",String(mdl))

func set_midi_open(on:bool)->void:
	midi_open=on
	emit_signal("midi_on",on)
