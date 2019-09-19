#ifndef OPERATOR_H
#define OPERATOR_H

#include "wave.h"

class Operator{
private:
	const int EG_DIVIDER=32;
	const FixedPoint ENVELOPE_RATE=FP_ONE*EG_DIVIDER;

	enum ADSR{OFF,RELEASE,SUSTAIN,DECAY,ATTACK};

	float mix_rate=DEFAULT_MIX_RATE;

	float frequency=0.0;
	float freq_mul=1.0;
	float freq_div=1.0;
	float detune=1.0;
	FixedPoint delta=0L;

	Wave wave=Wave();
	FixedPoint phi=0L;

	bool on=false;
	ADSR eg_phase=OFF;
	FixedPoint eg_vol=0L;
	int eg_counter=EG_DIVIDER;
	int attack_rate=240;
	FixedPoint eg_ar=0L;
	int decay_rate=192;
	FixedPoint eg_dr=0L;
	int sustain_level=192;
	FixedPoint eg_sl=0L;
	int sustain_rate=16;
	FixedPoint eg_sr=0L;
	int release_rate=64;
	FixedPoint eg_rr=0L;
	ADSR eg_repeat=OFF;

	FixedPoint am_floor=FP_ONE;
	FixedPoint am_level=0L;
	FixedPoint fm_max=0L;
	FixedPoint fm_min=0L;

	FixedPoint get_rate(int rate,int &var);

public:
	bool enabled=false;

	_ALWAYS_INLINE_ void calculate_envelope(){
		if(eg_counter){
			eg_counter--;
			return;
		}
		eg_counter=EG_DIVIDER;
		switch(eg_phase){
			case ATTACK:
				eg_vol+=eg_ar;
				if(eg_vol>=FP_ONE){
					eg_vol=eg_repeat==ATTACK?0L:FP_ONE;
					eg_phase=eg_repeat==ATTACK?ATTACK:DECAY;
				}
				break;
			case DECAY:
				eg_vol-=eg_dr;
				if(eg_vol<=eg_sl){
					eg_vol=eg_sl;
					eg_phase=eg_repeat==DECAY?ATTACK:SUSTAIN;
				}
				break;
			case SUSTAIN:
				eg_vol-=eg_sr;
				if(!on){
					eg_phase=eg_repeat==SUSTAIN?ATTACK:RELEASE;
				}else if(eg_vol<=0L){
					eg_vol=0L;
					eg_phase=eg_repeat==SUSTAIN?ATTACK:OFF;
				}
				break;
			case RELEASE:
				eg_vol-=eg_rr;
				if(eg_vol<=0L){
					eg_vol=0L;
					eg_phase=eg_repeat==RELEASE?ATTACK:OFF;
				}
				break;
			default:
				eg_vol=0L;
				enabled=false;
				on=false;
		}
	}

	_ALWAYS_INLINE_ FixedPoint generate(FixedPoint pm_in,FixedPoint am_lfo_in,FixedPoint fm_lfo_in){
		if(!enabled){
			return 0L;
		}
		calculate_envelope();
		FixedPoint sample=(wave.generate(phi+pm_in)*eg_vol)>>FP_INT_SHIFT;
		// AM
		FixedPoint mod=((am_lfo_in*am_level)>>FP_INT_SHIFT)+am_floor;
		sample=(sample*mod)>>FP_INT_SHIFT;
		// FM
		mod=((fm_lfo_in*(fm_lfo_in>0?fm_max:fm_min))>>FP_INT_SHIFT)+FP_ONE;
		phi+=(delta*mod)>>FP_INT_SHIFT;
		//
		return sample;
	};

	_ALWAYS_INLINE_ void set_delta(){
		delta=(frequency*freq_mul*detune*FP_ONE)/(freq_div*mix_rate);
	}

	void set_mix_rate(float mix_rate);
	void set_frequency(float frequency);
	void set_freq_mul(int multiplier);
	void set_freq_div(int divider);
	void set_detune(float detune);

	void set_wave_mode(int mode);
	void set_duty_cycle(FixedPoint duty_cycle);
	void set_wave(UserWave **user_wave);

	void set_attack_rate(int rate);
	void set_decay_rate(int rate);
	void set_sustain_level(int level);
	void set_sustain_rate(int rate);
	void set_release_rate(int rate);
	void set_repeat(int phase);

	void set_am_intensity(int intensity);
	void set_fm_intensity(int millis);

	void key_on(bool legato);
	void key_off();
	void stop();

	void set_phase(FixedPoint phi);
};

#endif