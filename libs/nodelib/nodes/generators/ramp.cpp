using namespace godot;

void NodeLib::ramp(Array output,int segment_size,int outptr,
	double ramp_from,double ramp_to,double curve
){
	int size_mask=output.size()-1;
	double cycle=1.0/Math::max(1.0,(double)segment_size);
	double phi=0.0;
	Decay decayer(segment_size);
	for(;segment_size;segment_size--){
		output[outptr]=Math::lerp(ramp_from,ramp_to,ease(phi,curve));
		phi+=cycle;
		outptr=(outptr+1)&size_mask;
	}
}
