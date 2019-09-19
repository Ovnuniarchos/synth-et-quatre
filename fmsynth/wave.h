#ifndef WAVE_H
#define WAVE_H

#include <cstddef>
#include "common_defs.h"

struct UserWave{
	FixedPoint *wave=NULL;
	int64_t size_mask=0;
	int64_t size_shift=0;

	~UserWave(){
		delete wave;
	}

	static int correct_wave_size(int wave_size,int &sz_mask,int &sz_shift){
		if(wave_size==0){
			sz_shift=0;
			sz_mask=0;
			return 0;
		}
		int mask=0;
		int shift=0;
		wave_size--;
		while(wave_size){
			mask|=(1<<shift);
			shift++;
			wave_size>>=1;
		}
		sz_shift=24-shift;
		sz_mask=mask;
		return mask+1;
	};
};

class Wave{
private:
	const FixedPoint NOISE_BIT=FP_ONE>>8;
	enum{RECTANGLE,SAW,TRIANGLE,NOISE,USER};

	int mode=RECTANGLE;

	int noise_gen=0;
	FixedPoint noise_latch=0L;
	FixedPoint noise_switch=NOISE_BIT;

	FixedPoint duty_cycle=FP_HALF;

	UserWave **wave=NULL;

public:
	_ALWAYS_INLINE_ FixedPoint fast_rand(){
		noise_gen=((noise_gen&1)<<24)|(noise_gen>>1)^((~noise_gen&0x4000)>>4)^((~noise_gen&0x200)<<9);
		return noise_gen;
	};

	_ALWAYS_INLINE_ FixedPoint generate(FixedPoint phi){
		phi&=FP_DEC_MASK;
		FixedPoint tmp;
		switch(mode){
			case RECTANGLE:
				return phi>=duty_cycle?FP_ONE:-FP_ONE;
			case SAW:
				tmp=(phi<<1)-FP_ONE;
				return phi>=duty_cycle?tmp:-tmp;
			case TRIANGLE:
				tmp=phi<FP_HALF?(FP_ONE-(phi<<2)):((phi-FP_HALF)<<2)-FP_ONE;
				return phi>=duty_cycle?tmp:-tmp;
			case NOISE:
				if((phi&NOISE_BIT)==noise_switch){
					noise_switch^=NOISE_BIT;
					noise_latch=(fast_rand()&FP_NEARLY_TWO)-FP_ONE;
				}
				return noise_latch;
			case USER:
				if(wave==NULL) return 0L;
				tmp=(*wave)->wave[(phi>>(*wave)->size_shift)&(*wave)->size_mask];
				return phi>=duty_cycle?tmp:-tmp;
			default:
				return 0L;
		}
	};

	_ALWAYS_INLINE_ void set_mode(int m){
		mode=clamp(m,(int)RECTANGLE,(int)USER);
	};

	_ALWAYS_INLINE_ void set_duty_cycle(FixedPoint dc){
		duty_cycle=clamp(dc,0L,FP_ONE-1);
	};

	_ALWAYS_INLINE_ void set_wave(UserWave **user_wave){
		wave=user_wave;
	};
};

#endif