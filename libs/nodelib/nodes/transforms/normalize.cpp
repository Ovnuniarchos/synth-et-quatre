using namespace godot;

void NodeLib::pre_normalize(Array input,int segment_size,int outptr,Array hi_lo){
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