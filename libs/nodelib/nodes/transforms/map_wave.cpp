using namespace godot;

void NodeLib::map_wave(Array output,int segment_size,int outptr,Array input,
	Array map,double slope_neg,double slope_pos,Array lerp,Array xerp,
	Array mix,Array clamp_mix,Array map_empty,Array isolate,
	Array amplitude,Array power,Array decay,Array dc
){
	enum{LERP_NONE,LERP_LINEAR,LERP_COS};
	enum{XERP_CONSTANT,XERP_EXTEND,XERP_WRAP};

	double size=(double)output.size();
	double t1;
	int size_mask=output.size()-1;
	int mode;
	I2DConverter i2d;
	Decay decayer(segment_size);
	for(int i=segment_size;i;i--){
		i2d.d=(double)input[outptr];
		if (!std::isnan(i2d.d)){
			i2d.d=(i2d.d+1.0)*size*0.5;
			t1=i2d.d+1.0;
			mode=(int)xerp[outptr];
			if (mode==XERP_CONSTANT){
				i2d.d=Math::clamp(i2d.d,0.0,(double)size_mask);
				t1=Math::clamp(t1,0.0,(double)size_mask);
			}else if (mode==XERP_WRAP){
				i2d.d=fposmod(i2d.d,size);
				t1=fposmod(t1,size);
			}
			mode=(int)lerp[outptr];
			if (i2d.d<0.0){
				i2d.d=(double)map[0]-slope_neg*i2d.d;
			}else if (i2d.d>=size){
				i2d.d=(double)map[size_mask]+slope_pos*(i2d.d-1.0);
			}else if (mode==LERP_NONE){
				i2d.d=(double)map[i2d.d];
			}else if (mode==LERP_LINEAR){
				if (t1<0.0){
					t1=(double)map[0]-slope_neg*t1;
				}else if (t1>=size){
					t1=(double)map[size_mask]+slope_pos*(t1-1.0);
				}else{
					t1=(double)map[t1];
				}
				i2d.d=Math::lerp((double)map[i2d.d],t1,i2d.d-Math::floor(i2d.d));
			}else{
				if (t1<0.0){
					t1=(double)map[0]-slope_neg*t1;
				}else if (t1>=size){
					t1=(double)map[size_mask]+slope_pos*(t1-1.0);
				}else{
					t1=(double)map[t1];
				}
				i2d.d=Math::lerp(map[i2d.d],t1,(1.0-cos((i2d.d-floor(i2d.d))*Math_PI))*0.5);
			}
		}
		if ((double)map_empty[outptr]<0.5 && std::isnan(i2d.d)){
			i2d.d=(double)input[outptr];
		}
		output[outptr]=decayer.next(i2d.abspow((double)power[outptr]),(double)decay[outptr])*(double)amplitude[outptr]+(double)dc[outptr];
		outptr=(outptr+1)&size_mask;
	}
	fill_out_of_region(segment_size,outptr,output,input,isolate);
}