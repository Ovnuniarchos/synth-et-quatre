extends NodeComponentIO
class_name DecimateNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,DecimateNodeComponent,header,DECIMATE_ID,DECIMATE_VERSION
	)
	if fr.has_error():
		return fr
	var node:DecimateNodeComponent=fr.data
	node.levels_value=inf.get_16()
	node.use_full_value=inf.get_float()
	node.lerp_value=inf.get_8()
	node.mix_value=inf.get_float()
	node.clamp_mix_value=inf.get_float()
	node.isolate=inf.get_boolean()
	node.amplitude=inf.get_float()
	node.power=inf.get_float()
	node.decay=inf.get_float()
	node.dc=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
