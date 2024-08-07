extends Node

signal step_changed(delta)

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
const OCTAVE_UP=[KEY_KP_MULTIPLY]
const OCTAVE_DOWN=[KEY_KP_DIVIDE]
const INSTRUMENT_UP=[KEY_KP_MULTIPLY|KEY_MASK_SHIFT]
const INSTRUMENT_DOWN=[KEY_KP_DIVIDE|KEY_MASK_SHIFT]
const STEP_UP=[KEY_KP_MULTIPLY|KEY_MASK_CTRL]
const STEP_DOWN=[KEY_KP_DIVIDE|KEY_MASK_CTRL]
const UP=KEY_UP
const DOWN=KEY_DOWN
const STEP=KEY_SPACE
const LEFT=KEY_LEFT
const RIGHT=KEY_RIGHT
const FAST_UP=KEY_PAGEUP
const FAST_DOWN=KEY_PAGEDOWN
const HOME=KEY_HOME
const END=KEY_END
const CLEAR=KEY_DELETE
const INTERPOLATE=KEY_I|KEY_MASK_CTRL
const INSERT=KEY_INSERT
const DELETE=KEY_DELETE|KEY_MASK_SHIFT
const VALUE_UP=[KEY_KP_ADD,KEY_VOLUMEUP]
const VALUE_DOWN=[KEY_KP_SUBTRACT,KEY_VOLUMEDOWN]
const COPY=[KEY_C|KEY_MASK_CTRL,KEY_C|KEY_MASK_CMD]
const CUT=[KEY_X|KEY_MASK_CTRL,KEY_X|KEY_MASK_CMD]
const PASTE=[KEY_V|KEY_MASK_CTRL,KEY_V|KEY_MASK_CMD]
const MIX_PASTE=[KEY_V|KEY_MASK_SHIFT|KEY_MASK_CTRL,KEY_V|KEY_MASK_SHIFT|KEY_MASK_CMD]
const DUPLICATE_ENTERED=[KEY_ENTER,KEY_KP_ENTER]
const DUPLICATE_LAST=[KEY_ENTER|KEY_MASK_SHIFT,KEY_KP_ENTER|KEY_MASK_SHIFT]
const SCROLL_LOCK=KEY_SCROLLLOCK
const PLAY_ALL=KEY_F5
const PLAY_TRACK=KEY_F6
const OSCILLOSCOPE_TOGGLE=KEY_F4


var notes_on:Array=[]
#var channel:int=-1


func _ready()->void:
	GLOBALS.array_fill(notes_on,-1,SongLimits.MAX_CHANNELS)

func _unhandled_input(event:InputEvent)->void:
	if handle_keys(event as InputEventKey):
		get_tree().set_input_as_handled()
	elif handle_midi(event as InputEventMIDI):
		get_tree().set_input_as_handled()

func handle_midi(event:InputEventMIDI)->bool:
	if event==null:
		return false
	if event.message==MIDI_MESSAGE_NOTE_ON:
		if event.velocity>0:
			IM_SYNTH.play_note(true,false,event.pitch)
		else:
			IM_SYNTH.play_note(false,false,event.pitch)
	elif event.message==MIDI_MESSAGE_NOTE_OFF:
		IM_SYNTH.play_note(false,false,event.pitch)
	else:
		print("CH:%d MS:%d PI:%d VE:%d IN:%d PR:%d CN:%d CV:%d"%[event.channel,event.message,event.pitch,event.velocity,event.instrument,event.pressure,event.controller_number,event.controller_value])
	return true

func handle_keys(event:InputEventKey)->bool:
	if event==null or event.is_echo():
		return false
	var fscan:int=event.get_scancode_with_modifiers()
	if (event.scancode) in KEYBOARD:
		IM_SYNTH.play_note(event.pressed,
				event.shift,
				KEYBOARD.find(event.scancode)+(GLOBALS.curr_octave*12)
			)
		return true
	if fscan in OCTAVE_UP:
		if !event.pressed:
			GLOBALS.curr_octave+=1
		return true
	elif fscan in OCTAVE_DOWN:
		if !event.pressed:
			GLOBALS.curr_octave-=1
		return true
	elif fscan in INSTRUMENT_UP:
		if !event.pressed:
			GLOBALS.set_instrument(GLOBALS.curr_instrument+1)
		return true
	elif fscan in INSTRUMENT_DOWN:
		if !event.pressed:
			GLOBALS.set_instrument(GLOBALS.curr_instrument-1)
		return true
	elif fscan in STEP_UP:
		if !event.pressed:
			emit_signal("step_changed",1)
		return true
	elif fscan in STEP_DOWN:
		if !event.pressed:
			emit_signal("step_changed",-1)
		return true
	return false

#

func _on_FmEditor_instrument_changed()->void:
	pass
	"""DEBUG.set_var("CHN",String(channel))
	if channel!=-1:
		SYNCER.set_fm_instrument(channel,GLOBALS.get_instrument())"""
