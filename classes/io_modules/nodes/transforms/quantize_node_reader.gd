extends NodeComponentIO
class_name QuantizeNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,QuantizeNodeComponent,header,CLIP_ID,CLIP_VERSION
	)
	if fr.has_error():
		return fr
	var node:QuantizeNodeComponent=fr.data
	node.levels_value=inf.get_8()
	node.use_full_value=float(bool(inf.get_8()))
	node.full_amplitude_value=float(bool(inf.get_8()))
	node.mix_value=inf.get_float()
	node.clamp_mix_value=inf.get_float()
	node.isolate=float(bool(inf.get_8()))
	node.amplitude=inf.get_float()
	node.power=inf.get_float()
	node.decay=inf.get_float()
	node.dc=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
