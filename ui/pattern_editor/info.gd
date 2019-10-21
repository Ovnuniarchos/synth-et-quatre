extends PanelContainer

signal step_changed(step)
signal velocity_changed(velocity)

func _ready()->void:
	GKBD.connect("octave_changed",self,"_on_octave_changed")
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	_on_song_changed()
	$GC/Step.value=1

func _on_song_changed()->void:
	set_block_signals(true)
	$GC/Octave.value=GLOBALS.curr_octave-1
	$GC/TicksSec.value=GLOBALS.song.ticks_second
	$GC/TicksRow.value=GLOBALS.song.ticks_row
	$GC/RowsPat.value=GLOBALS.song.pattern_length
	$GC/Channels.value=GLOBALS.song.num_channels
	set_block_signals(false)

#

# warning-ignore:unused_argument
func _on_octave_changed(oct:int)->void:
	var oc:SpinBox=$GC/Octave
	oc.set_block_signals(true)
	oc.value=GLOBALS.curr_octave-1
	oc.set_block_signals(false)

func _on_Octave_value_changed(value:float)->void:
	GLOBALS.curr_octave=int(value)+1

func _on_TicksSec_value_changed(value:float)->void:
	GLOBALS.song.set_ticks_second(value)

func _on_TicksRow_value_changed(value:float)->void:
	GLOBALS.song.set_ticks_row(value)

func _on_Step_value_changed(value:float)->void:
	emit_signal("step_changed",int(value))

func _on_Velocity_value_changed(value:float)->void:
	emit_signal("velocity_changed",clamp(value,0.0,255.0))

func _on_RowsPat_value_changed(value:float)->void:
	GLOBALS.song.set_pattern_length(value)

func _on_Channels_value_changed(value:float)->void:
	GLOBALS.song.set_num_channels(value)
