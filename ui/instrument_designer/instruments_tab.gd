extends Tabs

var notes:Array=[]
var key_on:Array=[]
var last_channel:int=-1

func _ready()->void:
	GLOBALS.connect("song_changed",self,"_on_song_changed")
	update_instrument()
	GLOBALS.array_fill(notes,-1,32)
	GLOBALS.array_fill(key_on,false,32)

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

#

func _unhandled_input(event:InputEvent)->void:
	if handle_keys(event as InputEventKey):
		accept_event()

func handle_keys(event:InputEventKey)->bool:
	if event==null or event.is_echo():
		return false
	if event.scancode in GLOBALS.KEYBOARD:
		var semi:int=GLOBALS.KEYBOARD.find(event.scancode)+(GLOBALS.curr_octave*12)
		var chan:int=notes.find(semi)
		var instr:Instrument=GLOBALS.get_instrument()
		if event.pressed:
			if chan==-1:
				chan=notes.find(-1)
				if chan==-1:
					chan=0
			if last_channel==-1:
				last_channel=chan
			elif event.shift:
				chan=last_channel
			key_on[chan]=true
			notes[chan]=semi
			last_channel=chan
			if instr is FmInstrument:
				SYNTH.set_fm_instrument(chan,instr)
				SYNTH.play_fm_note(chan,instr,semi,event.shift)
		elif chan!=-1:
			key_on[chan]=false
			if instr is FmInstrument:
				SYNTH.synth.key_off(chan,15)
		return true
	return false

#

func _on_FmEditor_instrument_changed():
	if last_channel!=-1:
		SYNTH.set_fm_instrument(last_channel,GLOBALS.get_instrument())
