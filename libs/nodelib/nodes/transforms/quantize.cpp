using namespace godot;

void NodeLib::quantize(Array output,int segment_size,int outptr,
	double hi,double lo,double hi_full,double lo_full,
	Array input,Array levels,Array dither,Array use_full,Array full_amplitude,
	Array mix,Array clamp_mix,Array isolate,
	Array amplitude,Array power,Array decay
){
	int size_mask=output.size()-1;
	double full_seg,full_amp;
	double h,l,t;
	double steps;
	double dit=0.0;
	I2DConverter i2d;
	Decay decayer(segment_size);
	for(int i=segment_size;i;i--){
		full_seg=(double)use_full[outptr];
		full_amp=(double)full_amplitude[outptr];
		h=Math::lerp(1.0,Math::lerp(hi,hi_full,full_seg),full_amp);
		l=Math::lerp(-1.0,Math::lerp(lo,lo_full,full_seg),full_amp);
		h-=l;
		steps=h/((double)levels[outptr]-1.0);
		t=(double)input[outptr];
		i2d.d=Math::stepify(dit+t-l,steps)+l;
		dit=(dit+t-i2d.d)*(double)dither[outptr];
		i2d.d=Math::lerp(t,i2d.d,Math::lerp((double)mix[outptr],Math::clamp((double)mix[outptr],0.0,1.0),(double)clamp_mix[outptr]));
		output[outptr]=decayer.next(i2d.abspow((double)power[outptr]),(double)decay[outptr])*(double)amplitude[outptr];
		outptr=(outptr+1)&size_mask;
	}
	fill_out_of_region(segment_size,outptr,output,input,isolate);
}
