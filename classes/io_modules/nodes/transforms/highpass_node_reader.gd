extends NodeComponentIO
class_name HighpassNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,HighpassNodeComponent,header,HIGHPASS_ID,HIGHPASS_VERSION
	)
	if fr.has_error():
		return fr
	var node:HighpassNodeComponent=fr.data
	node.cutoff=inf.get_16()
	node.attenuation=inf.get_float()
	node.resonance=inf.get_float()
	node.mix_value=inf.get_float()
	node.clamp_mix_value=inf.get_float()
	node.isolate=inf.get_boolean()
	node.amplitude=inf.get_float()
	node.power=inf.get_float()
	node.decay=inf.get_float()
	node.dc=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
