extends Synth

var notes_on:Array=[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
var notes:Array=[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
var instruments:Array=[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
var channel:int=0
var poly:int=2

#

func find_channel(semi:int)->int:
	if poly==2:
		return (channel+1)&31
	elif poly==1:
		for i in MAX_CHANNELS:
			if notes[i]==semi:
				return i
		return (channel+1)&31
	return channel

func play_note(keyon:bool,legato:bool,semi:int)->void:
	var instr:Instrument=GLOBALS.get_instrument()
	if keyon:
		channel=find_channel(semi)
		notes_on[channel]=semi
		notes[channel]=semi
		instruments[channel]=GLOBALS.curr_instrument
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

"""
void SynthTracker::set_freq_mul(int voice,int op_mask,int multiplier)
void SynthTracker::set_freq_div(int voice,int op_mask,int divider)
void SynthTracker::set_detune(int voice,int op_mask,int millis)
void SynthTracker::set_wave(int voice,int op_mask,int wave_num)
void SynthTracker::set_duty_cycle(int voice,int op_mask,FixedPoint duty_cycle)
void SynthTracker::set_phase(int voice,int op_mask,FixedPoint phi)
void SynthTracker::define_wave(int wave_num,Array wave)
void SynthTracker::define_sample(int wave_num,int loop_start,int loop_end,float rec_freq,float sam_freq,Array sample)
void SynthTracker::set_volume(int voice,int vel)
void SynthTracker::set_attack_rate(int voice,int op_mask,int rate)
void SynthTracker::set_decay_rate(int voice,int op_mask,int rate)
void SynthTracker::set_sustain_level(int voice,int op_mask,int level)
void SynthTracker::set_sustain_rate(int voice,int op_mask,int rate)
void SynthTracker::set_release_rate(int voice,int op_mask,int rate)
void SynthTracker::set_repeat(int voice,int op_mask,int phase)
void SynthTracker::set_ksr(int voice,int op_mask,int ksr)
void SynthTracker::set_am_intensity(int voice,int op_mask,int intensity)
void SynthTracker::set_am_lfo(int voice,int op_mask,int lfo)
void SynthTracker::set_fm_intensity(int voice,int op_mask,int millis)
void SynthTracker::set_fm_lfo(int voice,int op_mask,int lfo)
void SynthTracker::key_on(int voice,int op_mask,int velocity,bool legato)
void SynthTracker::key_off(int voice,int op_mask)
void SynthTracker::stop(int voice,int op_mask)
void SynthTracker::set_enable(int voice,int op_mask,int enable_bits)
void SynthTracker::set_clip(int voice,bool clip)
void SynthTracker::set_pm_factor(int voice,int op_from,int op_to,int pm_factor)
void SynthTracker::set_output(int voice,int op_mask,int volume)
void SynthTracker::set_panning(int voice,int panning,bool invert_left,bool invert_right)
// void SynthTracker::set_lfo_phase(int lfo,FixedPoint phi)
void SynthTracker::mute_voices(int mute_mask)
"""
