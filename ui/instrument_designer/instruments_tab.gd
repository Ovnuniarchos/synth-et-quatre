extends Tabs

func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	update_instrument()

func _on_song_changed()->void:
	update_instrument()

func update_instrument()->void:
	var ci:Instrument=GLOBALS.get_instrument()
	if ci==null:
		return
	if ci is FmInstrument:
		$Cols/FmEditor.update_instrument()

func _on_instrument_selected(index:int)->void:
	GLOBALS.curr_instrument=index
	update_instrument()
