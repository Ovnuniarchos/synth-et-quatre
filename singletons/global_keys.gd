extends Node

const KEYBOARD=[
	KEY_Z,KEY_S,KEY_X,KEY_D,KEY_C,KEY_V,KEY_G,KEY_B,KEY_H,KEY_N,KEY_J,KEY_M,
	KEY_Q,KEY_2,KEY_W,KEY_3,KEY_E,KEY_R,KEY_5,KEY_T,KEY_6,KEY_Y,KEY_7,KEY_U
]

const HEX_INPUT=[
	KEY_0,KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,
	KEY_8,KEY_9,KEY_A,KEY_B,KEY_C,KEY_D,KEY_E,KEY_F
]

var notes:Array=[]
var key_on:Array=[]
var last_channel:int=-1


func _ready():
	GLOBALS.array_fill(notes,-1,32)
	GLOBALS.array_fill(key_on,false,32)

#

func _unhandled_input(event:InputEvent)->void:
	if handle_keys(event as InputEventKey):
		get_tree().set_input_as_handled()

func handle_keys(event:InputEventKey)->bool:
	if event==null or event.is_echo():
		return false
	if event.scancode in KEYBOARD:
		var semi:int=KEYBOARD.find(event.scancode)+(GLOBALS.curr_octave*12)
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
