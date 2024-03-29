extends SynthWaveIO
class_name SynthWaveWriter


var writers:Dictionary={
	NoiseWave.COMPONENT_ID:null,
	RectangleWave.COMPONENT_ID:null,
	SawWave.COMPONENT_ID:null,
	SineWave.COMPONENT_ID:null,
	TriangleWave.COMPONENT_ID:null,
	BpfFilter.COMPONENT_ID:null,
	BrfFilter.COMPONENT_ID:null,
	ClampFilter.COMPONENT_ID:null,
	HpfFilter.COMPONENT_ID:null,
	LpfFilter.COMPONENT_ID:null,
	NormalizeFilter.COMPONENT_ID:null,
	QuantizeFilter.COMPONENT_ID:null,
	PowerFilter.COMPONENT_ID:null,
	DecayFilter.COMPONENT_ID:null
}


func lazy_load(type:String,sw:SynthWave)->WaveComponentIO:
	var wio:WaveComponentIO
	if writers[type]==null:
		match type:
			NoiseWave.COMPONENT_ID:
				wio=NoiseWaveWriter.new(sw.components)
			RectangleWave.COMPONENT_ID:
				wio=RectangleWaveWriter.new(sw.components)
			SawWave.COMPONENT_ID:
				wio=SawWaveWriter.new(sw.components)
			SineWave.COMPONENT_ID:
				wio=SineWaveWriter.new(sw.components)
			TriangleWave.COMPONENT_ID:
				wio=TriangleWaveWriter.new(sw.components)
			BpfFilter.COMPONENT_ID:
				wio=BPFFilterWriter.new(sw.components)
			BrfFilter.COMPONENT_ID:
				wio=BRFFilterWriter.new(sw.components)
			ClampFilter.COMPONENT_ID:
				wio=ClampFilterWriter.new(sw.components)
			HpfFilter.COMPONENT_ID:
				wio=HPFFilterWriter.new(sw.components)
			LpfFilter.COMPONENT_ID:
				wio=LPFFilterWriter.new(sw.components)
			NormalizeFilter.COMPONENT_ID:
				wio=NormalizeFilterWriter.new(sw.components)
			QuantizeFilter.COMPONENT_ID:
				wio=QuantizeFilterWriter.new(sw.components)
			PowerFilter.COMPONENT_ID:
				wio=PowerFilterWriter.new(sw.components)
			DecayFilter.COMPONENT_ID:
				wio=DecayFilterWriter.new(sw.components)
	else:
		wio=writers[type]
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
