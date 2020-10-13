#ifndef RECTANGLE_WAVE
#define RECTANGLE_WAVE

#include "wave.h"

class RectangleWave:public Wave{
public:
	FixedPoint generate(FixedPoint phi,FixedPoint pm_in,FixedPoint duty_cycle) override{
		return ((phi+pm_in)&FP_DEC_MASK)>=duty_cycle?FP_ONE:-FP_ONE;
	};
};

#endif