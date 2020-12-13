#ifndef USER_WAVE
#define USER_WAVE

#include <Variant.hpp>
#include <Array.hpp>

#include "wave.h"

class UserWave:public Wave{
private:
	FixedPointShort *wave=NULL;
	int64_t size_mask=0;
	int64_t size_shift=0;

public:
	UserWave(godot::Array wave_in){
		int size=correct_wave_size(wave_in.size());
		if(size==0){
			wave==NULL;
		}else{
			wave=new FixedPointShort[size];
			for(int i=0;i<size;i++) wave[i]=((float)wave_in[i])*FP_ONE;
		}
	}

	~UserWave(){
		delete[] wave;
	};

	FixedPoint generate(FixedPoint phi,FixedPoint pm_in,FixedPoint duty_cycle,WaveState& st) override{
		if(wave==NULL) return 0L;
		phi=(phi+pm_in)&FP_DEC_MASK;
		FixedPoint tmp=wave[(phi>>size_shift)&size_mask];
		return phi>=duty_cycle?tmp:-tmp;
	};

	_ALWAYS_INLINE_ int correct_wave_size(int wave_size){
		if(wave_size==0){
			size_shift=0;
			size_mask=0;
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
		size_shift=24-shift;
		size_mask=mask;
		return mask+1;
	};
};

#endif