extends SynthWaveIO
class_name SynthWaveWriter


var writers:Dictionary={
	NoiseWave.COMPONENT_ID:NoiseWaveWriter,
	RectangleWave.COMPONENT_ID:RectangleWaveWriter,
	SawWave.COMPONENT_ID:SawWaveWriter,
	SineWave.COMPONENT_ID:SineWaveWriter,
	TriangleWave.COMPONENT_ID:TriangleWaveWriter,
	BpfFilter.COMPONENT_ID:BPFFilterWriter,
	BrfFilter.COMPONENT_ID:BRFFilterWriter,
	ClampFilter.COMPONENT_ID:ClampFilterWriter,
	HpfFilter.COMPONENT_ID:HPFFilterWriter,
	LpfFilter.COMPONENT_ID:LPFFilterWriter,
	NormalizeFilter.COMPONENT_ID:NormalizeFilterWriter,
	QuantizeFilter.COMPONENT_ID:QuantizeFilterWriter,
	PowerFilter.COMPONENT_ID:PowerFilterWriter,
	DecayFilter.COMPONENT_ID:DecayFilterWriter
}


func lazy_load(type:String,sw:SynthWave)->WaveComponentIO:
	if writers[type] is GDScript:
		writers[type]=writers[type].new([])
	var wio:WaveComponentIO=writers[type]
	wio.components=sw.components
	return wio


func serialize(out:ChunkedFile,wave:SynthWave)->FileResult:
	out.start_chunk(CHUNK_ID,CHUNK_VERSION)
	out.store_8(wave.size_po2)
	out.store_pascal_string(wave.name)
	out.store_16(wave.components.size())
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	var fr:FileResult
	for comp in wave.components:
		if writers.has(comp.COMPONENT_ID):
			fr=lazy_load(comp.COMPONENT_ID,wave).serialize(out,comp)
		else:
			fr=FileResult.new(FileResult.ERR_BAD_WAVE_COMPONENT_OUT,{
				"type":comp.COMPONENT_ID,
				FileResult.ERRV_FILE:out.get_path()
			})
		if fr.has_error():
			return fr
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()
