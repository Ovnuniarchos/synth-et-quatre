using namespace godot;

void NodeLib::multiclamp(Array output,int segment_size,int outptr,Array input,
	Array level_hi,Array clamp_hi,Array mode_hi,
	Array level_lo,Array clamp_lo,Array mode_lo,
	Array mix,Array clamp_mix,Array isolate,
	Array amplitude,Array power,Array decay,Array dc
){
	enum{CLAMP_NN=0,CLAMP_NC,CLAMP_NW,CLAMP_NB,
		CLAMP_CN=8,CLAMP_CC,CLAMP_CW,CLAMP_CB,
		CLAMP_WN=16,CLAMP_WC,CLAMP_WW,CLAMP_WB,
		CLAMP_BN=24,CLAMP_BC,CLAMP_BW,CLAMP_BB
	};
	const int CLAMP_SHIFT=3;
	int size_mask=output.size()-1;
	int mode;
	int seg_size=segment_size;
	double mix_val;
	double t,t2;
	double lvl,lvh;
	double d,d2;
	I2DConverter i2d;
	Decay decayer(segment_size);
	for(;segment_size;segment_size--){
		double mix_val=Math::lerp((double)mix[outptr],Math::clamp((double)mix[outptr],0.0,1.0),(double)clamp_mix[outptr]);
		if (std::isnan((double)mode_hi[outptr]) || std::isnan((double)mode_lo[outptr])){
			mode=CLAMP_NN;
		}else{
			mode=(((int)mode_hi[outptr])<<CLAMP_SHIFT)|(int)mode_lo[outptr];
		}
		t2=t=(double)input[outptr];
		lvh=Math::lerp((double)level_hi[outptr],Math::clamp((double)level_hi[outptr],-1.0,1.0),(double)clamp_hi[outptr]);
		lvl=Math::lerp((double)level_lo[outptr],Math::clamp((double)level_lo[outptr],-1.0,1.0),(double)clamp_lo[outptr]);
		switch(mode){
			case CLAMP_NC:
				if (t<lvl) t=lvl;
				break;
			case CLAMP_NW:
				if (t<lvl) t=Math::wrapf(t,lvl,1.0);
			case CLAMP_NB:
				if (t<lvl) t=lvl-(t-lvl);
				break;
			case CLAMP_CN:
				if (t>lvh) t=lvh;
				break;
			case CLAMP_CC:
				t=Math::clamp(t,lvl,lvh);
				break;
			case CLAMP_CW:
				if (t<lvl) t=Math::wrapf(t,lvl,lvh);
				if (t>lvh) t=lvh;
				break;
			case CLAMP_CB:
				if (t<lvl) t=lvl-(t-lvl);
				if (t>lvh) t=lvh;
				break;
			case CLAMP_WN:
				if (t>lvh) t=Math::wrapf(t,-1.0,lvh);
				break;
			case CLAMP_WC:
				if (t>lvh) t=Math::wrapf(t,-1.0,lvh);
				if (t<lvl) t=lvl;
				break;
			case CLAMP_WW:
				t=Math::wrapf(t,lvl,lvh);
				break;
			case CLAMP_WB:
				if (t<lvl) t=lvl-(t-lvl);
				t=Math::wrapf(t,lvl,lvh);
				break;
			case CLAMP_BN:
				if (t>lvh) t=lvh-(t-lvh);
				break;
			case CLAMP_BC:
				if (t>lvh) t=lvh-(t-lvh);
				if (t<lvl) t=lvl;
				break;
			case CLAMP_BW:
				if (t>lvh) t=lvh-(t-lvh);
				t=Math::wrapf(t,lvl,lvh);
				break;
			case CLAMP_BB:
				if (t<lvl || t>lvh){
					d=lvh-lvl;
					if (std::isnan(d) || Math::is_zero_approx(d)){
						t=(lvh+lvl)*0.5;
					}else if (t<lvl){
						d2=fposmod((t-lvl)/d,2.0);
						t=fposmod(t-lvl,std::abs(d));
						if (d2<1.0){
							t=lvl+t;
						}else{
							t=lvh-t;
						}
					}else{
						d2=fposmod((t-lvh)/d,2.0);
						t=fposmod(t-lvh,std::abs(d));
						if (d2<1.0){
							t=lvh-t;
						}else{
							t=lvl+t;
						}
					}
				}
		}
		i2d.d=Math::lerp(t2,t,mix_val);
		output[outptr]=decayer.next(i2d.abspow((double)power[outptr]),(double)decay[outptr])*(double)amplitude[outptr]+(double)dc[outptr];
		outptr=(outptr+1)&size_mask;
	}
	fill_out_of_region(seg_size,outptr,output,input,isolate);
}