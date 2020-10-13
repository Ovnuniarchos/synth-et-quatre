#ifndef TRIANGLE_WAVE
#define TRIANGLE_WAVE

#include "wave.h"

class TriangleWave:public Wave{
public:
	FixedPoint generate(FixedPoint phi,FixedPoint pm_in,FixedPoint duty_cycle) override{
		phi=(phi+pm_in)&FP_DEC_MASK;
		FixedPoint tmp=phi<FP_HALF?(FP_ONE-(phi<<2)):((phi-FP_HALF)<<2)-FP_ONE;
		return phi>=duty_cycle?tmp:-tmp;
	};
};

#endif