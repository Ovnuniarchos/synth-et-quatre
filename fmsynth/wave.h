#ifndef WAVE_H
#define WAVE_H

#include "common_defs.h"

struct WaveState{
	FixedPoint state[3]={0L,0L,0L};
};

class Wave{
public:
	const FixedPoint size;
	const float recorded_freq;
	const float sample_freq;

	Wave(FixedPoint sz=1L,float rf=1.0,float sf=1.0):size(sz),recorded_freq(rf),sample_freq(sf){};

	virtual FixedPoint generate(FixedPoint phi,FixedPoint pm_in,FixedPoint duty_cycle,WaveState& st){return 0L;};

	virtual FixedPoint fix_loop(FixedPoint phi,FixedPoint mod_in){return phi+mod_in;};

	virtual inline bool resets_on_keyon(){return false;};
};

#endif