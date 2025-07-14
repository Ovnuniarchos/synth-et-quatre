using namespace godot;

void NodeLib::power(Array output,int segment_size,int outptr,
	Array input,Array power,
	Array mix,Array clamp_mix,Array isolate,
	Array amplitude,Array decay,Array dc
){
	int size_mask=output.size()-1;
	double t;
	I2DConverter i2d;
	Decay decayer(segment_size);
	for(int i=segment_size;i;i--){
		t=i2d.d=(double)input[outptr];
		i2d.abspow((double)power[outptr]);
		i2d.d=decayer.next(i2d.d,(double)decay[outptr])*(double)amplitude[outptr]+(double)dc[outptr];
		output[outptr]=Math::lerp(t,i2d.d,Math::lerp((double)mix[outptr],Math::clamp((double)mix[outptr],0.0,1.0),(double)clamp_mix[outptr]));
		outptr=(outptr+1)&size_mask;
	}
	fill_out_of_region(segment_size,outptr,output,input,isolate);
}