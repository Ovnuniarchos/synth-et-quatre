using namespace godot;

void NodeLib::map_range(Array output,int segment_size,int outptr,Array input,
	Array min_in,Array max_in,Array min_out,Array max_out,Array xerp_in,Array xerp_out,
	Array mix,Array clamp_mix,Array isolate,
	Array amplitude,Array power,Array decay,Array dc
){
	int size_mask=output.size()-1;
	double t;
	I2DConverter i2d;
	Decay decayer(segment_size);
	for(int i=segment_size;i;i--){
		i2d.d=t=(double)input[outptr];
		i2d.d=Math::lerp(Math::max(i2d.d,(double)min_in[outptr]),i2d.d,(double)xerp_in[outptr]);
		i2d.d=Math::lerp(Math::min(i2d.d,(double)max_in[outptr]),i2d.d,(double)xerp_out[outptr]);
		i2d.d=Math::range_lerp(
			i2d.d,
			(double)min_in[outptr],(double)max_in[outptr],
			(double)min_out[outptr],(double)max_out[outptr]
		);
		i2d.d=decayer.next(i2d.abspow((double)power[outptr]),(double)decay[outptr])*(double)amplitude[outptr]+(double)dc[outptr];
		output[outptr]=Math::lerp(t,i2d.d,Math::lerp((double)mix[outptr],Math::clamp((double)mix[outptr],0.0,1.0),(double)clamp_mix[outptr]));
		outptr=(outptr+1)&size_mask;
	}
	fill_out_of_region(segment_size,outptr,output,input,isolate);
}