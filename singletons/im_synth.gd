extends Synth


#

func play_fm_note(channel:int,instr:FmInstrument,semi:int,legato:bool)->void:
	var semitone:int=semi*100
	synth.set_note(channel,instr.op_mask,semitone)
	synth.set_enable(channel,15,instr.op_mask)
	synth.set_panning(channel,31,false,false)
	synth.key_on(channel,instr.op_mask,255,legato)
