extends HBoxContainer


func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	GLOBALS.connect("octave_changed",self,"_on_octave_changed")
	_on_song_changed()

func _on_song_changed()->void:
	$Octave.text="Octave: %-2d"%[GLOBALS.curr_octave-1]
	$Step.text="Step: %-3d"%[1] # From editor
	$Velocity.text="Velocity: %-3d"%[1] # From editor
	$Tempo.text="Tempo: %-3.2f rows/s"%[GLOBALS.song.ticks_second/float(GLOBALS.song.ticks_row)]
	$Instrument.text="Instrument: %s"%[GLOBALS.get_instrument_name()]

func _on_octave_changed(o:int)->void:
	$Octave.text="Octave %2d"%[o-1]

func _on_Info_step_changed(step:int)->void:
	$Step.text="Step: %-3d"%[step]
