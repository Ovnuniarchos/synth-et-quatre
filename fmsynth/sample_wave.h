#ifndef SAMPLE_WAVE
#define SAMPLE_WAVE

#include <Variant.hpp>
#include <Array.hpp>

#include "wave.h"


class SampleWave:public Wave{
private:
	const FixedPoint SAMPLE_PM_FACTOR=16L; // Ad-hoc value

	FixedPointShort *sample=NULL;
	int64_t size=0;
	int64_t loop_start=0;
	int64_t loop_size=0;
	float recorded_freq=0.0;
	float sample_freq=0.0;

	_ALWAYS_INLINE_ FixedPoint _fix_loop(FixedPoint phi,FixedPoint mod_in){
		uint64_t ptr=phi>>FP_INT_SHIFT;
		if(ptr<loop_start){
			return phi+mod_in;
		}
		phi+=mod_in;
		ptr=phi>>FP_INT_SHIFT;
		if(loop_size>0L){
			ptr=((ptr-loop_start)%loop_size)+loop_start;
		}
		return (clamp(ptr,(uint64_t)0L,(uint64_t)size)<<FP_INT_SHIFT)|(phi&FP_DEC_MASK);
	}

public:
	SampleWave(godot::Array sample_in,int loop_0,int loop_1,float rec_freq,float sam_freq){
		size=sample_in.size();
		int64_t loop_start=clamp((int64_t)loop_0,0L,size);
		int64_t loop_end=clamp((int64_t)loop_1,0L,size);
		if(loop_start>loop_end){
			int64_t t=loop_start;
			loop_start=loop_end;
			loop_end=t;
		}
		loop_size=(loop_end-loop_start)+(loop_end==loop_start?0:1);
		recorded_freq=rec_freq;
		sample_freq=sam_freq;
		if(size==0){
			sample=NULL;
		}else{
			sample=new FixedPointShort[size];
			for(int i=0;i<size;i++) sample[i]=((float)sample_in[i])*FP_ONE;
		}
		// printf("%d (%d) %d\n",loop_start,loop_end,loop_size);
	}

	~SampleWave(){
		delete[] sample;
	};

	FixedPoint fix_loop(FixedPoint phi,FixedPoint mod_in) override{
		FixedPoint p2=_fix_loop(phi,mod_in);
		return p2;
	}

	FixedPoint generate(FixedPoint phi,FixedPoint pm_in,FixedPoint duty_cycle) override{
		if(sample==NULL || size==0) return 0L;
		return sample[(_fix_loop(phi,pm_in*SAMPLE_PM_FACTOR)>>FP_INT_SHIFT)&FP_DEC_MASK];
	};

	FixedPoint get_size() override{return size<<FP_INT_SHIFT;}

	float get_recorded_freq() override{return recorded_freq;};

	float get_sample_freq() override{return sample_freq;};
};

#endif