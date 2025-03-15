using namespace godot;

void NodeLib::pulse(Array output,int segment_size,int outptr,
	Array ppulse_start,Array ppulse_length,Array ppulse_amplitude,
	Array npulse_start,Array npulse_length,Array npulse_amplitude,
	Array frequency,Array amplitude,Array phi0,Array decay,Array dc
){
	int size_mask=output.size()-1;
	double cycle=1.0/Math::max(1.0,(double)segment_size);
	double pps,ppl,nps,npl;
	double phi;
	double iphi=0.0;
	double t;
	Decay decayer(segment_size);
	for(;segment_size;segment_size--){
		pps=fposmod((double)ppulse_start[outptr],1.0);
		ppl=Math::clamp((double)ppulse_length[outptr],0.0,1.0)+pps;
		nps=fposmod((double)npulse_start[outptr],1.0);
		npl=Math::clamp((double)npulse_length[outptr],0.0,1.0)+nps;
		phi=fposmod((iphi*(double)frequency[outptr])+(double)phi0[outptr],1.0);
		t=(to_double(phi<(ppl-1.0) || (phi>=pps && phi<ppl))*(double)ppulse_amplitude[outptr])
			-(to_double(phi<(npl-1.0) || (phi>=nps && phi<npl))*(double)npulse_amplitude[outptr]);
		output[outptr]=decayer.next(t,(double)decay[outptr])*(double)amplitude[outptr]+(double)dc[outptr];
		iphi+=cycle;
		outptr=(outptr+1)&size_mask;
	}
}
