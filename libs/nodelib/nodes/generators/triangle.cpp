using namespace godot;

void NodeLib::triangle(Array output,int segment_size,int outptr,
	Array frequency,Array amplitude,Array dphi,Array power,Array decay,Array dc,
	Array quarter0,Array quarter1,Array quarter2,Array quarter3
){
	Array quarter_values[]={quarter0,quarter1,quarter2,quarter3};
	int size_mask=output.size()-1;
	double cycle=1.0/Math::max(1.0,(double)segment_size);
	double phi=0.0;
	double alpha;
	double t;
	Decay decayer(segment_size);
	double quarters[]={0.0,0.0,0.0,0.0,1.0,0.0,-1.0};
	I2DConverter i2d;
	for(;segment_size;segment_size--){
		alpha=(phi*(double)frequency[outptr])+(double)dphi[outptr];
		t=fposmod(alpha,0.25)*4.0;
		quarters[0]=t;
		quarters[1]=1.0-t;
		quarters[2]=-t;
		quarters[3]=t-1.0;
		i2d.d=quarters[(int64_t)quarter_values[(int)(alpha*4.0)][outptr]];
		output[outptr]=decayer.next(i2d.abspow((double)power[outptr]),(double)decay[outptr])*(double)amplitude[outptr]+(double)dc[outptr];
		phi+=cycle;
		outptr=(outptr+1)&size_mask;
	}
}