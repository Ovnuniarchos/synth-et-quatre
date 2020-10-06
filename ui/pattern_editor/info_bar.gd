extends HBoxContainer


func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	GLOBALS.connect("octave_changed",self,"_on_octave_changed")
	GLOBALS.connect("instrument_changed",self,"_on_instrument_changed")
	_on_song_changed()

func _on_song_changed()->void:
	$Octave.text="Octave: %-2d"%[GLOBALS.curr_octave-1]
	$Step.text="Step: %-3d"%[1] # From editor
	$Velocity.text="Velocity: %-3d"%[1] # From editor
	$Tempo.text="Tempo: %-3.2f rows/s"%[GLOBALS.song.ticks_second/float(GLOBALS.song.ticks_row)]
	$Instrument.text="Instrument: %s"%[GLOBALS.get_instrument_name()]
	GLOBALS.song.connect("speed_changed",self,"_on_speed_changed")

func _on_octave_changed(o:int)->void:
	$Octave.text="Octave %2d"%[o-1]

func _on_Info_step_changed(step:int)->void:
	$Step.text="Step: %-3d"%[step]

func _on_speed_changed()->void:
	$Tempo.text="Tempo: %-3.2f rows/s"%[GLOBALS.song.ticks_second/float(GLOBALS.song.ticks_row)]

func _on_step_changed(step:int)->void:
	$Step.text="Step: %-3d"%[step]

func _on_velocity_changed(velocity:int)->void:
	$Velocity.text="Velocity: %-3d"%[velocity]

func _on_instrument_changed(_inst:int,inst_name:String)->void:
	$Instrument.text="Instrument: %s"%[inst_name]
