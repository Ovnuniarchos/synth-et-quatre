#ifndef OPERATOR
#define OPERATOR

#include "wave.h"

class Operator{
private:
	const int EG_DIVIDER=32;
	const FixedPoint ENVELOPE_RATE_1S=FP_ONE*EG_DIVIDER*256;

	enum ADSR{OFF,PRE_ATTACK,ATTACK,PRE_DECAY,DECAY,SUSTAIN,RELEASE,SUSTAIN_UP};
	enum DET_MODE{NORMAL,FIXED,DELTA};

	float mix_rate=DEFAULT_MIX_RATE;

	bool enabled=false;

	int key_cents=0;
	float frequency=0.0;
	float freq_mul=1.0;
	float freq_div=1.0;
	float detune=1.0;
	int detune_mode=NORMAL;
	FixedPoint fixed_freq=0L;
	FixedPoint delta=0L;

	Wave **waves=NULL;
	int wave_ix=0;
	FixedPoint phi=0L;
	FixedPoint duty_cycle=0L;
	WaveState wave_state;

	bool on=false;
	ADSR eg_phase=OFF;
	FixedPoint eg_vol=0L;
	FixedPoint eg_tick=0L;
	FixedPoint eg_delta_tick=0L;
	int eg_counter=EG_DIVIDER;
	int pre_attack_rate=0;
	int pre_attack_level=0;
	FixedPoint eg_patk_rate=0L;
	FixedPoint eg_patk_level=0L; // Doubles as hold length
	int attack_rate=240;
	FixedPoint eg_atk_rate=0L;
	int pre_decay_rate=0;
	int pre_decay_level=0;
	FixedPoint eg_pdec_rate=0L;
	FixedPoint eg_pdec_level=0L; // Doubles as hold length
	int decay_rate=192;
	FixedPoint eg_dec_rate=0L;
	int sustain_level=192;
	FixedPoint eg_sus_level=0L;
	int sustain_rate=16;
	FixedPoint eg_sus_rate=0L;
	int release_rate=64;
	FixedPoint eg_rel_rate=0L;
	ADSR eg_repeat=OFF;
	int key_scale=0;

	FixedPoint am_floor=FP_ONE;
	FixedPoint am_level=0L;
	FixedPoint fm_max=0L;
	FixedPoint fm_min=0L;

	_ALWAYS_INLINE_ void calculate_envelope();

	_ALWAYS_INLINE_ FixedPoint get_rate(int rate,int &var);

	_ALWAYS_INLINE_ void set_delta();

	_ALWAYS_INLINE_ bool is_valid_wave(int ix);

public:
	void set_wave_list(Wave **list);

	FixedPoint generate(FixedPoint pm_in,FixedPoint am_lfo_in,FixedPoint fm_lfo_in);

	void set_mix_rate(float mix_rate);
	void set_frequency(int cents,float frequency);
	void set_freq_mul(int multiplier);
	void set_freq_div(int divider);
	void set_detune(int frequency,float detune);
	void set_detune_mode(int mode);

	void set_wave(int wave_num);
	void set_duty_cycle(FixedPoint duty_cycle);
	void set_phase(FixedPoint phi);
	void shift_phase(FixedPoint delta);

	void set_pre_attack_rate(int rate);
	void set_pre_attack_level(int level);
	void set_attack_rate(int rate);
	void set_pre_decay_rate(int rate);
	void set_pre_decay_level(int level);
	void set_decay_rate(int rate);
	void set_sustain_level(int level);
	void set_sustain_rate(int rate);
	void set_release_rate(int rate);
	void set_repeat(int phase);
	void set_ksr(int ksr);

	void set_am_intensity(int intensity);
	void set_fm_intensity(int millis);

	void set_enable(bool enable);
	void key_on(bool legato);
	void key_off();
	void stop();
};

#endif