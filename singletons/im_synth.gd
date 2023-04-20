extends Synth

var notes_on:Array
var channel:int=0
var poly:bool=true

#

func _init():
	notes_on=[]
	notes_on.resize(MAX_CHANNELS)
	for i in MAX_CHANNELS:
		notes_on[i]=-1

func play_note(keyon:bool,legato:bool,semi:int)->void:
	var instr:Instrument=GLOBALS.get_instrument()
	if keyon:
		if poly:
			channel=(channel+1)&31
		notes_on[channel]=semi
		if instr is FmInstrument:
			IM_SYNTH.set_fm_instrument(channel,instr)
			IM_SYNTH.play_fm_note(channel,instr,semi,legato)
	else:
		for i in MAX_CHANNELS:
			if notes_on[i]!=semi:
				continue
			notes_on[i]=-1
			if instr is FmInstrument:
				IM_SYNTH.synth.key_off(i,15)

#

func play_fm_note(chan:int,instr:FmInstrument,semi:int,legato:bool)->void:
	var semitone:int=semi*100
	synth.set_note(chan,instr.op_mask,semitone)
	synth.set_enable(chan,15,instr.op_mask)
	synth.set_panning(chan,31,false,false)
	synth.key_on(chan,instr.op_mask,255,legato)
