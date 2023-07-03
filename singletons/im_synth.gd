extends Synth

enum {MONO,SEMI,POLY}

var notes_on:Array
var notes:Array
var instruments:Array
var timers:Array
var channel:int=0
var poly:int=POLY
var ti:int

#

func _init()->void:
	notes_on=Array()
	notes=Array()
	instruments=Array()
	for i in MAX_CHANNELS:
		instruments.append(null)
		notes.append(-1)
		notes_on.append(-1)
		timers.append(0)

func _ready()->void:
	var tmr:Timer=Timer.new()
	tmr.wait_time=0.004
	tmr.connect("timeout",self,"_on_tmr")
	add_child(tmr)
	ti=Time.get_ticks_msec()
	tmr.start()

func _on_tmr()->void:
	var delta:int=Time.get_ticks_msec()-ti
	ti=Time.get_ticks_msec()

func find_channel(semi:int)->int:
	if poly==POLY:
		return (channel+1)&31
	elif poly==SEMI:
		for i in MAX_CHANNELS:
			if notes[i]==semi:
				return i
		return (channel+1)&31
	return channel

func play_note(keyon:bool,legato:bool,semi:int)->void:
	semi*=100
	var instr:Instrument=GLOBALS.get_instrument()
	if keyon:
		channel=find_channel(semi)
		notes_on[channel]=semi
		notes[channel]=semi
		instruments[channel]=GLOBALS.curr_instrument
		if instr is FmInstrument:
			set_fm_instrument(channel,instr)
			play_fm_note(channel,instr,semi,legato)
	else:
		for i in MAX_CHANNELS:
			if notes_on[i]!=semi:
				continue
			notes_on[i]=-1
			if instr is FmInstrument:
				synth.key_off(i,15)

#

func play_fm_note(chan:int,instr:FmInstrument,semi:int,legato:bool)->void:
	#var semitone:int=semi*100
	synth.set_note(chan,instr.op_mask,semi)
	synth.set_enable(chan,15,instr.op_mask)
	synth.set_panning(chan,31,false,false)
	synth.key_on(chan,instr.op_mask,255,legato)

#

func set_freq_mul(op:int,multiplier:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_freq_mul(i,op_mask,multiplier)

func set_freq_div(op:int,divider:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_freq_div(i,op_mask,divider)

func set_detune(op:int,millis:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_detune(i,op_mask,millis)

func set_wave(op:int,ix:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_wave(i,op_mask,ix)

func set_duty_cycle(op:int,duc:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	duc<<=16
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_duty_cycle(i,op_mask,duc)

func set_attack_rate(op:int,ar:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_attack_rate(i,op_mask,ar)

func set_decay_rate(op:int,dr:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_decay_rate(i,op_mask,dr)

func set_sustain_level(op:int,sl:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_sustain_level(i,op_mask,sl)

func set_sustain_rate(op:int,sr:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_sustain_rate(i,op_mask,sr)

func set_release_rate(op:int,rr:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_release_rate(i,op_mask,rr)

func set_repeat(op:int,phase:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_repeat(i,op_mask,phase)

func set_ksr(op:int,ksr:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_ksr(i,op_mask,ksr)

func set_am_intensity(op:int,intensity:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_am_intensity(i,op_mask,intensity)

func set_am_lfo(op:int,ix:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_am_lfo(i,op_mask,ix)

func set_fm_intensity(op:int,millis:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_fm_intensity(i,op_mask,millis)

func set_fm_lfo(op:int,ix:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_fm_lfo(i,op_mask,ix)

func set_enable(opmask:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_enable(i,15,opmask)

func set_clip(clip:bool)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_clip(i,clip)

func set_pm_factor(from_op:int,to_op:int,pm_factor:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_pm_factor(i,from_op,to_op,pm_factor)

func set_output(op:int,output:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument() as FmInstrument
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instruments[i]==GLOBALS.curr_instrument:
			synth.set_output(i,op_mask,output)
"""
//void SynthTracker::set_freq_mul(int voice,int op_mask,int multiplier)
//void SynthTracker::set_freq_div(int voice,int op_mask,int divider)
//void SynthTracker::set_detune(int voice,int op_mask,int millis)
//void SynthTracker::set_wave(int voice,int op_mask,int wave_num)
//void SynthTracker::set_duty_cycle(int voice,int op_mask,FixedPoint duty_cycle)
//void SynthTracker::set_phase(int voice,int op_mask,FixedPoint phi)
//void SynthTracker::set_volume(int voice,int vel)
//void SynthTracker::set_attack_rate(int voice,int op_mask,int rate)
//void SynthTracker::set_decay_rate(int voice,int op_mask,int rate)
//void SynthTracker::set_sustain_level(int voice,int op_mask,int level)
//void SynthTracker::set_sustain_rate(int voice,int op_mask,int rate)
//void SynthTracker::set_release_rate(int voice,int op_mask,int rate)
//void SynthTracker::set_repeat(int voice,int op_mask,int phase)
//void SynthTracker::set_ksr(int voice,int op_mask,int ksr)
//void SynthTracker::set_am_intensity(int voice,int op_mask,int intensity)
//void SynthTracker::set_am_lfo(int voice,int op_mask,int lfo)
//void SynthTracker::set_fm_intensity(int voice,int op_mask,int millis)
//void SynthTracker::set_fm_lfo(int voice,int op_mask,int lfo)
//void SynthTracker::key_on(int voice,int op_mask,int velocity,bool legato)
//void SynthTracker::key_off(int voice,int op_mask)
//void SynthTracker::stop(int voice,int op_mask)
//void SynthTracker::set_enable(int voice,int op_mask,int enable_bits)
//void SynthTracker::set_clip(int voice,bool clip)
//void SynthTracker::set_pm_factor(int voice,int op_from,int op_to,int pm_factor)
//void SynthTracker::set_output(int voice,int op_mask,int volume)
//void SynthTracker::set_panning(int voice,int panning,bool invert_left,bool invert_right)
// void SynthTracker::set_lfo_phase(int lfo,FixedPoint phi)
//void SynthTracker::mute_voices(int mute_mask)
"""
