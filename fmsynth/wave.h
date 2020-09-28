#ifndef WAVE_H
#define WAVE_H

#include <cstddef>
#include "common_defs.h"

struct UserWave{
	FixedPointShort *wave=NULL;
	bool sample=false;
	int64_t size_mask=0;
	int64_t size_shift=0;
	int64_t loop_start=0;
	int64_t loop_size=0;
	float recorded_freq=0.0;
	float sample_freq=0.0;

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

	_ALWAYS_INLINE_ FixedPoint generate(FixedPoint phi,FixedPoint pm_in){
		phi=(mode==USER)?phi:(phi+pm_in)&FP_DEC_MASK;
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
				if(wave==NULL || (*wave)==NULL) return 0L;
				if((*wave)->sample){
					phi=(fix_loop(phi,pm_in)>>FP_INT_SHIFT)&FP_DEC_MASK;
					return (*wave)->wave[phi];
				}
				phi=(phi+pm_in)&FP_DEC_MASK;
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

	_ALWAYS_INLINE_ int64_t get_size_mask(){
		return is_sampled()?(*wave)->size_mask:0L;
	}

	_ALWAYS_INLINE_ float get_recorded_freq(){
		return is_sampled()?(*wave)->recorded_freq:1.0;
	}

	_ALWAYS_INLINE_ float get_sample_freq(){
		return is_sampled()?(*wave)->sample_freq:1.0;
	}

	_ALWAYS_INLINE_ bool is_sampled(){
		return (mode==USER)&&(wave!=NULL)&&(*wave!=NULL)&&((*wave)->sample);
	}

	_ALWAYS_INLINE_ FixedPoint fix_loop(FixedPoint phi,FixedPoint mod_in){
		if(!is_sampled()){
			return phi+mod_in;
		}
		int64_t ptr=phi>>FP_INT_SHIFT;
		if(ptr<(*wave)->loop_start){
			return phi+mod_in;
		}
		phi+=mod_in;
		ptr=phi>>FP_INT_SHIFT;
		if((*wave)->loop_size>0L){
			ptr=((ptr-(*wave)->loop_start)%(*wave)->loop_size)+(*wave)->loop_start;
		}
		return (clamp(ptr,0L,(*wave)->size_mask)<<FP_INT_SHIFT)|(phi&FP_DEC_MASK);
	}
};

#endif