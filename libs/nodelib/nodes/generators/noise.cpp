using namespace godot;

void NodeLib::noise(Array output,int segment_size,int outptr,
	int64_t seed,Array amplitude,Array decay,Array power,Array dc,Array octaves,Array frequency,
	Array persistence,Array lacunarity,Array randomness
){
	Ref<OpenSimplexNoise> noiser=Ref<OpenSimplexNoise>();
	noiser.instance();
	noiser->set_seed(seed);
	Random random(seed);
	int size_mask=output.size()-1;
	double cycle=1.0/Math::max(1.0,(double)segment_size);
	double minval=std::numeric_limits<double>::max();
	double maxval=-minval;
	double phi=0.0;
	double t;
	int ptr=outptr;
	I2DConverter i2d;
	for(int i=segment_size;i;i--){
		noiser->set_octaves(octaves[ptr]);
		t=(double)frequency[ptr];
		noiser->set_period(abs(t)>0.0001?(1.0/t):0.0);
		noiser->set_persistence(persistence[ptr]);
		noiser->set_lacunarity(lacunarity[ptr]);
		i2d.d=Math::lerp((double)noiser->get_noise_1d(phi),(double)noiser->get_noise_1d(phi-1.0),phi)
			+random.next((double)randomness[ptr]);
		output[ptr]=i2d.abspow((double)power[ptr]);
		minval=i2d.d<minval?i2d.d:minval;
		maxval=i2d.d>maxval?i2d.d:maxval;
		ptr=(ptr+1)&size_mask;
		phi+=cycle;
	}
	Decay decayer(segment_size);
	ptr=outptr;
	for(;segment_size;segment_size--){
		t=(double)amplitude[ptr];
		output[ptr]=decayer.next(Math::range_lerp((double)output[ptr],minval,maxval,-t,t)+(double)dc[ptr],(double)decay[ptr]);
		ptr=(ptr+1)&size_mask;
	}
}
