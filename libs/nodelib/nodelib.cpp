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
	enum{
		HI,LO,HILO,
		HI_FULL,LO_FULL,HILO_FULL
	};
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
		if (i<segment_size && !std::isnan(t)){
			hi=t>hi?t:hi;
			lo=t<lo?t:lo;
		}
		t=(double)input[outptr];
		if (!std::isnan(t)){
			hi_full=t>hi_full?t:hi_full;
			lo_full=t<lo_full?t:lo_full;
		}
		outptr=(outptr+1)&size_mask;
	}
	if (hi_full==-INFINITY && lo_full==INFINITY){
		hi_lo[HI_FULL]=-INFINITY;
		hi_lo[LO_FULL]=-INFINITY;
		return;
	}
	if (hi==-INFINITY && lo==INFINITY){
		hi=1.0;
		lo=-1.0;
	}
	hi_lo[HI]=hi;
	hi_lo[LO]=lo;
	hi_lo[HILO]=Math::max(std::abs(hi),std::abs(lo));
	hi_lo[HI_FULL]=hi_full;
	hi_lo[LO_FULL]=lo_full;
	hi_lo[HILO_FULL]=Math::max(std::abs(hi_full),std::abs(lo_full));
}
