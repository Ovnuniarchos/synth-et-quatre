#ifndef SAW_WAVE
#define SAW_WAVE

#include "wave.h"

class SawWave:public Wave{
public:
	FixedPoint generate(FixedPoint phi,FixedPoint pm_in,FixedPoint duty_cycle,WaveState& st) override{
		phi=(phi+pm_in)&FP_DEC_MASK;
		FixedPoint tmp=(phi<<1)-FP_ONE;
		return phi>=duty_cycle?tmp:-tmp;
	};
};

#endif