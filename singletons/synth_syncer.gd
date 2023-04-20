extends Node

func set_mix_rate(mix_rate:float)->void:
	SYNTH.synth.set_mix_rate(mix_rate)
	IM_SYNTH.synth.set_mix_rate(mix_rate)

func set_fm_instrument(channel:int,instr:FmInstrument)->void:
	SYNTH.set_fm_instrument(channel,instr)
	IM_SYNTH.set_fm_instrument(channel,instr)

func set_lfo_duty_cycle(lfo_ix:int,duc:int)->void:
	SYNTH.synth.set_lfo_duty_cycle(lfo_ix,duc<<16)
	IM_SYNTH.synth.set_lfo_duty_cycle(lfo_ix,duc<<16)

func set_lfo_wave(lfo_ix:int,wave_ix:int)->void:
	SYNTH.synth.set_lfo_wave(lfo_ix,wave_ix)
	IM_SYNTH.synth.set_lfo_wave(lfo_ix,wave_ix)

func set_lfo_frequency(lfo_ix:int,freq:float)->void:
	SYNTH.synth.set_lfo_freq(lfo_ix,freq)
	IM_SYNTH.synth.set_lfo_freq(lfo_ix,freq)
