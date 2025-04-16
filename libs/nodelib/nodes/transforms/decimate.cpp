using namespace godot;

void NodeLib::decimate(Array output,int segment_size,int outptr,
	Array input,Array samples,Array use_full,Array lerp,
	Array mix,Array clamp_mix,Array isolate,
	Array amplitude,Array power,Array decay
){
	enum{LERP_NONE,LERP_LINEAR,LERP_COS};

	int size_mask=output.size()-1;
	double sample_size,full_sample_size;
	double seg_size=segment_size,full_size=(double)output.size();
	double t,d;
	int j,lerp_mode;
	I2DConverter i2d;
	Decay decayer(segment_size);
	for(int i=segment_size;i;i--){
		sample_size=seg_size/(double)samples[outptr];
		full_sample_size=full_size/(double)samples[outptr];
		if (sample_size<=1.0){
			i2d.d=(double)input[outptr];
		}else{
			lerp_mode=(int)lerp[outptr];
			t=outptr/sample_size;
			j=Math::floor(t)*sample_size;
			i2d.d=(double)input[j&size_mask];
			if (lerp_mode){
				j+=sample_size;
				d=std::modf(t,&t);
				t=((double)input[j&size_mask])-i2d.d;
				if (lerp_mode==LERP_LINEAR){
					i2d.d+=t*d;
				}else{
					i2d.d+=t*(1.0-cos(d*Math_PI))*0.5;
				}
			}
		}
		i2d.d=Math::lerp((double)input[outptr],i2d.d,Math::lerp((double)mix[outptr],Math::clamp((double)mix[outptr],0.0,1.0),(double)clamp_mix[outptr]));
		output[outptr]=decayer.next(i2d.abspow((double)power[outptr]),(double)decay[outptr])*(double)amplitude[outptr];
		outptr=(outptr+1)&size_mask;
	}
	fill_out_of_region(segment_size,outptr,output,input,isolate);
}
