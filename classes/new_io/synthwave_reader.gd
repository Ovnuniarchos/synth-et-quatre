extends SynthWaveIO
class_name SynthWaveReader


var readers:Dictionary={
	WaveComponentIO.NOISE_ID:null,
	WaveComponentIO.RECTANGLE_ID:null,
	WaveComponentIO.SAW_ID:null,
	WaveComponentIO.SINE_ID:null,
	WaveComponentIO.TRIANGLE_ID:null,
	WaveComponentIO.BPF_ID:null,
	WaveComponentIO.BRF_ID:null,
	WaveComponentIO.CLAMP_ID:null,
	WaveComponentIO.HPF_ID:null,
	WaveComponentIO.LPF_ID:null,
	WaveComponentIO.NORMALIZE_ID:null,
	WaveComponentIO.QUANTIZE_ID:null
}


func lazy_load(type:String,sw:SynthWave)->WaveComponentIO:
	var wio:WaveComponentIO
	if readers[type]==null:
		match type:
			WaveComponentIO.NOISE_ID:
				wio=NoiseWaveReader.new(sw.components)
			WaveComponentIO.RECTANGLE_ID:
				wio=RectangleWaveReader.new(sw.components)
			WaveComponentIO.SAW_ID:
				wio=SawWaveReader.new(sw.components)
			WaveComponentIO.SINE_ID:
				wio=SineWaveReader.new(sw.components)
			WaveComponentIO.TRIANGLE_ID:
				wio=TriangleWaveReader.new(sw.components)
			WaveComponentIO.BPF_ID:
				wio=BPFFilterReader.new(sw.components)
			WaveComponentIO.BRF_ID:
				wio=BRFFilterReader.new(sw.components)
			WaveComponentIO.CLAMP_ID:
				wio=ClampFilterReader.new(sw.components)
			WaveComponentIO.HPF_ID:
				wio=HPFFilterReader.new(sw.components)
			WaveComponentIO.LPF_ID:
				wio=LPFFilterReader.new(sw.components)
			WaveComponentIO.NORMALIZE_ID:
				wio=NormalizeFilterReader.new(sw.components)
			WaveComponentIO.QUANTIZE_ID:
				wio=QuantizeFilterReader.new(sw.components)
	else:
		wio=readers[type]
	wio.components=sw.components
	return wio


func deserialize(inf:ChunkedFile,header:Dictionary)->SynthWave:
	if not inf.is_chunk_valid(header,CHUNK_ID,CHUNK_VERSION):
		return null
	var w:SynthWave=SynthWave.new()
	w.size_po2=inf.get_8()
	w.name=inf.get_pascal_string()
	w.components=[]
	w.components.resize(inf.get_16())
	for i in w.components.size():
		var hdr:Dictionary=inf.get_chunk_header()
		var nw:WaveComponent=null
		if readers.has(hdr[ChunkedFile.CHUNK_ID]):
			nw=lazy_load(hdr[ChunkedFile.CHUNK_ID],w).deserialize(inf,hdr)
		else:
			inf.invalid_chunk(hdr)
			inf.skip_chunk(hdr)
			return null
		w.components[i]=nw
		inf.skip_chunk(hdr)
	w.resize_data(1<<w.size_po2)
	w.calculate()
	return w
