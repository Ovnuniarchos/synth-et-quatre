extends NodeComponentIO
class_name MapWaveNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,MapWaveNodeComponent,header,MAP_WAVE_ID,MAP_WAVE_VERSION
	)
	if fr.has_error():
		return fr
	var node:MapWaveNodeComponent=fr.data
	node.lerp_value=inf.get_8()
	node.extrapolate=inf.get_8()
	node.map_empty=inf.get_boolean()
	node.mix_value=inf.get_float()
	node.clamp_mix_value=inf.get_float()
	node.isolate=inf.get_boolean()
	node.amplitude=inf.get_float()
	node.power=inf.get_float()
	node.decay=inf.get_float()
	node.dc=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
