extends NodeWaveIO
class_name NodeWaveReader


var readers:Dictionary={
	NodeComponentIO.OUTPUT_ID:OutputNodeReader,
	NodeComponentIO.NOISE_ID:NoiseNodeReader,
	NodeComponentIO.PULSE_ID:PulseNodeReader,
	NodeComponentIO.RAMP_ID:RampNodeReader,
	NodeComponentIO.SAW_ID:SawNodeReader,
	NodeComponentIO.SINE_ID:SineNodeReader,
	NodeComponentIO.TRIANGLE_ID:TriangleNodeReader,
	NodeComponentIO.CLAMP_ID:ClampNodeReader,
	NodeComponentIO.CLIP_ID:ClipNodeReader,
	NodeComponentIO.MAP_RANGE_ID:MapRangeNodeReader,
	NodeComponentIO.MAP_WAVE_ID:MapWaveNodeReader,
	NodeComponentIO.MIX_ID:MixNodeReader,
	NodeComponentIO.NORMALIZE_ID:NormalizeNodeReader,
	NodeComponentIO.DECAY_ID:DecayNodeReader,
	NodeComponentIO.POWER_ID:PowerNodeReader,
}


func lazy_load(type:String)->NodeComponentIO:
	if readers[type] is GDScript:
		readers[type]=readers[type].new()
	return readers[type]


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	# Header
	if not inf.is_chunk_valid(header,CHUNK_ID,CHUNK_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:CHUNK_ID,
			FileResult.ERRV_EXP_VERSION:CHUNK_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var wave:NodeWave=NodeWave.new()
	wave.size_po2=inf.get_8()
	wave.name=inf.get_pascal_string()
	var component_count:int=inf.get_16()
	# Components
	var fr:FileResult
	var wave_ref:WeakRef=weakref(wave)
	wave.components=[]
	for i in component_count:
		fr=deserialize_component(inf)
		if fr.has_error():
			return fr
		elif fr.data!=null:
			fr.data.wave=wave_ref
			wave.components.append(fr.data)
			if fr.data is OutputNodeComponent:
				wave.output=fr.data
	# Connections
	for node in wave.components:
		translate_connections(node,wave)
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new(OK,wave)


func deserialize_component(inf:ChunkedFile,forced_type:String="")->FileResult:
	var header:Dictionary=inf.get_chunk_header()
	var type:String=inf.get_chunk_id(header) if forced_type.empty() else forced_type
	if not readers.has(type):
		inf.invalid_chunk(header)
		inf.rewind_chunk(header)
		return FileResult.new()
	var fr:FileResult=lazy_load(type).deserialize(inf,header)
	return fr if fr.has_error() else FileResult.new(OK,fr.data)


func translate_connections(node:WaveNodeComponent,wave:NodeWave)->void:
	for slot in node.inputs:
		var connections:Array=slot[WaveNodeComponent.SLOT_IN]
		for i in connections.size():
			connections[i]=wave.components[connections[i]]
