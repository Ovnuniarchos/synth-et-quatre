extends HBoxContainer


func _ready()->void:
	add_constant_override("separation",get_font("font").get_height()*2)
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	GLOBALS.connect("octave_changed",self,"_on_octave_changed")
	GLOBALS.connect("instrument_changed",self,"_on_instrument_changed")
	_on_song_changed()

func _on_song_changed()->void:
	_on_octave_changed(GLOBALS.curr_octave)
	_on_step_changed(1)
	_on_velocity_changed(128)
	_on_speed_changed()
	_on_instrument_changed(GLOBALS.curr_instrument,GLOBALS.get_instrument_name())
	GLOBALS.song.connect("speed_changed",self,"_on_speed_changed")

func _on_octave_changed(o:int)->void:
	$Octave.text=tr("IBAR_OCTAVE").format({"i_oct":"%-2d"%[o-1]})

func _on_speed_changed()->void:
	$Tempo.text=tr("IBAR_TEMPO").format({"f_tempo":"%-3.2f"%[GLOBALS.song.ticks_second/float(GLOBALS.song.ticks_row)]})

func _on_step_changed(step:int)->void:
	$Step.text=tr("IBAR_STEP").format({"i_step":"%-3d"%[step]})

func _on_velocity_changed(velocity:int)->void:
	$Velocity.text=tr("IBAR_VELOCITY").format({"i_vel":"%-3d"%[velocity]})

func _on_instrument_changed(inst:int,inst_name:String)->void:
	$Instrument.text=tr("IBAR_INSTRUMENT").format({"s_inst":inst_name,"i_inst":"%02X"%inst})
