extends Node

const DEFAULT_VOLUME=1.0/32.0

var synth=preload("res://fm_synth.gdns").new()

#

func generate(buffer_size:int,command_list:Array,global_volume:float=DEFAULT_VOLUME)->PoolVector2Array:
	return synth.generate(buffer_size,global_volume,command_list)

#

func reset()->void:
	for i in range(0,32):
		synth.stop(i,15)

func set_mix_rate(mix_rate:float)->void:
	synth.set_mix_rate(mix_rate)

func set_fm_instrument(channel:int,instr:FmInstrument)->void:
	for i in range(0,4):
		var op_mask:int=1<<i
		synth.set_attack_rate(channel,op_mask,instr.attacks[i])
		synth.set_decay_rate(channel,op_mask,instr.decays[i])
		synth.set_sustain_level(channel,op_mask,instr.sustain_levels[i])
		synth.set_sustain_rate(channel,op_mask,instr.sustains[i])
		synth.set_release_rate(channel,op_mask,instr.releases[i])
		synth.set_repeat(channel,op_mask,instr.repeats[i])
		synth.set_wave_mode(channel,op_mask,instr.waveforms[i])
		synth.set_duty_cycle(channel,op_mask,instr.duty_cycles[i])
		synth.set_freq_mul(channel,op_mask,instr.multipliers[i])
		synth.set_freq_div(channel,op_mask,instr.dividers[i])
		synth.set_detune(channel,op_mask,instr.detunes[i])
		synth.set_output(channel,op_mask,instr.routings[i][4])
		for j in range(0,4):
			synth.set_pm_factor(channel,i,j,instr.routings[i][j])
		synth.set_am_intensity(channel,op_mask,instr.am_intensity[i])
		synth.set_am_lfo(channel,op_mask,instr.am_lfo[i])
		synth.set_fm_intensity(channel,op_mask,instr.fm_intensity[i])
		synth.set_fm_lfo(channel,op_mask,instr.fm_lfo[i])

func play_fm_note(channel:int,instr:FmInstrument,semi:int,legato:bool)->void:
	var semitone:int=semi*100
	synth.set_note(channel,instr.op_mask,semitone)
	synth.set_enable(channel,15,0)
	synth.set_panning(channel,31,false,false)
	synth.key_on(channel,instr.op_mask,255,legato)

func set_lfo_duty_cycle(lfo_ix:int,duc:int)->void:
	synth.set_lfo_duty_cycle(lfo_ix,duc)

func set_lfo_wave(lfo_ix:int,wave_ix:int)->void:
	synth.set_lfo_wave_mode(lfo_ix,wave_ix)

func set_lfo_frequency(lfo_ix:int,freq:float)->void:
	synth.set_lfo_freq(lfo_ix,freq)
