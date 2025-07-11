using namespace godot;

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

void NodeLib::highpass(Array output,int segment_size,int outptr,
	double cutoff_mul,int steps,
	Array input,Array cutoff,Array attenuation,Array resonance,
	Array mix,Array clamp_mix,Array isolate,
	Array amplitude,Array power,Array decay,Array dc
){
	if(segment_size>0){
		int size_mask=output.size()-1;
		VectorC data[3];
		std::vector<int> chunks=create_chunks(segment_size,outptr,steps);
		fft_convert(input,data[0]);
		fft(data[0],false);
		//
		data[1].resize(data[0].size());
		outptr=chunks[0]&size_mask;
		hp_coeffs(data[0],data[1],(double)cutoff[outptr]*cutoff_mul,(double)attenuation[outptr],(double)resonance[outptr]);
		fft(data[1],true);
		//
		data[2].resize(data[0].size());
		//
		I2DConverter i2d;
		Decay decayer(segment_size);
		for(int i=0;i<chunks.size();i+=2){
			outptr=(chunks[i]+chunks[i+1])&size_mask;
			hp_coeffs(data[0],data[2],(double)cutoff[outptr]*cutoff_mul,(double)attenuation[outptr],(double)resonance[outptr]);
			fft(data[2],true);
			outptr=chunks[i];
			double li=0.0,dli=1.0/chunks[i+1];
			for(int j=chunks[i+1];j>0;j--,li+=dli){
				if(std::isnan((double)input[outptr])){
					output[outptr]=input[outptr];
				}else{
					i2d.d=Math::lerp(data[1][outptr].real(),data[2][outptr].real(),li);
					i2d.d=(double)dc[outptr]+decayer.next(i2d.abspow((double)power[outptr]),(double)decay[outptr])*(double)amplitude[outptr];
					output[outptr]=Math::lerp((double)input[outptr],i2d.d,Math::lerp((double)mix[outptr],Math::clamp((double)mix[outptr],0.0,1.0),(double)clamp_mix[outptr]));
				}
				outptr=(outptr+1)&size_mask;
			}
			data[1].swap(data[2]);
		}
	}
	fill_out_of_region(segment_size,outptr,output,input,isolate);
}