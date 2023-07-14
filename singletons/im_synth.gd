extends Synth

enum {MONO,SEMI,POLY}

var notes_on:Array=Array()
var notes:Array=Array()
var volumes:Array=Array()
var panpots:Array=Array()
var channel_invs:Array=Array()
var clips:Array=Array()
var instr_ids:Array=Array()
var kon_time:Array=Array()
var koff_time:Array=Array()
var channel:int=0
var poly:int=POLY
var ti:int=-1

#

func _init()->void:
	for i in MAX_CHANNELS:
		notes_on.append(-1)
		notes.append(-1)
		volumes.append(0)
		panpots.append(0)
		channel_invs.append(0)
		clips.append(0)
		instr_ids.append(-1)
		kon_time.append(-1)
		koff_time.append(-1)

func _ready()->void:
	var tmr:Timer=Timer.new()
	tmr.wait_time=0.004
	tmr.connect("timeout",self,"_on_macro_timer")
	add_child(tmr)
	ti=Time.get_ticks_msec()
	tmr.start()

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
		instr_ids[channel]=GLOBALS.curr_instrument
		if instr is FmInstrument:
			set_fm_instrument(channel,instr)
			play_fm_note(channel,instr,semi,legato)
	else:
		for i in MAX_CHANNELS:
			if notes_on[i]!=semi:
				continue
			notes_on[i]=-1
			koff_time[i]=kon_time[i]
			if GLOBALS.get_instrument(instr_ids[i]) is FmInstrument:
				synth.key_off(i,15)

#

func play_fm_note(chan:int,instr:FmInstrument,semi:int,legato:bool)->void:
	# semitone = semi / 100
	synth.set_note(chan,instr.op_mask,semi)
	synth.set_enable(chan,15,instr.op_mask)
	synth.set_panning(chan,31,false,false)
	synth.key_on(chan,instr.op_mask,255,legato)
	volumes[chan]=255
	panpots[chan]=31
	channel_invs[chan]=0
	clips[chan]=int(instr.clip)
	if !legato:
		kon_time[chan]=0
		koff_time[chan]=-1

#

func _on_macro_timer()->void:
	if ti<0:
		ti=Time.get_ticks_msec()
		return
	ti=Time.get_ticks_msec()-ti
	var instr:FmInstrument
	var val:int
	var val_b:int
	var kot:int
	var kft:int
	for chan in MAX_CHANNELS:
		if notes[chan]==-1 or instr_ids[chan]==-1:
			continue
		instr=GLOBALS.get_instrument(instr_ids[chan]) as FmInstrument
		if instr==null:
			continue
		kon_time[chan]+=ti
		kot=(kon_time[chan]*GLOBALS.song.ticks_second)/1000
		kft=(koff_time[chan]*GLOBALS.song.ticks_second)/1000 if koff_time[chan]>-1 else -1
		# Global tone
		for i in 4:
			val=instr.freq_macro.get_value(kot,kft,notes[chan])
			synth.set_note(chan,1<<i,val)
		# Global volume
		val=instr.volume_macro.get_value(kot,kft,volumes[chan])
		synth.set_volume(chan,val)
		# Panpot
		val=instr.pan_macro.get_value(kot,kft,panpots[chan])
		val_b=instr.chanl_invert_macro.get_value(kot,kft,channel_invs[chan])
		synth.set_panning(chan,val,bool(val_b&1),bool(val_b&2))
		# Clip
		val=instr.pan_macro.get_value(kot,kft,clips[chan])
		synth.set_clip(chan,bool(val))
	ti=Time.get_ticks_msec()

#

func set_freq_mul(op:int,multiplier:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_freq_mul(i,op_mask,multiplier)

func set_freq_div(op:int,divider:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_freq_div(i,op_mask,divider)

func set_detune(op:int,millis:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_detune(i,op_mask,millis)

func set_wave(op:int,ix:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_wave(i,op_mask,ix)

func set_duty_cycle(op:int,duc:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	duc<<=16
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_duty_cycle(i,op_mask,duc)

func set_attack_rate(op:int,ar:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_attack_rate(i,op_mask,ar)

func set_decay_rate(op:int,dr:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_decay_rate(i,op_mask,dr)

func set_sustain_level(op:int,sl:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_sustain_level(i,op_mask,sl)

func set_sustain_rate(op:int,sr:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_sustain_rate(i,op_mask,sr)

func set_release_rate(op:int,rr:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_release_rate(i,op_mask,rr)

func set_repeat(op:int,phase:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_repeat(i,op_mask,phase)

func set_ksr(op:int,ksr:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_ksr(i,op_mask,ksr)

func set_am_intensity(op:int,intensity:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_am_intensity(i,op_mask,intensity)

func set_am_lfo(op:int,ix:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_am_lfo(i,op_mask,ix)

func set_fm_intensity(op:int,millis:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_fm_intensity(i,op_mask,millis)

func set_fm_lfo(op:int,ix:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_fm_lfo(i,op_mask,ix)

func set_enable(opmask:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_enable(i,15,opmask)

func set_clip(clip:bool)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			clips[i]=int(clip)
			synth.set_clip(i,clip)

func set_pm_factor(from_op:int,to_op:int,pm_factor:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_pm_factor(i,from_op,to_op,pm_factor)

func set_output(op:int,output:int)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			synth.set_output(i,op_mask,output)
"""
//void SynthTracker::set_phase(int voice,int op_mask,FixedPoint phi)
//void SynthTracker::set_volume(int voice,int vel)
//void SynthTracker::key_on(int voice,int op_mask,int velocity,bool legato)
//void SynthTracker::key_off(int voice,int op_mask)
//void SynthTracker::stop(int voice,int op_mask)
//void SynthTracker::set_panning(int voice,int panning,bool invert_left,bool invert_right)
// void SynthTracker::set_lfo_phase(int lfo,FixedPoint phi)
//void SynthTracker::mute_voices(int mute_mask)
"""
