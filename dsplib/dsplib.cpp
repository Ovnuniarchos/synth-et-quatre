#include "dsplib.h"
#include <cstdio>

using namespace godot;

extern "C" void GDN_EXPORT dsplib_gdnative_init(godot_gdnative_init_options *o){
	Godot::gdnative_init(o);
}

extern "C" void GDN_EXPORT dsplib_gdnative_singleton(){
}

extern "C" void GDN_EXPORT dsplib_gdnative_terminate(godot_gdnative_terminate_options *o){
	Godot::gdnative_terminate(o);
}

extern "C" void GDN_EXPORT dsplib_nativescript_init(void *handle){
	Godot::nativescript_init(handle);
	register_class<DSPLib>();
}

void DSPLib::_register_methods(){
	register_method("add_sound_streams", &DSPLib::addSoundStreams);
	register_method("mix_waves", &DSPLib::mixWaves);
	register_method("noise", &DSPLib::noise);
	register_method("sine", &DSPLib::sine);
	register_method("rectangle", &DSPLib::rectangle);
	register_method("saw", &DSPLib::saw);
	register_method("triangle", &DSPLib::triangle);
	register_method("normalize", &DSPLib::normalize);
	register_method("convolution_filter", &DSPLib::convolutionFilter);
	register_method("clamp", &DSPLib::clamp);
	register_method("quantize", &DSPLib::quantize);
}

DSPLib::DSPLib(){
	float f=(1.0f/16384.0f)*Math_PI*0.5;
	for(int i=0;i<16384;i++){
		sineTable[i]=Math::sin(i*f);
	}
}

DSPLib::~DSPLib(){
}

void DSPLib::_init(){
}


Array DSPLib::addSoundStreams(Array a,Array b){
	if(a.size()<b.size()){
		for(int i=a.size()-1;i>-1;i--){
			a[i]=((Vector2)a[i])+((Vector2)b[i]);
		}
		return a;
	}else{
		for(int i=b.size()-1;i>-1;i--){
			b[i]=((Vector2)a[i])+((Vector2)b[i]);
		}
		return b;
	}
}

Array DSPLib::mixWaves(Array input,Array generated,Array modulator,Array output,float am,float xm,float vol,int mode){
	switch(mode){
	case REPLACE:
		output.resize(generated.size());
		for(int i=generated.size()-1;i>-1;i--){
			output[i]=variant2Float(generated[i])*
				Math::lerp(1.0f,full2Positive(variant2Float(modulator[i])),am)*
				Math::lerp(1.0f,variant2Float(modulator[i]),xm);
		}
		return output;
	case ADD:
		output.resize(generated.size());
		for(int i=generated.size()-1;i>-1;i--){
			output[i]=variant2Float(input[i])+(
				variant2Float(generated[i])*
				Math::lerp(1.0f,full2Positive(variant2Float(modulator[i])),am)*
				Math::lerp(1.0f,variant2Float(modulator[i]),xm)
			);
		}
		return output;
	case AM:
		output.resize(generated.size());
		for(int i=generated.size()-1;i>-1;i--){
			output[i]=variant2Float(input[i])*Math::lerp(1.0f,full2Positive(
				variant2Float(generated[i])*
				Math::lerp(1.0f,full2Positive(variant2Float(modulator[i])),am)*
				Math::lerp(1.0f,variant2Float(modulator[i]),xm)
			),vol);
		}
		return output;
	case XM:
		output.resize(generated.size());
		for(int i=generated.size()-1;i>-1;i--){
			output[i]=variant2Float(input[i])*Math::lerp(1.0f,
				variant2Float(generated[i])*
				Math::lerp(1.0f,full2Positive(variant2Float(modulator[i])),am)
				*Math::lerp(1.0f,variant2Float(modulator[i]),xm),
			vol);
		}
		return output;
	}
	return input;
}

void DSPLib::noise(
	Array input,Array output,
	float pos0,float length,
	int64_t seed,float tone,float power,
	float vol,int mode
){
	vol=(mode!=REPLACE && mode!=ADD)?1.0f:vol;
	randomSeed=seed;
	float fract=0.0f;
	int size=input.size();
	int phi0=pos0*size;
	int range=length*size;
	float v0=randSample();
	float v1=randSample();
	float vmin=std::numeric_limits<float>::max();
	float vmax=-std::numeric_limits<float>::max();
	for(int i=0,j=phi0%size;i<size;i++,j=(j+1)%size){
		if(i<=range){
			fract+=tone;
			if(fract>=1.0f){
				fract-=1.0f;
				v0=v1;
				v1=randSample();
			}
			float v=Math::lerp(v0,v1,ease(fract));
			output[j]=v;
			vmin=(v<vmin)?v:vmin;
			vmax=(v>vmax)?v:vmax;
		}else if(mode==REPLACE){
			output[j]=input[j];
		}else{
			output[j]=0.0f;
		}
	}
	for(int i=0,j=phi0%size;i<range;i++,j=(j+1)%size){
		output[j]=abspow(Math::range_lerp(variant2Float(output[j]),vmin,vmax,-1.0f,1.0f),power)*vol;
	}
}

void DSPLib::sine(
	Array input,Array output,Array modulator,
	float pos0,float offset,float freqMult,float cycles,
	float pm,float power,float decay,
	float vol,int mode,
	int q0,int q1,int q2,int q3
){
	vol=(mode!=REPLACE && mode!=ADD)?1.0f:vol;
	int quadrants[]={q0,q1,q2,q3};
	int size=input.size();
	int sz1=size-1;
	int range=(size*cycles)/freqMult;
	uint64_t dphi=(FIXP_1*freqMult)/size;
	uint64_t phi=(uint64_t)(offset*FIXP_1)&FIXP_1MASK;
	I2FConverter v0;
	v0.f=-vol;
	float v;
	decay=1.0f-((decay/size)*64.0f);
	float dec=1.0f;
	for(int i=0,j=(int)(pos0*size)&sz1;i<size;i++,j=(j+1)&sz1){
		if(cycles>0.0f && i>=range){
			output[j]=(mode==REPLACE)?variant2Float(input[j]):0.0f;
			continue;
		}
		uint64_t rphi=phi+(variant2Float(modulator[i])*pm*FIXP_1);
		float values[]={
			sineTable[(rphi>>24UL)&0x3fffUL],sineTable[(~rphi>>24UL)&0x3fffUL],
			-sineTable[(rphi>>24UL)&0x3fffUL],-sineTable[(~rphi>>24UL)&0x3fffUL],
			0.0f,1.0f,-1.0f
		};
		v=abspow(values[quadrants[(rphi>>38UL)&3]],power);
		calc_decay(dec,decay,v0,v);
		output[j]=v*dec*vol;
		phi+=dphi;
	}
}

void DSPLib::rectangle(
	Array input,Array output,Array modulator,
	float pos0,float offset,float freqMult,float cycles,
	float pm,float decay,
	float vol,int mode,
	float zStart,float nStart
){
	vol=(mode!=REPLACE && mode!=ADD)?1.0f:vol;
	int size=input.size();
	int sz1=size-1;
	int range=(size*cycles)/freqMult;
	uint64_t dphi=(FIXP_1*freqMult)/size;
	uint64_t phi=(uint64_t)(offset*FIXP_1)&FIXP_1MASK;
	uint64_t zs=(uint64_t)(zStart*FIXP_1)&FIXP_1MASK;
	uint64_t ns=(uint64_t)(nStart*FIXP_1)&FIXP_1MASK;
	I2FConverter v0;
	v0.f=-vol;
	float v;
	decay=1.0f-((decay/size)*64.0f);
	float dec=1.0f;
	for(int i=0,j=(int)(pos0*size)&sz1;i<size;i++,j=(j+1)&sz1){
		if(cycles>0.0f && i>=range){
			output[j]=(mode==REPLACE)?variant2Float(input[j]):0.0f;
			continue;
		}
		uint64_t rphi=(uint64_t)(phi+(variant2Float(modulator[i])*pm*FIXP_1))&FIXP_1MASK;
		if(rphi>ns){
			v=-vol;
		}else if(rphi>zs){
			v=0.0f;
		}else{
			v=vol;
		}
		calc_decay(dec,decay,v0,v);
		output[j]=v*dec;
		phi+=dphi;
	}
}

void DSPLib::saw(
	Array input,Array output,Array modulator,
	float pos0,float offset,float freqMult,float cycles,
	float pm,float power,float decay,
	float vol,int mode,
	int q0,int q1,int q2,int q3
){
	vol=(mode!=REPLACE && mode!=ADD)?1.0f:vol;
	int quarters[]={q0,q1,q2,q3};
	int size=input.size();
	int sz1=size-1;
	int range=(size*cycles)/freqMult;
	uint64_t dphi=(FIXP_1*freqMult)/size;
	uint64_t phi=(uint64_t)(offset*FIXP_1)&FIXP_1MASK;
	I2FConverter i2f;
	I2FConverter v0;
	v0.f=-vol;
	float v;
	decay=1.0f-((decay/size)*64.0f);
	float dec=1.0f;
	for(int i=0,j=(int)(pos0*size)&sz1;i<size;i++,j=(j+1)&sz1){
		if(cycles>0.0f && i>=range){
			output[j]=(mode==REPLACE)?variant2Float(input[j]):0.0f;
			continue;
		}
		uint64_t rphi=(uint64_t)(phi+(variant2Float(modulator[i])*pm*FIXP_1))&FIXP_1MASK;
		i2f.setMantissa((rphi>>16)&0x3fffff);
		float values[]={i2f.f-1.0f,i2f.f-0.5f,i2f.f,i2f.f+0.5f,1.0f-i2f.f,0.5f-i2f.f,-i2f.f,-i2f.f-0.5f,1.0f,0.5f,0.0f,-0.5f,-1.0f};
		v=abspow(values[quarters[(rphi>>38)&3]],power);
		calc_decay(dec,decay,v0,v);
		output[j]=v*dec*vol;
		phi+=dphi;
	}
}

void DSPLib::triangle(
	Array input,Array output,Array modulator,
	float pos0,float offset,float freqMult,float cycles,
	float pm,float power,float decay,
	float vol,int mode,
	int q0,int q1,int q2,int q3
){
	vol=(mode!=REPLACE && mode!=ADD)?1.0f:vol;
	int quarters[]={q0,q1,q2,q3};
	int size=input.size();
	int sz1=size-1;
	int range=(size*cycles)/freqMult;
	uint64_t dphi=(FIXP_1*freqMult)/size;
	uint64_t phi=(uint64_t)(offset*FIXP_1)&FIXP_1MASK;
	I2FConverter i2f;
	I2FConverter v0;
	v0.f=-vol;
	float v;
	decay=1.0f-((decay/size)*64.0f);
	float dec=1.0f;
	for(int i=0,j=(int)(pos0*size)&sz1;i<size;i++,j=(j+1)&sz1){
		if(cycles>0.0f && i>=range){
			output[j]=(mode==REPLACE)?variant2Float(input[j]):0.0f;
			continue;
		}
		uint64_t rphi=(uint64_t)(phi+(variant2Float(modulator[i])*pm*FIXP_1))&FIXP_1MASK;
		i2f.setMantissa(rphi>>15);
		i2f.f=i2f.f-1.0f;
		float values[]={i2f.f,i2f.f+1.0f,-i2f.f,-i2f.f-1.0f,1.0f,0.0f,-1.0f};
		v=abspow(values[quarters[(rphi>>38)&3]],power);
		calc_decay(dec,decay,v0,v);
		output[j]=v*dec*vol;
		phi+=dphi;
	}
}

void DSPLib::normalize(Array input,Array output,bool keepCenter){
	float vMax=input.max();
	float vMin=input.min();
	if (keepCenter){
		vMax=Math::max(abs(vMax),abs(vMin));
		for(int i=input.size()-1;i>-1;i--){
			output[i]=Math::range_lerp(variant2Float(input[i]),-vMax,vMax,-1.0f,1.0f);
		}
	}else{
		for(int i=input.size()-1;i>-1;i--){
			output[i]=Math::range_lerp(variant2Float(input[i]),vMin,vMax,-1.0f,1.0f);
		}
	}
}

void DSPLib::convolutionFilter(Array input,Array output,Array coeffs){
	float *in=arrayG2C(input);
	float *co=arrayG2C(coeffs);
	int mask=input.size()-1;
	int taps=coeffs.size();
	for(int i=mask;i>-1;i--){
		float val=0.0f;
		for(int j=taps-1,k=-(taps>>1);j>-1;j--,k++){
			val+=in[(i+k)&mask]*co[j];
		}
		output[i]=val;
	}
	delete[] in;
	delete[] co;
}

void DSPLib::clamp(Array input,Array output,float loLevel,float hiLevel,bool loClamp,bool hiClamp){
	for(int i=input.size()-1;i>-1;i--){
		float v=variant2Float(input[i]);
		output[i]=Math::clamp(v,loClamp?loLevel:v,hiClamp?hiLevel:v);
	}
}

void DSPLib::quantize(Array input,Array output,int steps){
	float st=2.0f/(steps-1.0f);
	for(int i=input.size()-1;i>-1;i--){
		output[i]=Math::stepify(variant2Float(input[i])+1.0f,st)-1.0f;
	}
}
