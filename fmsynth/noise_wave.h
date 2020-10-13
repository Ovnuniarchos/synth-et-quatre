#ifndef NOISE_WAVE
#define NOISE_WAVE

#include <cstdlib>
#include "wave.h"

class NoiseWave:public Wave{
private:
	const int NOISE_SIZE=0x1000;
	const int NOISE_MASK=NOISE_SIZE-1;
	uint8_t *noiz;

public:
	NoiseWave(){
		noiz=new uint8_t[NOISE_SIZE];
		for(int i=0;i<NOISE_SIZE;i++){
			int j=rand()&NOISE_MASK;
			noiz[i]=j&0xff;
			noiz[j]=i&0xff;
		}
	};

	~NoiseWave(){
		delete noiz;
	};

	FixedPoint generate(FixedPoint phi,FixedPoint pm_in,FixedPoint duty_cycle) override{
		phi+=pm_in;
		FixedPoint tmp=(noiz[(phi>>19)&NOISE_MASK]<<20)+
			(noiz[(phi>>20)&NOISE_MASK]<<19)+
			(noiz[(phi>>21)&NOISE_MASK]<<18)+
			(noiz[(phi>>22)&NOISE_MASK]<<17)+
			(noiz[(phi>>23)&NOISE_MASK]<<16)+
			(noiz[(phi>>24)&NOISE_MASK]<<15)+
			(noiz[(phi>>25)&NOISE_MASK]<<14)+
			(noiz[(phi>>26)&NOISE_MASK]<<13);
		return (tmp&FP_NEARLY_TWO)-FP_ONE;
	};
};

#endif