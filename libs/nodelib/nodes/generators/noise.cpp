using namespace godot;

void NodeLib::noise(Array output,int segment_size,int outptr,
	int64_t seed,Array amplitude,Array decay,Array power,Array dc,Array octaves,Array frequency,
	Array persistence,Array lacunarity,Array randomness
){
	Ref<OpenSimplexNoise> noiser=Ref<OpenSimplexNoise>();
	noiser.instance();
	noiser->set_seed(seed);
	noiser->set_period(1.0);
	Random random(seed);
	int size_mask=output.size()-1;
	double cycle=1.0/Math::max(1.0,(double)segment_size);
	double phi=0.0;
	double t;
	int ptr=outptr;
	I2DConverter i2d;
	Decay decayer(segment_size);
	for(int i=segment_size;i;i--){
		noiser->set_octaves(octaves[ptr]);
		t=(double)frequency[ptr];
		noiser->set_persistence(persistence[ptr]);
		noiser->set_lacunarity(lacunarity[ptr]);
		i2d.d=Math::lerp((double)noiser->get_noise_1d(phi*t),(double)noiser->get_noise_1d((phi*t)-t),phi)
			+random.next((double)randomness[ptr]);
		output[ptr]=(double)dc[ptr]+decayer.next(i2d.abspow((double)power[ptr]),(double)decay[ptr])*(double)amplitude[ptr];
		ptr=(ptr+1)&size_mask;
		phi+=cycle;
	}
}
