#ifndef NOISE_WAVE
#define NOISE_WAVE

#include "wave.h"

class NoiseWave:public Wave{
public:
	const int ST_NOISE_LSFR=0;
	const int ST_NOISE_LATCH=1;
	const int ST_NOISE_SWITCH=2;
	const FixedPoint NOISE_BIT=FP_ONE>>3;

	FixedPoint generate(FixedPoint phi,FixedPoint pm_in,FixedPoint duty_cycle,WaveState& st) override{
		uint64_t& nlsfr=(uint64_t&)st.state[ST_NOISE_LSFR];
		FixedPoint& nlatch=st.state[ST_NOISE_LATCH];
		FixedPoint& nswitch=st.state[ST_NOISE_SWITCH];
		if((phi&NOISE_BIT)==nswitch){
			nswitch^=NOISE_BIT;
			nlsfr=((nlsfr&1UL)<<63) | ((nlsfr>>1)&0x7fffffffffffffffUL) ^ ((~nlsfr&0x4020000000UL)>>26) ^ ((~nlsfr&0x200UL)<<19) ^ ((~nlsfr&0x1000UL)<<29);
			nlatch=(nlsfr&FP_NEARLY_TWO)-FP_ONE;
		}
		return nlatch;
	};
};

#endif