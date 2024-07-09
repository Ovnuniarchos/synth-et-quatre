extends PanelContainer


signal step_changed(step)
signal velocity_changed(velocity)
signal pan_changed(pan)
signal invert_changed(invl,invr)


func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	GLOBALS.connect("octave_changed",self,"_on_octave_changed")
	_on_song_changed()
	$SC/VBC/GC/Step.value=1


func _on_song_changed()->void:
	set_block_signals(true)
	$SC/VBC/Author.text=GLOBALS.song.author
	$SC/VBC/Title.text=GLOBALS.song.title
	$SC/VBC/GC/Octave.value=GLOBALS.curr_octave-1
	$SC/VBC/GC/TicksSec.value=GLOBALS.song.ticks_second
	$SC/VBC/GC/TicksRow.value=GLOBALS.song.ticks_row
	$SC/VBC/GC/RowsPat.value=GLOBALS.song.pattern_length
	$SC/VBC/GC/Channels.value=GLOBALS.song.num_channels
	$SC/VBC/GC/MinHlite.value=GLOBALS.song.minor_highlight
	$SC/VBC/GC/MajHlite.value=GLOBALS.song.major_highlight
	set_block_signals(false)


#


func _on_octave_changed(_oct:int)->void:
	$SC/VBC/GC/Octave.value=GLOBALS.curr_octave-1


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
	$SC/VBC/GC/MinHlite.max_value=value
	$SC/VBC/GC/MajHlite.max_value=value


func _on_Channels_value_changed(value:float)->void:
	GLOBALS.song.set_num_channels(value)


func _on_Title_text_changed(t:String)->void:
	GLOBALS.song.set_title(t)


func _on_Author_text_changed(t:String)->void:
	GLOBALS.song.set_author(t)


func _on_Editor_step_changed(step:int)->void:
	$SC/VBC/GC/Step.value=step


func _on_Editor_pan_changed(pan:int)->void:
	$SC/VBC/GC/Pan.value=pan


func _on_Editor_invert_changed(invl:bool,invr:bool)->void:
	$SC/VBC/GC/InvertLeft.pressed=invl
	$SC/VBC/GC/InvertRight.pressed=invr


func _on_MinHlite_value_changed(value:int)->void:
	GLOBALS.song.set_minor_highlight(value)


func _on_MajHlite_value_changed(value:int)->void:
	GLOBALS.song.set_major_highlight(value)


func _on_slider_focus_exited()->void:
	emit_signal("focus_exited")


func _on_text_entered(_new_text:String)->void:
	emit_signal("focus_exited")


func _on_InvertLeft_toggled(_p:bool)->void:
	emit_signal("invert_changed",$SC/VBC/GC/InvertLeft.pressed,$SC/VBC/GC/InvertRight.pressed)


func _on_InvertRight_toggled(_p:bool)->void:
	emit_signal("invert_changed",$SC/VBC/GC/InvertLeft.pressed,$SC/VBC/GC/InvertRight.pressed)


func _on_Pan_value_changed(value:int)->void:
	emit_signal("pan_changed",value)
