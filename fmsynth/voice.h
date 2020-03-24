#ifndef VOICE_H
#define VOICE_H

#include <cmath>

#include "operator.h"


class Voice{
private:
	static const int MAX_OPS=4;
	Operator ops[MAX_OPS];
	int pms[MAX_OPS][MAX_OPS]={
		0,0,0,0,
		0,0,0,0,
		0,0,0,0,
		0,0,0,0
	};
	int outs[MAX_OPS]={256,0,0,0};
	FixedPoint last_samples[MAX_OPS]={0L,0L,0L,0L};
	int volume=256;
	int vol_left=33;
	int vol_right=33;
	int am_lfos[MAX_OPS]={0,0,0,0};
	int fm_lfos[MAX_OPS]={0,0,0,0};

public:
	_ALWAYS_INLINE_ FixedPoint generate(FixedPoint* lfo_ins){
		last_samples[0]=ops[0].generate(
			((last_samples[0]*pms[0][0])+
			(last_samples[1]*pms[1][0])+
			(last_samples[2]*pms[2][0])+
			(last_samples[3]*pms[3][0]))>>8
			,lfo_ins[am_lfos[0]],lfo_ins[fm_lfos[0]]
		);
		last_samples[1]=ops[1].generate(
			((last_samples[0]*pms[0][1])+
			(last_samples[1]*pms[1][1])+
			(last_samples[2]*pms[2][1])+
			(last_samples[3]*pms[3][1]))>>8
			,lfo_ins[am_lfos[1]],lfo_ins[fm_lfos[1]]
		);
		last_samples[2]=ops[2].generate(
			((last_samples[0]*pms[0][2])+
			(last_samples[1]*pms[1][2])+
			(last_samples[2]*pms[2][2])+
			(last_samples[3]*pms[3][2]))>>8
			,lfo_ins[am_lfos[2]],lfo_ins[fm_lfos[2]]
		);
		last_samples[3]=ops[3].generate(
			((last_samples[0]*pms[0][3])+
			(last_samples[1]*pms[1][3])+
			(last_samples[2]*pms[2][3])+
			(last_samples[3]*pms[3][3]))>>8
			,lfo_ins[am_lfos[3]],lfo_ins[fm_lfos[3]]
		);
		return ((
				(last_samples[0]*outs[0])+(last_samples[1]*outs[1])+
				(last_samples[2]*outs[2])+(last_samples[3]*outs[3])
			)*volume)>>16;
	};

	void set_mix_rate(float mix_rate);
	void set_note(int op_mask,int cents);
	void set_freq_mul(int op_mask,int multiplier);
	void set_freq_div(int op_mask,int divider);
	void set_detune(int op_mask,int millis);

	void set_wave_mode(int op_mask,int mode);
	void set_duty_cycle(int op_mask,FixedPoint duty_cycle);
	void set_wave(int op_mask,UserWave **user_wave);

	void set_volume(int vol);
	void set_attack_rate(int op_mask,int rate);
	void set_decay_rate(int op_mask,int rate);
	void set_sustain_level(int op_mask,int level);
	void set_sustain_rate(int op_mask,int rate);
	void set_release_rate(int op_mask,int rate);
	void set_repeat(int op_mask,int phase);
	void set_ksr(int op_mask,int ksr);

	void set_am_intensity(int op_mask,int intensity);
	void set_am_lfo(int op_mask,int lfo);
	void set_fm_intensity(int op_mask,int millis);
	void set_fm_lfo(int op_mask,int lfo);

	void key_on(int op_mask,int volume,bool legato);
	void key_off(int op_mask);
	void stop(int op_mask);
	void set_enable(int op_mask,bool enable);

	void set_pm_factor(int op_from,int op_to,int factor);
	void set_output(int op_mask,int volume);

	void set_panning(int panning,bool invert_left,bool invert_right);
	_ALWAYS_INLINE_ int get_volume_left(){return vol_left;};
	_ALWAYS_INLINE_ int get_volume_right(){return vol_right;};

	void set_phase(int op_mask,int phi);
};

#endif