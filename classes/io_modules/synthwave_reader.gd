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
	WaveComponentIO.QUANTIZE_ID:null,
	WaveComponentIO.POWER_ID:null,
	WaveComponentIO.DECAY_ID:null
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
			WaveComponentIO.POWER_ID:
				wio=PowerFilterReader.new(sw.components)
			WaveComponentIO.DECAY_ID:
				wio=DecayFilterReader.new(sw.components)
	else:
		wio=readers[type]
	wio.components=sw.components
	return wio


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,CHUNK_ID,CHUNK_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:CHUNK_ID,
			FileResult.ERRV_EXP_VERSION:CHUNK_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var w:SynthWave=SynthWave.new()
	w.size_po2=inf.get_8()
	w.name=inf.get_pascal_string()
	w.components=[]
	w.components.resize(inf.get_16())
	var fr:FileResult
	for i in w.components.size():
		var hdr:Dictionary=inf.get_chunk_header()
		if inf.get_error():
			return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
		if readers.has(inf.get_chunk_id(hdr)):
			fr=lazy_load(inf.get_chunk_id(hdr),w).deserialize(inf,hdr)
			if fr.has_error():
				return fr
			w.components[i]=fr.data
		else:
			inf.invalid_chunk(hdr)
			inf.skip_chunk(hdr)
			return FileResult.new(FileResult.ERR_BAD_WAVE_COMPONENT,{
				FileResult.ERRV_CHUNK:inf.get_chunk_id(hdr),FileResult.ERRV_FILE:inf.get_path()
			})
		inf.skip_chunk(hdr)
	w.resize_data(1<<w.size_po2)
	w.calculate()
	return FileResult.new(OK,w)
