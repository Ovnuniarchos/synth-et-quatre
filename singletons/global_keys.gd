extends Node

signal octave_changed(oct)

const KEYBOARD=[
	KEY_Z,KEY_S,KEY_X,KEY_D,KEY_C,KEY_V,KEY_G,KEY_B,KEY_H,KEY_N,KEY_J,KEY_M,
	KEY_Q,KEY_2,KEY_W,KEY_3,KEY_E,KEY_R,KEY_5,KEY_T,KEY_6,KEY_Y,KEY_7,KEY_U
]
const HEX_INPUT=[
	KEY_0,KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,
	KEY_8,KEY_9,KEY_A,KEY_B,KEY_C,KEY_D,KEY_E,KEY_F
]
const HEX_INPUT_KP=[
	KEY_KP_0,KEY_KP_1,KEY_KP_2,KEY_KP_3,KEY_KP_4,KEY_KP_5,KEY_KP_6,KEY_KP_7,
	KEY_KP_8,KEY_KP_9,KEY_A,KEY_B,KEY_C,KEY_D,KEY_E,KEY_F
]
const NOTE_OFF=KEY_BACKSPACE
const OCTAVE_UP=[KEY_KP_DIVIDE]
const OCTAVE_DOWN=[KEY_KP_MULTIPLY]
const UP=KEY_UP
const DOWN=KEY_DOWN
const LEFT=KEY_LEFT
const RIGHT=KEY_RIGHT
const FAST_UP=KEY_PAGEUP
const FAST_DOWN=KEY_PAGEDOWN
const HOME=KEY_HOME
const END=KEY_END
const CLEAR=KEY_DELETE
const INSERT=KEY_INSERT
const DELETE=KEY_DELETE|KEY_MASK_SHIFT
const VALUE_UP=[KEY_KP_ADD,KEY_VOLUMEUP]
const VALUE_DOWN=[KEY_KP_SUBTRACT,KEY_VOLUMEDOWN]
const COPY=[KEY_C|KEY_MASK_CTRL,KEY_C|KEY_MASK_CMD]
const CUT=[KEY_X|KEY_MASK_CTRL,KEY_X|KEY_MASK_CMD]
const PASTE=[KEY_V|KEY_MASK_CTRL,KEY_V|KEY_MASK_CMD]
const MIX_PASTE=[KEY_V|KEY_MASK_SHIFT|KEY_MASK_CTRL,KEY_V|KEY_MASK_SHIFT|KEY_MASK_CMD]
const DUPLICATE=[KEY_ENTER,KEY_KP_ENTER]


var notes_on:Array=[]
var channel:int=-1


func _ready()->void:
	GLOBALS.array_fill(notes_on,-1,Song.MAX_CHANNELS)

func _unhandled_input(event:InputEvent)->void:
	if handle_keys(event as InputEventKey):
		get_tree().set_input_as_handled()
	elif handle_midi(event as InputEventMIDI):
		get_tree().set_input_as_handled()

func handle_midi(event:InputEventMIDI)->bool:
	if event==null:
		return false
	if event.message==MIDI_MESSAGE_NOTE_ON:
		play_note(true,false,event.pitch)
	elif event.message==MIDI_MESSAGE_NOTE_OFF:
		play_note(false,false,event.pitch)
	else:
		print("CH:%d MS:%d PI:%d VE:%d IN:%d PR:%d CN:%d CV:%d"%[event.channel,event.message,event.pitch,event.velocity,event.instrument,event.pressure,event.controller_number,event.controller_value])
	return true

func handle_keys(event:InputEventKey)->bool:
	if event==null or event.is_echo():
		return false
	var fscan:int=event.get_scancode_with_modifiers()
	if (fscan&~KEY_MASK_SHIFT) in KEYBOARD:
		play_note(event.pressed,
				event.shift,
				KEYBOARD.find(event.scancode)+(GLOBALS.curr_octave*12)
			)
		return true
	if fscan in OCTAVE_UP:
		if !event.pressed:
			GLOBALS.curr_octave+=1
			emit_signal("octave_changed",GLOBALS.curr_octave)
		return true
	if fscan in OCTAVE_DOWN:
		if !event.pressed:
			GLOBALS.curr_octave-=1
			emit_signal("octave_changed",GLOBALS.curr_octave)
		return true
	return false

func play_note(keyon:bool,legato:bool,semi:int,chan:int=-1)->void:
	if SYNTH.mute_mask&0xFFFFFFFF==0xFFFFFFFF:
		return
	var instr:Instrument=GLOBALS.get_instrument()
	if keyon:
		if chan==-1:
			channel=(channel+1)&31
			var bailout:int=0
			while SYNTH.mute_mask&(1<<channel)!=0 and bailout<32:
				channel=(channel+1)&31
				bailout+=1
			chan=channel
		notes_on[chan]=semi
		if instr is FmInstrument:
			SYNTH.set_fm_instrument(chan,instr)
			SYNTH.play_fm_note(chan,instr,semi,legato)
	else:
		for i in range(Song.MAX_CHANNELS):
			if notes_on[i]!=semi:
				continue
			notes_on[i]=-1
			if instr is FmInstrument:
				SYNTH.synth.key_off(i,15)

#

func _on_FmEditor_instrument_changed()->void:
	if channel!=-1:
		SYNTH.set_fm_instrument(channel,GLOBALS.get_instrument())
