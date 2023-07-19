#ifndef VOICE
#define VOICE

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
	FixedPoint last_samples[2][MAX_OPS]={{0L,0L,0L,0L},{0L,0L,0L,0L}};
	int volume=256;
	int new_volume=256;
	int vol_left=33;
	int vol_right=33;
	int am_lfos[MAX_OPS]={0,0,0,0};
	int fm_lfos[MAX_OPS]={0,0,0,0};

public:
	bool clip=false;

	void set_wave_list(Wave **list);

	FixedPoint generate(FixedPoint* lfo_ins);

	void set_mix_rate(float mix_rate);
	void set_note(int op_mask,int cents);
	void set_freq_mul(int op_mask,int multiplier);
	void set_freq_div(int op_mask,int divider);
	void set_detune(int op_mask,int millis);

	void set_wave(int op_mask,int wave_num);
	void set_duty_cycle(int op_mask,FixedPoint duty_cycle);
	void set_phase(int op_mask,FixedPoint phi);

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
	void set_enable(int op_mask,int enable_bits);

	void set_pm_factor(int op_from,int op_to,int factor);
	void set_output(int op_mask,int volume);

	void set_panning(int panning,bool invert_left,bool invert_right);
	_ALWAYS_INLINE_ int get_volume_left(){return vol_left;};
	_ALWAYS_INLINE_ int get_volume_right(){return vol_right;};
};

#endif