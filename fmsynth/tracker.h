#ifndef TRACKER_H
#define TRACKER_H

#include <vector>
#include <Godot.hpp>
#include <PoolArrays.hpp>

#include "fm_synth.h"


namespace godot{

class SynthTracker : public Object{
	GODOT_CLASS(SynthTracker,Object)
private:
	FmSynth synth=FmSynth();
	PoolVector2Array buffer=PoolVector2Array();
	enum{
		CMD_WAIT=0x00,
		CMD_FREQ,
		CMD_KEYON,
		CMD_KEYON_LEGATO,
		CMD_KEYOFF,
		CMD_STOP,
		CMD_ENABLE,
		CMD_MULT=0x07,
		CMD_DIV,
		CMD_DET,
		CMD_DUC,
		CMD_WAVE=0x0b,
		CMD_VEL=0x0c,
		CMD_AR,
		CMD_DR,
		CMD_SL,
		CMD_SR,
		CMD_RR,
		CMD_RM,
		CMD_PM=0x13,
		CMD_OUT,
		CMD_PAN=0x15,
		CMD_PHI=0x16,
		CMD_AMS=0x17,
		CMD_AM_LFO,
		CMD_FMS,
		CMD_FM_LFO,
		CMD_LFO_FREQ=0x1b,
		CMD_LFO_WAVE,
		CMD_LFO_DUC,
		CMD_END=0xff
	};

public:
	static void _register_methods();

	SynthTracker();
	~SynthTracker();

	void _init();

	PoolVector2Array generate(int size,float volume,Array cmds);

	void set_mix_rate(float mix_rate);
	void set_note(int voice,int op_mask,int cents);
	void set_freq_mul(int voice,int op_mask,int multiplier);
	void set_freq_div(int voice,int op_mask,int divider);
	void set_detune(int voice,int op_mask,int millis);

	void set_wave_mode(int voice,int op_mask,int mode);
	void set_duty_cycle(int voice,int op_mask,FixedPoint duty_cycle);
	void set_wave(int wave_ix,PoolRealArray wave);

	void set_velocity(int voice,int vel);
	void set_attack_rate(int voice,int op_mask,int rate);
	void set_decay_rate(int voice,int op_mask,int rate);
	void set_sustain_level(int voice,int op_mask,int level);
	void set_sustain_rate(int voice,int op_mask,int rate);
	void set_release_rate(int voice,int op_mask,int rate);
	void set_repeat(int voice,int op_mask,int phase);

	void set_am_intensity(int voice,int op_mask,int intensity);
	void set_am_lfo(int voice,int op_mask,int lfo);
	void set_fm_intensity(int voice,int op_mask,int millis);
	void set_fm_lfo(int voice,int op_mask,int lfo);

	void key_on(int voice,int op_mask,int velocity,bool legato);
	void key_off(int voice,int op_mask);
	void stop(int voice,int op_mask);
	void set_enable(int voice,int op_mask,bool enable);

	void set_pm_factor(int voice,int op_from,int op_to,int pm_factor);
	void set_output(int voice,int op_mask,int volume);

	void set_panning(int voice,int panning,bool invert_left,bool invert_right);

	void set_phase(int voice,int op_mask,int phi);

	void set_lfo_freq(int lfo,float frequency);
	void set_lfo_wave_mode(int lfo,int mode);
	void set_lfo_duty_cycle(int lfo,int duty_cycle);

	void mute_voices(int mute_mask);
};

}

#endif