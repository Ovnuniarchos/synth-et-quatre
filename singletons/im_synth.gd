extends Synth

enum {MONO,SEMI,POLY}

var notes_on:Array=Array()
var notes:Array=Array()
var volumes:Array=Array()
var panpots:Array=Array()
var channel_invs:Array=Array()
#
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
	synth.set_panning(chan,128,false,false)
	synth.key_on(chan,instr.op_mask,255,legato)
	synth.set_enable(chan,15,instr.op_mask)
	volumes[chan]=255
	panpots[chan]=128
	channel_invs[chan]=0
	if !legato:
		kon_time[chan]=0
		koff_time[chan]=-1

#

#TODO: add pre_xxx macros
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
	var mask:int
	for chan in MAX_CHANNELS:
		if notes[chan]==-1 or instr_ids[chan]==-1:
			continue
		instr=GLOBALS.get_instrument(instr_ids[chan]) as FmInstrument
		if instr==null:
			continue
		kon_time[chan]+=ti
		kot=(kon_time[chan]*GLOBALS.song.ticks_second)/1000
		kft=(koff_time[chan]*GLOBALS.song.ticks_second)/1000 if koff_time[chan]>-1 else -1
		# Global+op tone
		val_b=instr.freq_macro.get_value(kot,kft,notes[chan])
		if GLOBALS.curr_arp!=null:
			val_b=GLOBALS.curr_arp.get_value(kot,kft,val_b,GLOBALS.arp_ticks)
		for op in 4:
			val=instr.op_freq_macro[op].get_value(kot,kft,val_b)
			synth.set_note(chan,1<<op,val)
		# Global volume
		val=instr.volume_macro.get_value(kot,kft,volumes[chan])
		synth.set_velocity(chan,val)
		# Global+op key
		val_b=instr.key_macro.get_value(kot,kft,0)
		for op in 4:
			mask=1<<op
			val=instr.op_key_macro[op].get_value(kot,kft,val_b)
			if val==1:
				synth.key_on(chan,mask,volumes[chan],false)
			elif val==2:
				synth.key_on(chan,mask,volumes[chan],true)
			elif val==3:
				synth.stop(chan,mask)
				synth.key_on(chan,mask,volumes[chan],false)
			elif val==4:
				synth.key_off(chan,mask)
			elif val==5:
				synth.stop(chan,mask)
		# Global Op Enable
		val=instr.op_enable_macro.get_value(kot,kft,0)
		synth.set_enable(chan,val>>ParamMacro.MASK_PASSTHROUGH_SHIFT,val&ParamMacro.MASK_VALUE_MASK)
		# Global Panpot
		val=instr.pan_macro.get_value(kot,kft,panpots[chan])
		val_b=instr.chanl_invert_macro.get_value(kot,kft,channel_invs[chan])
		synth.set_panning(chan,val,bool(val_b&1),bool(val_b&2))
		# Global Clip
		val=instr.clip_macro.get_value(kot,kft,instr.clip)
		if val>=ParamMacro.MASK_VALUE_MASK:
			synth.set_clip(chan,bool(val&ParamMacro.MASK_VALUE_MASK))
		else:
			synth.set_clip(chan,instr.clip)
		# Per-op
		for op in 4:
			mask=1<<op
			# Op Duty Cycle
			val=instr.duty_macros[op].get_value(kot,kft,instr.duty_cycles[op])
			synth.set_duty_cycle(chan,mask,val<<16)
			# Op Wave
			val=instr.wave_macros[op].get_value(kot,kft,instr.waveforms[op])
			synth.set_wave(chan,mask,val)
			# Op Attack
			val=instr.attack_macros[op].get_value(kot,kft,instr.attacks[op])
			synth.set_attack_rate(chan,mask,val)
			# Op Decay
			val=instr.decay_macros[op].get_value(kot,kft,instr.decays[op])
			synth.set_decay_rate(chan,mask,val)
			# Op SusLevel
			val=instr.sus_level_macros[op].get_value(kot,kft,instr.sustain_levels[op])
			if val!=instr.sustain_levels[op]:
				synth.set_sustain_level(chan,mask,val)
			# Op SusRate
			val=instr.sus_rate_macros[op].get_value(kot,kft,instr.sustains[op])
			synth.set_sustain_rate(chan,mask,val)
			# Op Release
			val=instr.release_macros[op].get_value(kot,kft,instr.releases[op])
			synth.set_release_rate(chan,mask,val)
			# Op Repeat
			val=instr.repeat_macros[op].get_value(kot,kft,instr.repeats[op])
			synth.set_repeat(chan,mask,val)
			# Op AMI
			val=instr.ami_macros[op].get_value(kot,kft,instr.am_intensity[op])
			synth.set_am_intensity(chan,mask,val)
			# Op KSR
			val=instr.ksr_macros[op].get_value(kot,kft,instr.key_scalers[op])
			synth.set_ksr(chan,mask,val)
			# Op Multiplier
			val=instr.multiplier_macros[op].get_value(kot,kft,instr.multipliers[op])
			synth.set_freq_mul(chan,mask,val)
			# Op Divider
			val=instr.divider_macros[op].get_value(kot,kft,instr.dividers[op])
			synth.set_freq_div(chan,mask,val)
			# Op Detune
			val=instr.detune_macros[op].get_value(kot,kft,instr.detunes[op])
			synth.set_detune(chan,mask,val)
			# Op Detune Mode
			val=instr.detune_mode_macros[op].get_value(kot,kft,instr.detune_modes[op])
			synth.set_detune_mode(chan,mask,val)
			# Op FMI
			val=instr.fmi_macros[op].get_value(kot,kft,instr.fm_intensity[op])
			synth.set_fm_intensity(chan,mask,val)
			# Op AM LFO
			val=instr.am_lfo_macros[op].get_value(kot,kft,instr.am_lfo[op])
			synth.set_am_lfo(chan,mask,val)
			# Op FM LFO
			val=instr.fm_lfo_macros[op].get_value(kot,kft,instr.fm_lfo[op])
			synth.set_fm_lfo(chan,mask,val)
			# Op Phase
			val=instr.phase_macros[op].get_value(kot,kft,ParamMacro.PASSTHROUGH)
			if val!=ParamMacro.PASSTHROUGH:
				if instr.phase_macros[op].relative:
					synth.shift_phase(chan,mask,val<<16)
				else:
					synth.set_phase(chan,mask,val<<16)
			# Op Output
			val=instr.out_macros[op].get_value(kot,kft,instr.routings[op][4])
			synth.set_output(chan,mask,val)
			for op_to in 4:
				# Op OpX
				val=instr.op_macros[op][op_to].get_value(kot,kft,instr.routings[op][op_to])
				synth.set_pm_factor(chan,op,op_to,val)
	ti=Time.get_ticks_msec()

#

func set_param(data:Array,setter:String)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var fn:FuncRef=funcref(synth,setter)
	data.insert(0,0)
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			data[0]=i
			fn.call_funcv(data)

func set_op_param(op:int,data:int,setter:String)->void:
	var inst:FmInstrument=GLOBALS.get_instrument()
	if inst==null:
		return
	var op_mask:int=1<<op
	var fn:FuncRef=funcref(synth,setter)
	for i in MAX_CHANNELS:
		if instr_ids[i]==GLOBALS.curr_instrument:
			fn.call_func(i,op_mask,data)

func set_freq_mul(op:int,multiplier:int)->void:
	set_op_param(op,multiplier,"set_freq_mul")

func set_freq_div(op:int,divider:int)->void:
	set_op_param(op,divider,"set_freq_div")

func set_detune(op:int,millis:int)->void:
	set_op_param(op,millis,"set_detune")

func set_detune_mode(op:int,mode:int)->void:
	set_op_param(op,mode,"mode")

func set_wave(op:int,wave_ix:int)->void:
	set_op_param(op,wave_ix,"set_wave")

func set_duty_cycle(op:int,duty_cycle:int)->void:
	set_op_param(op,duty_cycle,"set_duty_cycle")

func set_pre_attack_rate(op:int,rate:int)->void:
	set_op_param(op,rate,"set_pre_attack_rate")

func set_pre_attack_level(op:int,level:int)->void:
	set_op_param(op,level,"set_pre_attack_level")

func set_attack_rate(op:int,rate:int)->void:
	set_op_param(op,rate,"set_attack_rate")

func set_pre_decay_rate(op:int,rate:int)->void:
	set_op_param(op,rate,"set_pre_decay_rate")

func set_pre_decay_level(op:int,level:int)->void:
	set_op_param(op,level,"set_pre_decay_level")

func set_decay_rate(op:int,rate:int)->void:
	set_op_param(op,rate,"set_decay_rate")

func set_sustain_level(op:int,level:int)->void:
	set_op_param(op,level,"set_sustain_level")

func set_sustain_rate(op:int,rate:int)->void:
	set_op_param(op,rate,"set_sustain_rate")

func set_release_rate(op:int,rate:int)->void:
	set_op_param(op,rate,"set_release_rate")

func set_repeat(op:int,phase:int)->void:
	set_op_param(op,phase,"set_repeat")

func set_ksr(op:int,rate:int)->void:
	set_op_param(op,rate,"set_ksr")

func set_am_intensity(op:int,intensity:int)->void:
	set_op_param(op,intensity,"set_am_intensity")

func set_am_lfo(op:int,lfo_ix:int)->void:
	set_op_param(op,lfo_ix,"set_am_lfo")

func set_fm_intensity(op:int,millis:int)->void:
	set_op_param(op,millis,"set_fm_intensity")

func set_fm_lfo(op:int,lfo_ix:int)->void:
	set_op_param(op,lfo_ix,"set_fm_lfo")

func set_enable(opmask:int)->void:
	set_param([15,opmask],"set_enable")

func set_clip(clip:bool)->void:
	set_param([clip],"set_clip")

func set_pm_factor(from_op:int,to_op:int,pm_factor:int)->void:
	set_param([from_op,to_op,pm_factor],"set_pm_factor")

func set_output(op:int,output:int)->void:
	set_op_param(op,output,"set_output")

"""
//void SynthTracker::set_phase(int voice,int op_mask,FixedPoint phi)
//void SynthTracker::set_volume(int voice,int vel)
//void SynthTracker::key_on(int voice,int op_mask,int velocity,bool legato)
//void SynthTracker::key_off(int voice,int op_mask)
//void SynthTracker::stop(int voice,int op_mask)
//void SynthTracker::set_lfo_phase(int lfo,FixedPoint phi)
//void SynthTracker::mute_voices(int mute_mask)
"""
