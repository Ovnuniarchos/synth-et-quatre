extends NodeComponentIO
class_name NormalizeNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,NormalizeNodeComponent,header,NORMALIZE_ID,NORMALIZE_VERSION
	)
	if fr.has_error():
		return fr
	var node:NormalizeNodeComponent=fr.data
	node.keep_0=inf.get_float()
	node.use_full=inf.get_float()
	node.mix_value=inf.get_float()
	node.clamp_mix_value=inf.get_float()
	node.isolate=float(bool(inf.get_8()))
	node.amplitude=inf.get_float()
	node.power=inf.get_float()
	node.decay=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
