#include "nodelib.h"
#include "nodes/processors.cpp"
#include "nodes/generators/noise.cpp"
#include "nodes/generators/pulse.cpp"
#include "nodes/generators/ramp.cpp"
#include "nodes/generators/saw.cpp"
#include "nodes/generators/sine.cpp"
#include "nodes/generators/triangle.cpp"
#include "nodes/transforms/multiclamp.cpp"
#include "nodes/transforms/clip.cpp"
#include "nodes/transforms/decay.cpp"
#include "nodes/transforms/map_range.cpp"
#include "nodes/transforms/map_wave.cpp"
#include "nodes/transforms/mix.cpp"
#include "nodes/transforms/mux.cpp"
#include "nodes/transforms/normalize.cpp"
#include "nodes/transforms/power.cpp"
#include "nodes/transforms/quantize.cpp"
#include "nodes/transforms/decimate.cpp"
#include "nodes/transforms/lowpass.cpp"
#include <cstdio>


using namespace godot;

extern "C" void GDN_EXPORT nodelib_gdnative_init(godot_gdnative_init_options *o){
	Godot::gdnative_init(o);
}

extern "C" void GDN_EXPORT nodelib_gdnative_singleton(){
}

extern "C" void GDN_EXPORT nodelib_gdnative_terminate(godot_gdnative_terminate_options *o){
	Godot::gdnative_terminate(o);
}

extern "C" void GDN_EXPORT nodelib_nativescript_init(void *handle){
	Godot::nativescript_init(handle);
	register_class<NodeLib>();
}

void NodeLib::_register_methods(){
	register_method("accumulate", &NodeLib::accumulate);
	register_method("de_nan_ize", &NodeLib::de_nan_ize);
	register_method("optionize", &NodeLib::optionize);
	register_method("booleanize", &NodeLib::booleanize);
	register_method("diff_booleanize", &NodeLib::diff_booleanize);
	register_method("clamp", &NodeLib::clamp);
	//
	register_method("noise", &NodeLib::noise);
	register_method("pulse", &NodeLib::pulse);
	register_method("ramp", &NodeLib::ramp);
	register_method("saw", &NodeLib::saw);
	register_method("sine", &NodeLib::sine);
	register_method("triangle", &NodeLib::triangle);
	//
	register_method("multiclamp", &NodeLib::multiclamp);
	register_method("clip", &NodeLib::clip);
	register_method("decay", &NodeLib::decay);
	register_method("map_range", &NodeLib::map_range);
	register_method("map_wave", &NodeLib::map_wave);
	register_method("mix", &NodeLib::mix);
	register_method("mux", &NodeLib::mux);
	register_method("find_amplitude_bounds", &NodeLib::find_amplitude_bounds);
	register_method("normalize", &NodeLib::normalize);
	register_method("power", &NodeLib::power);
	register_method("quantize", &NodeLib::quantize);
	register_method("decimate", &NodeLib::decimate);
	register_method("lowpass", &NodeLib::lowpass);
}

NodeLib::NodeLib(){
	double f=(1.0/16384.0)*Math_PI*0.5;
	for(int i=0;i<16384;i++){
		sineTable[i]=Math::sin(i*f);
	}
}

NodeLib::~NodeLib(){
}

void NodeLib::_init(){
}

void NodeLib::fill_out_of_region(int segment_size,int outptr,Array output,Array input,Array isolate){
	int size_mask=output.size()-1;
	segment_size=output.size()-segment_size;
	for(;segment_size;segment_size--){
		if ((double)isolate[outptr]<0.5) output[outptr]=input[outptr];
		outptr=(outptr+1)&size_mask;
	}
}

void NodeLib::find_amplitude_bounds(Array input,int segment_size,int outptr,Array hi_lo){
	int size=input.size();
	int size_mask=size-1;
	double t;
	double range;
	double range_full;
	double hi=-INFINITY;
	double lo=INFINITY;
	double hi_full=-INFINITY;
	double lo_full=INFINITY;
	for(int i=0;i<size;i++){
		t=(double)input[outptr];
		if(!std::isnan(t)){
			if(i<segment_size){
				hi=t>hi?t:hi;
				lo=t<lo?t:lo;
			}
			hi_full=t>hi_full?t:hi_full;
			lo_full=t<lo_full?t:lo_full;
		}
		outptr=(outptr+1)&size_mask;
	}
	if (hi_full==-INFINITY && lo_full==INFINITY){
		hi_lo[HILO_FULL]=INFINITY;
		return;
	}
	hi_lo[HI_FULL]=hi_full;
	hi_lo[LO_FULL]=lo_full;
	hi_lo[HILO_FULL]=Math::max(std::abs(hi_full),std::abs(lo_full));
	if (hi==-INFINITY && lo==INFINITY){
		hi_lo[HILO]=INFINITY;
		return;
	}
	hi_lo[HI]=hi;
	hi_lo[LO]=lo;
	hi_lo[HILO]=Math::max(std::abs(hi),std::abs(lo));
}

void NodeLib::fft(std::vector<Complex> &data,bool inverse){
	unsigned int N=data.size(),k=N,n;
	double thetaT=Math_PI/N;
	Complex phiT=Complex(std::cos(thetaT),-std::sin(thetaT)),T;
	while(k>1){
		n=k;
		k>>=1;
		phiT=phiT*phiT;
		T=1.0;
		for(unsigned int l=0;l<k;l++){
			for(unsigned int a=l;a<N;a+=n){
				unsigned int b=a+k;
				Complex t=data[a]-data[b];
				data[a]+=data[b];
				data[b]=t*T;
			}
			T*=phiT;
		}
	}
	unsigned int m=(unsigned int)std::log2(N);
	double sum=-INFINITY;
	for (unsigned int a=0;a<N;a++){
		unsigned int b=a;
		b=(((b&0xaaaaaaaa)>>1)|((b&0x55555555)<<1));
		b=(((b&0xcccccccc)>>2)|((b&0x33333333)<<2));
		b=(((b&0xf0f0f0f0)>>4)|((b&0x0f0f0f0f)<<4));
		b=(((b&0xff00ff00)>>8)|((b&0x00ff00ff)<<8));
		b=((b>>16)|(b<<16))>>(32-m);
		if(b>a){
			Complex t=data[a];
			data[a]=data[b];
			data[b]=t;
		}
		if(std::abs(data[a].real())>sum) sum=std::abs(data[a].real());
	}
	if(inverse){
		// If its an IFFT, we use the calculated factor
		double factor=1.0/std::max(std::abs(sum),(double)N);
		for(int i=0;i<N;i++) data[i].real(data[i].real()*factor);
	}else{
		for(int i=0;i<N;i++) data[i].imag(-data[i].imag());
	}
}

std::vector<int> NodeLib::create_chunks(int segment_size,int outptr,int steps){
	std::vector<int> chunks=std::vector<int>(0);
	int pos=0,npos;
	int opos=-1,onpos=-1;
	for(int i=0;i<steps;i++){
		npos=((i+1)*segment_size)/steps;
		if (pos!=npos && pos!=opos && npos!=onpos){
			chunks.push_back(pos+outptr);
			chunks.push_back(npos-pos);
			opos=pos;
			onpos=npos;
			pos=npos;
		}
	}
	npos=segment_size;
	if (pos<segment_size && pos!=opos && npos!=onpos){
		chunks.push_back(pos+outptr);
		chunks.push_back(npos-pos);
	}
	return chunks;
}

