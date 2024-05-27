extends SynthWaveIO
class_name SynthWaveReader


var readers:Dictionary={
	WaveComponentIO.NOISE_ID:NoiseWaveReader,
	WaveComponentIO.RECTANGLE_ID:RectangleWaveReader,
	WaveComponentIO.SAW_ID:SawWaveReader,
	WaveComponentIO.SINE_ID:SineWaveReader,
	WaveComponentIO.TRIANGLE_ID:TriangleWaveReader,
	WaveComponentIO.BPF_ID:BPFFilterReader,
	WaveComponentIO.BRF_ID:BRFFilterReader,
	WaveComponentIO.CLAMP_ID:ClampFilterReader,
	WaveComponentIO.HPF_ID:HPFFilterReader,
	WaveComponentIO.LPF_ID:LPFFilterReader,
	WaveComponentIO.NORMALIZE_ID:NormalizeFilterReader,
	WaveComponentIO.QUANTIZE_ID:QuantizeFilterReader,
	WaveComponentIO.POWER_ID:PowerFilterReader,
	WaveComponentIO.DECAY_ID:DecayFilterReader
}


func lazy_load(type:String,sw:SynthWave)->WaveComponentIO:
	if readers[type] is GDScript:
		readers[type]=readers[type].new([])
	var wio:WaveComponentIO=readers[type]
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
