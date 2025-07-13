using namespace godot;

void NodeLib::lp_coeffs(VectorC &source,VectorC &dest,int cutoff,double attenuation,double resonance){
	int end=source.size();
	int sz2=(source.size()>>1)-1;
	double attn=1.0;
	double attf=1.0/std::log(2);
	dest[0]=source[0];
	for(int i=1;i<sz2;i++){
		attn=(std::pow(0.5,std::abs(cutoff-i))*resonance)+1.0;
		if(i>cutoff){
			attn*=std::pow(attenuation,std::log(i-cutoff)*attf);
		}
		dest[i]=source[i]*attn;
		dest[end-i]=source[end-i]*attn;
	}
	sz2++;
	if(sz2>cutoff){
		attn*=attenuation;
		dest[sz2]=source[sz2];
	}
}

void NodeLib::hp_coeffs(VectorC &source,VectorC &dest,int cutoff,double attenuation,double resonance){
	int end=source.size();
	int sz2=(source.size()>>1)-1;
	double attn=1.0;
	double attf=1.0/std::log(2);
	dest[0]=source[0];
	for(int i=1;i<sz2;i++){
		attn=(std::pow(0.5,std::abs(cutoff-i))*resonance)+1.0;
		if(i<cutoff){
			attn*=std::pow(attenuation,std::log(cutoff-i)*attf);
		}
		dest[i]=source[i]*attn;
		dest[end-i]=source[end-i]*attn;
	}
	sz2++;
	if(sz2>cutoff){
		attn*=attenuation;
		dest[sz2]=source[sz2];
	}
}

void NodeLib::bp_coeffs(VectorC &source,VectorC &dest,int cutofflo,int cutoffhi,double attenuation,double resonance){
	int end=source.size();
	int sz2=(source.size()>>1)-1;
	double attn=1.0;
	double attf=1.0/std::log(2);
	dest[0]=source[0];
	for(int i=1;i<sz2;i++){
		attn=(std::pow(0.5,std::min(std::abs(cutoffhi-i),std::abs(i-cutofflo)))*resonance)+1.0;
		if(i>cutoffhi){
			attn*=std::pow(attenuation,std::log(i-cutoffhi)*attf);
		}
		if(i<cutofflo){
			attn*=std::pow(attenuation,std::log(cutofflo-i)*attf);
		}
		dest[i]=source[i]*attn;
		dest[end-i]=source[end-i]*attn;
	}
	sz2++;
	if(sz2>cutoffhi){
		attn*=attenuation;
		dest[sz2]=source[sz2];
	}
}

void NodeLib::br_coeffs(VectorC &source,VectorC &dest,int cutofflo,int cutoffhi,double attenuation,double resonance){
	int end=source.size();
	int sz2=(source.size()>>1)-1;
	double attn=1.0;
	double attf=1.0/std::log(2);
	dest[0]=source[0];
	for(int i=1;i<sz2;i++){
		attn=(std::pow(0.5,std::min(std::abs(cutoffhi-i),std::abs(i-cutofflo)))*resonance)+1.0;
		if(i<cutoffhi && i>cutofflo){
			attn*=std::pow(attenuation,std::log(cutoffhi-i)*attf);
			attn*=std::pow(attenuation,std::log(i-cutofflo)*attf);
		}
		dest[i]=source[i]*attn;
		dest[end-i]=source[end-i]*attn;
	}
	sz2++;
	if(sz2>cutoffhi){
		attn*=attenuation;
		dest[sz2]=source[sz2];
	}
}

void NodeLib::lowpass(Array output,int segment_size,int outptr,
	double cutoff_mul,int steps,
	Array input,Array cutoff,Array attenuation,Array resonance,
	Array mix,Array clamp_mix,Array isolate,
	Array amplitude,Array power,Array decay,Array dc
){
	double cutoff_muls[]={cutoff_mul};
	Array cutoffs[]={cutoff};
	multi_fft(output,segment_size,outptr,cutoff_muls,steps,LOPASS,
		input,cutoffs,attenuation,resonance,
		mix,clamp_mix,isolate,
		amplitude,power,decay,dc
	);
}

void NodeLib::highpass(Array output,int segment_size,int outptr,
	double cutoff_mul,int steps,
	Array input,Array cutoff,Array attenuation,Array resonance,
	Array mix,Array clamp_mix,Array isolate,
	Array amplitude,Array power,Array decay,Array dc
){
	double cutoff_muls[]={cutoff_mul};
	Array cutoffs[]={cutoff};
	multi_fft(output,segment_size,outptr,cutoff_muls,steps,HIPASS,
		input,cutoffs,attenuation,resonance,
		mix,clamp_mix,isolate,
		amplitude,power,decay,dc
	);
}

void NodeLib::bandpass(Array output,int segment_size,int outptr,
	double cutofflo_mul,double cutoffhi_mul,int steps,
	Array input,Array cutofflo,Array cutoffhi,Array attenuation,Array resonance,
	Array mix,Array clamp_mix,Array isolate,
	Array amplitude,Array power,Array decay,Array dc
){
	double cutoff_muls[]={cutofflo_mul,cutoffhi_mul};
	Array cutoffs[]={cutofflo,cutoffhi};
	multi_fft(output,segment_size,outptr,cutoff_muls,steps,BANDPASS,
		input,cutoffs,attenuation,resonance,
		mix,clamp_mix,isolate,
		amplitude,power,decay,dc
	);
}

void NodeLib::bandreject(Array output,int segment_size,int outptr,
	double cutofflo_mul,double cutoffhi_mul,int steps,
	Array input,Array cutofflo,Array cutoffhi,Array attenuation,Array resonance,
	Array mix,Array clamp_mix,Array isolate,
	Array amplitude,Array power,Array decay,Array dc
){
	double cutoff_muls[]={cutofflo_mul,cutoffhi_mul};
	Array cutoffs[]={cutofflo,cutoffhi};
	multi_fft(output,segment_size,outptr,cutoff_muls,steps,BANDREJECT,
		input,cutoffs,attenuation,resonance,
		mix,clamp_mix,isolate,
		amplitude,power,decay,dc
	);
}
