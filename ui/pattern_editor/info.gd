extends PanelContainer

signal step_changed(step)

func _ready()->void:
	GKBD.connect("octave_changed",self,"_on_octave_changed")
	sync_with_song()
	$GC/Step.value=1

func sync_with_song()->void:
	set_block_signals(true)
	$GC/Octave.value=GLOBALS.curr_octave-1
	$GC/TicksSec.value=GLOBALS.song.ticks_second
	$GC/TicksRow.value=GLOBALS.song.ticks_row
	set_block_signals(false)

#

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
