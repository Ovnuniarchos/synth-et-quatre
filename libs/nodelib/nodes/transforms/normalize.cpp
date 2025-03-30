using namespace godot;

void NodeLib::normalize(Array output,int segment_size,int outptr,
	double hi,double lo,double hilo,double hi_full,double lo_full,double hilo_full,
	Array input,Array keep_0,Array use_full,
	Array mix,Array clamp_mix,Array isolate,
	Array amplitude,Array power,Array decay
){
	int size_mask=output.size()-1;
	double full;
	double h,l,hl;
	double t;
	I2DConverter i2d;
	Decay decayer(segment_size);
	for(int i=segment_size;i;i--){
		full=(double)use_full[outptr];
		h=Math::lerp(hi,hi_full,full);
		l=Math::lerp(lo,lo_full,full);
		hl=Math::lerp(hilo,hilo_full,full);
		t=i2d.d=(double)input[outptr];
		i2d.d=Math::lerp(Math::range_lerp(i2d.d,l,h,-1.0,1.0),
			Math::range_lerp(i2d.d,-hl,hl,-1.0,1.0),
			(double)keep_0[outptr]
		);
		full=(double)mix[outptr];
		i2d.d=Math::lerp(t,i2d.d,Math::lerp(full,Math::clamp(full,0.0,1.0),(double)clamp_mix[outptr]));
		output[outptr]=decayer.next(i2d.abspow((double)power[outptr]),(double)decay[outptr])*(double)amplitude[outptr];
		outptr=(outptr+1)&size_mask;
	}
	fill_out_of_region(segment_size,outptr,output,input,isolate);
}