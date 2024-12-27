extends NodeWaveIO
class_name NodeWaveWriter


var writers:Dictionary={
	OutputNodeComponent.NODE_TYPE:OutputNodeWriter
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
	out.store_16(wave.components.size()+1)
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	# Serialize components
	var fr:FileResult
	fr=serialize_component(out,wave.output)
	if fr.has_error():
		return fr
	for comp in wave.components:
		fr=serialize_component(out,comp)
		if fr.has_error():
			return fr
	# TODO: Serialize connections
	out.start_chunk(CONNECTIONS_ID,CONNECTIONS_VERSION)
	out.store_16(wave.comonents.size()+1)
	fr=serialize_connections(out,wave.output,wave)
	if fr.has_error():
		return fr
	for comp in wave.components:
		fr=serialize_connections(out,comp,wave)
		if fr.has_error():
			return fr
	out.end_chunk()
	# Serialize positions
	out.start_chunk(POSITIONS_ID,POSITIONS_VERSION)
	out.store_16(wave.comonents.size()+1)
	out.store_32(wave.output.viz_rect.position.x)
	out.store_32(wave.output.viz_rect.position.y)
	out.store_32(wave.output.viz_rect.size.x)
	out.store_32(wave.output.viz_rect.size.y)
	for comp in wave.components:
		out.store32(comp.viz_rect.position.x)
		out.store32(comp.viz_rect.position.y)
		out.store32(comp.viz_rect.size.w)
		out.store32(comp.viz_rect.size.h)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()


func serialize_component(out:ChunkedFile,comp:WaveNodeComponent)->FileResult:
	var fr:FileResult
	if writers.has(comp.COMPONENT_ID):
		fr=lazy_load(comp.COMPONENT_ID).serialize(out,comp)
	else:
		fr=FileResult.new(FileResult.ERR_BAD_WAVE_COMPONENT_OUT,{
			"type":comp.COMPONENT_ID,
			FileResult.ERRV_FILE:out.get_path()
		})
	return fr


func serialize_connections(out:ChunkedFile,node:WaveNodeComponent,wave:NodeWave)->FileResult:
	return FileResult.new()
