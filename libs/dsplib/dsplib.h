#ifndef DSPLIB
#define DSPLIB

#include <Godot.hpp>
#include <Node.hpp>
#include <Vector2.hpp>
#include <Math.hpp>
#include <limits>


namespace godot{

class DSPLib:public Node{
	GODOT_CLASS(DSPLib,Node)
private:
	enum MixMode{OFF,REPLACE,ADD,AM,XM};
	const uint64_t FIXP_1=0x10000000000ULL;
	const uint64_t FIXP_1MASK=0xffffffffffULL;
	union I2FConverter{
		uint32_t i;
		float f;
		inline void setMantissa(uint32_t m){i=0x3f800000U+(m&0x007fffffU);f-=1.0f;}
		inline bool isNegative(){return (bool)(i&0x80000000U);}
		inline void setSign(bool neg){i=(i&0x7fffffff)|((neg<<31U)&0x80000000U);}
		inline void setPositive(){i&=0x7fffffff;}
	};
	uint64_t randomSeed;
	float sineTable[16384];
	inline float randSample(){
		randomSeed=((randomSeed&1ULL)<<63ULL) | ((randomSeed>>1ULL)&0x7fffffffffffffffULL) ^ ((~randomSeed&0x4020000000ULL)>>26ULL) ^ ((~randomSeed&0x200ULL)<<19ULL) ^ ((~randomSeed&0x1000ULL)<<29ULL);
		I2FConverter i2f;
		i2f.i=(randomSeed^(randomSeed>>32))&0x807fffff;
		return i2f.f;
	}
	inline float ease(float in){
		if(in<0.5){
			in*=2.0;
			return (in*in)*0.5;
		} else {
			in=1.0-(in-0.5)*2.0;
			return (1.0-(in*in))*0.5+0.5;
		}
	}
	inline float variant2Float(Variant x){return (float)x;}
	inline float full2Positive(float x){return (x+1.0f)*0.5f;}
	inline float abs(float x){
		I2FConverter i2f;
		i2f.f=x;
		i2f.i&=0x7fffffff;
		return i2f.f;
	}
	inline float abspow(float x,float power){
		I2FConverter i2f;
		i2f.f=x;
		bool neg=i2f.isNegative();
		i2f.setPositive();
		i2f.f=pow(i2f.f,power);
		i2f.setSign(neg);
		return i2f.f;
	}
	inline void calc_decay(float &curr_dec,float &decay,I2FConverter &delta,float &current){
		delta.f=current-delta.f;
		if(abs(delta.f)<0.0000001f || delta.isNegative()!=(current<0.0f)){
			curr_dec-=decay;
			if (curr_dec<0.0f) curr_dec=0.0f;
		}else{
			curr_dec=1.0f;
		}
		delta.f=current;
	}
	inline float init_decay(float decay,int size){
		return (pow(decay,5.0)*128.0f)/size;
	}
	float* arrayG2C(Array in){
		float *out=new float[in.size()];
		for(int i=in.size()-1;i>-1;i--){
			out[i]=variant2Float(in[i]);
		}
		return out;
	}
public:
	static void _register_methods();

	DSPLib();
	~DSPLib();

	void _init();

	Array addSoundStreams(Array const a,Array const b);

	Array mixWaves(Array input,Array generated,Array modulator,Array output,float am,float xm,float vol,int mode);

	void noise(
		Array input,Array output,
		float pos0,float length,
		int64_t seed,float tone,float power,
		float vol,int mode
	);
	void sine(
		Array input,Array output,Array modulator,
		float pos0,float offset,float freqMult,float cycles,
		float pm,float power,float decay,
		float vol,int mode,
		int q0,int q1,int q2,int q3
	);
	void rectangle(
		Array input,Array output,Array modulator,
		float pos0,float offset,float freqMult,float cycles,
		float pm,float decay,
		float vol,int mode,
		float zStart,float nStart
	);
	void saw(
		Array input,Array output,Array modulator,
		float pos0,float offset,float freqMult,float cycles,
		float pm,float power,float decay,
		float vol,int mode,
		int q0,int q1,int q2,int q3
	);
	void triangle(
		Array input,Array output,Array modulator,
		float pos0,float offset,float freqMult,float cycles,
		float pm,float power,float decay,
		float vol,int mode,
		int q0,int q1,int q2,int q3
	);

	void convolutionFilter(Array input,Array output,Array coeffs,float vol);
	void normalize(Array input,Array output,bool keepCenter,float vol);
	void clamp(Array input,Array output,float loLevel,float hiLevel,bool loClamp,bool hiClamp,float vol);
	void quantize(Array input,Array output,int steps,float vol);
	void power(Array input,Array output,float power,float vol);
	void decay(Array input,Array output,float decay,float vol);
};

}

#endif