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
#include "nodes/transforms/normalize.cpp"
#include "nodes/transforms/power.cpp"
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
	register_method("pre_normalize", &NodeLib::pre_normalize);
	register_method("normalize", &NodeLib::normalize);
	register_method("power", &NodeLib::power);
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

