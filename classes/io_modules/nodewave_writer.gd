extends NodeWaveIO
class_name NodeWaveWriter


var writers:Dictionary={
	OutputNodeComponent.NODE_TYPE:OutputNodeWriter,
	NoiseNodeComponent.NODE_TYPE:NoiseNodeWriter,
	PulseNodeComponent.NODE_TYPE:PulseNodeWriter,
	RampNodeComponent.NODE_TYPE:RampNodeWriter,
	SawNodeComponent.NODE_TYPE:SawNodeWriter,
	SineNodeComponent.NODE_TYPE:SineNodeWriter,
	TriangleNodeComponent.NODE_TYPE:TriangleNodeWriter,
	ClampNodeComponent.NODE_TYPE:ClampNodeWriter,
	ClipNodeComponent.NODE_TYPE:ClipNodeWriter,
	MapRangeNodeComponent.NODE_TYPE:MapRangeNodeWriter,
	MapWaveNodeComponent.NODE_TYPE:MapWaveNodeWriter,
	MixNodeComponent.NODE_TYPE:MixNodeWriter,
	NormalizeNodeComponent.NODE_TYPE:NormalizeNodeWriter,
	DecayNodeComponent.NODE_TYPE:DecayNodeWriter,
	PowerNodeComponent.NODE_TYPE:PowerNodeWriter,
	MuxNodeComponent.NODE_TYPE:MuxNodeWriter,
	QuantizeNodeComponent.NODE_TYPE:QuantizeNodeWriter,
	DecimateNodeComponent.NODE_TYPE:DecimateNodeWriter,
	LowpassNodeComponent.NODE_TYPE:LowpassNodeWriter
}


func lazy_load(type:String)->NodeComponentIO:
	if writers[type] is GDScript:
		writers[type]=writers[type].new()
	return writers[type]


func serialize(out:ChunkedFile,wave:NodeWave)->FileResult:
	# Header
	out.start_chunk(CHUNK_ID,CHUNK_VERSION)
	out.store_8(wave.size_po2)
	out.store_pascal_string(wave.name)
	out.store_16(wave.components.size())
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	# Serialize components
	var fr:FileResult
	for comp in wave.components:
		fr=serialize_component(out,comp,wave)
		if fr.has_error():
			return fr
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()


func serialize_component(out:ChunkedFile,comp:WaveNodeComponent,_wave:NodeWave)->FileResult:
	var fr:FileResult
	if writers.has(comp.NODE_TYPE):
		fr=lazy_load(comp.NODE_TYPE).serialize(out,comp)
	else:
		fr=FileResult.new(FileResult.ERR_BAD_WAVE_COMPONENT_OUT,{
			"type":comp.NODE_TYPE,
			FileResult.ERRV_FILE:out.get_path()
		})
	return fr
