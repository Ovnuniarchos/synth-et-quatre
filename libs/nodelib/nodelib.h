#ifndef NODELIB
#define NODELIB

#include <Godot.hpp>
#include <Math.hpp>
#include <OpenSimplexNoise.hpp>
#include <Node.hpp>
#include <cmath>
#include <limits>
#include <cstdio>
#include <complex>
#include <vector>


namespace godot{

class NodeLib:public Node{
	GODOT_CLASS(NodeLib,Node)

private:
	typedef std::complex<double> Complex;
	typedef std::vector<Complex> VectorC;

	double sineTable[16384];

	enum AmplitudeBounds{
		HI,LO,HILO,
		HI_FULL,LO_FULL,HILO_FULL
	};

	union I2DConverter{
		uint64_t i;
		double d;
		I2DConverter(){i=0L;}
		I2DConverter(double v){d=v;}
		I2DConverter(uint64_t v){i=v;}
		inline double setSign(double b){I2DConverter i2(b);i=(i&0x7fffffffffffffffULL)|(i2.i&0x8000000000000000ULL);return d;}
		inline double setPlusMinusOne(uint64_t m){i=0x3fe0000000000000ULL|(m&0x800fffffffffffffULL);return d;}
		inline double setPositive(){i&=0x7fffffffffffffffULL;return d;}
		inline double abspow(double p){uint64_t s=i&0x8000000000000000ULL;setPositive();d=pow(d,p);i|=s;return d;}
	};

	struct Random{
		uint64_t seed;
		Random(uint64_t v){seed=v;}
		inline double next(){
			seed=(((seed&1ULL)<<63ULL) | ((seed>>1ULL)&0x7fffffffffffffffULL)) ^ ((~seed&0x4020000000ULL)>>26ULL) ^ ((~seed&0x230ULL)<<19ULL) ^ ((~seed&0x1050ULL)<<39ULL) ^ 0x30f04050010109ULL;
			I2DConverter i2d;
			return i2d.setPlusMinusOne(seed);
		}
		inline double next(double v){
			return next()*v;
		}
	};

	template <typename T> static inline int sgn(T val) {
		return (T(0)<val)-(val<T(0));
	};

	struct Decay{
		double last_value;
		double decay;
		double decay_factor;

		Decay(int size){
			last_value=0.0;
			decay=1.0;
			decay_factor=128.0/Math::max(1.0,(double)size);
		}
		inline double next(double new_value,double decay_in){
			double delta=new_value-last_value;
			if (fabs(delta)<0.00000001 || sgn(delta)!=sgn(new_value)){
				decay=Math::max(0.0,decay-(pow(decay_in,4.0)*decay_factor));
			}else{
				decay=1.0;
			}
			last_value=new_value;
			return new_value*decay;
		}
	};

	static inline double fposmod(double a,double b){
		double t=fmod(a,b);
		return ((t<0.0)!=(b<0.0))?(t+b):t;
	};

	static inline double to_double(bool b){return b?1.0:0.0;}

	static inline double ease(double x,double c){
		if(c>0.0){
			return (c<1.0)?1.0-pow(1.0-x,1.0/c):pow(x, c);
		}else if(c < 0){
			return (x< 0.5)?pow(x*2.0,-c)*0.5:(1.0-pow(1.0-(x-0.5)*2.0,-c))*0.5+0.5;
		}
		return 0.0;
	}

	void fill_out_of_region(int segment_size,int outptr,Array output,Array input,Array isolate);

	void fft_convert(Array input,VectorC &data){
		// TODO interpolate NaN regions
		data.resize(input.size());
		for(int i=input.size()-1;i>=0;i--) data[i]=(double)input[i];
	}

	void fft(VectorC &data,bool inverse);

	std::vector<int> create_chunks(int segment_size,int outptr,int steps);

	void lp_coeffs(VectorC &source,VectorC &dest,int cutoff,double attenuation,double resonance);

	void hp_coeffs(VectorC &source,VectorC &dest,int cutoff,double attenuation,double resonance);

public:
	static void _register_methods();

	NodeLib();
	~NodeLib();

	void _init();

	void accumulate(Array input,Array output);

	void de_nan_ize(Array array,double value);

	void optionize(Array array,double value,int option_count);

	void booleanize(Array array);

	void diff_booleanize(Array array);

	void clamp(Array array,double minval,double maxval);

	void noise(Array output,int segment_size,int outptr,
		int64_t seed,Array amplitude,Array decay,Array power,Array dc,Array octaves,Array frequency,
		Array persistence,Array lacunarity,Array randomness
	);

	void pulse(Array output,int segment_size,int outptr,
		Array ppulse_start,Array ppulse_length,Array ppulse_amplitude,
		Array npulse_start,Array npulse_length,Array npulse_amplitude,
		Array frequency,Array amplitude,Array phi0,Array decay,Array dc
	);

	void ramp(Array output,int segment_size,int outptr,
		double ramp_from,double ramp_to,double curve
	);

	void saw(Array output,int segment_size,int outptr,
		Array frequency,Array amplitude,Array dphi,Array power,Array decay,Array dc,
		Array quarter0,Array quarter1,Array quarter2,Array quarter3
	);

	void sine(Array output,int segment_size,int outptr,
		Array frequency,Array amplitude,Array dphi,Array power,Array decay,Array dc,
		Array quarter0,Array quarter1,Array quarter2,Array quarter3
	);

	void triangle(Array output,int segment_size,int outptr,
		Array frequency,Array amplitude,Array dphi,Array power,Array decay,Array dc,
		Array quarter0,Array quarter1,Array quarter2,Array quarter3
	);

	void multiclamp(Array output,int segment_size,int outptr,Array input,
		Array level_hi,Array clamp_hi,Array mode_hi,
		Array level_lo,Array clamp_lo,Array mode_lo,
		Array mix,Array clamp_mix,Array isolate,
		Array amplitude,Array power,Array decay,Array dc
	);

	void clip(Array output,int segment_size,int outptr,Array input);

	void decay(Array output,int segment_size,int outptr,Array input,
		Array mix,Array clamp_mix,Array isolate,
		Array amplitude,Array power,Array decay,Array dc
	);

	void map_range(Array output,int segment_size,int outptr,Array input,
		Array min_in,Array max_in,Array min_out,Array max_out,Array xerp_in,Array xerp_out,
		Array mix,Array clamp_mix,Array isolate,
		Array amplitude,Array power,Array decay,Array dc
	);

	void map_wave(Array output,int segment_size,int outptr,Array input,
		Array map,double slope_neg,double slope_pos,Array lerp,Array xerp,
		Array mix,Array clamp_mix,Array map_empty,Array isolate,
		Array amplitude,Array power,Array decay,Array dc
	);

	void mix(Array output,int segment_size,int outptr,
		Array a,Array b,Array mode,
		Array mix,Array clamp_mix,Array isolate,
		Array power,Array decay,Array dc
	);

	void mux(Array output,int segment_size,int outptr,
		Array inputs,Array selector,Array clip
	);

	void find_amplitude_bounds(Array input,int segment_size,int outptr,Array hi_lo);

	void normalize(Array output,int segment_size,int outptr,
		double hi,double lo,double hilo,double hi_full,double lo_full,double hilo_full,
		Array input,Array keep_0,Array use_full,
		Array mix,Array clamp_mix,Array isolate,
		Array amplitude,Array power,Array decay
	);

	void power(Array output,int segment_size,int outptr,
		Array input,Array power,
		Array mix,Array clamp_mix,Array isolate,
		Array amplitude,Array decay,Array dc
	);

	void quantize(Array output,int segment_size,int outptr,
		double hi,double lo,double hi_full,double lo_full,
		Array input,Array levels,Array dither,Array use_full,Array full_amplitude,
		Array mix,Array clamp_mix,Array isolate,
		Array amplitude,Array power,Array decay
	);

	void decimate(Array output,int segment_size,int outptr,
		Array input,Array samples,Array use_full,Array lerp,
		Array mix,Array clamp_mix,Array isolate,
		Array amplitude,Array power,Array decay,Array dc
	);

	void lowpass(Array output,int segment_size,int outptr,
		double cutoff_mul,int steps,
		Array input,Array cutoff,Array attenuation,Array resonance,
		Array mix,Array clamp_mix,Array isolate,
		Array amplitude,Array power,Array decay,Array dc
	);

	void highpass(Array output,int segment_size,int outptr,
		double cutoff_mul,int steps,
		Array input,Array cutoff,Array attenuation,Array resonance,
		Array mix,Array clamp_mix,Array isolate,
		Array amplitude,Array power,Array decay,Array dc
	);
};

}

#endif