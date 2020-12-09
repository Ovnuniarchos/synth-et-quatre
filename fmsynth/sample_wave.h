#ifndef SAMPLE_WAVE
#define SAMPLE_WAVE

#include <Array.hpp>

#include "wave.h"


class SampleWave:public Wave{
private:
	const FixedPoint SAMPLE_PM_FACTOR=16L; // Ad-hoc value

	FixedPointShort *sample=NULL;
	int64_t loop_start=0;
	int64_t loop_size=0;
	bool reset_on_keyon;

	_ALWAYS_INLINE_ FixedPoint _fix_loop(FixedPoint phi,FixedPoint mod_in,bool& finished){
		uint64_t ptr=phi>>FP_INT_SHIFT;
		if(ptr<loop_start){
			return phi+mod_in;
		}
		finished=ptr>=size && loop_size==0L;
		phi+=mod_in;
		ptr=phi>>FP_INT_SHIFT;
		if(loop_size>0L){
			ptr=((ptr-loop_start)%loop_size)+loop_start;
		}
		return (clamp(ptr,(uint64_t)0L,(uint64_t)size-1)<<FP_INT_SHIFT)|(phi&FP_DEC_MASK);
	};

public:
	SampleWave(godot::Array sample_in,int loop_0,int loop_1,float rec_freq,float sam_freq):Wave(sample_in.size(),rec_freq,sam_freq){
		int64_t loop_st=clamp((int64_t)loop_0,0L,size);
		int64_t loop_end=clamp((int64_t)loop_1,0L,size);
		if(loop_st>loop_end){
			loop_start=loop_end;
			loop_end=loop_st;
		} else {
			loop_start=loop_st;
		}
		loop_size=(loop_end-loop_start)+(loop_end==loop_start?0:1);
		reset_on_keyon=loop_size==0;
		if(size==0){
			sample=NULL;
		}else{
			sample=new FixedPointShort[size];
			for(int i=0;i<size;i++) sample[i]=((float)sample_in[i])*FP_ONE;
		}
	};

	~SampleWave(){
		delete[] sample;
	};

	FixedPoint fix_loop(FixedPoint phi,FixedPoint mod_in) override{
		bool _dummy;
		return _fix_loop(phi,mod_in,_dummy);
	};

	FixedPoint generate(FixedPoint phi,FixedPoint pm_in,FixedPoint duty_cycle) override{
		if(sample==NULL || size==0) return 0L;
		bool finished;
		phi=_fix_loop(phi,pm_in*SAMPLE_PM_FACTOR,finished);
		return sample[(phi>>FP_INT_SHIFT)&FP_DEC_MASK];
	};

	inline bool resets_on_keyon() override{return reset_on_keyon;};
};

#endif