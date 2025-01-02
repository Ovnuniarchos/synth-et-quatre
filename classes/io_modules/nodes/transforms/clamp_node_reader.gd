extends NodeComponentIO
class_name ClampNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,ClampNodeComponent,header,CLAMP_ID,CLAMP_VERSION
	)
	if fr.has_error():
		return fr
	var node:ClampNodeComponent=fr.data
	node.level_hi_value=inf.get_float()
	node.clamp_hi_value=inf.get_float()
	node.mode_hi=inf.get_8()
	node.level_lo_value=inf.get_float()
	node.clamp_lo_value=inf.get_float()
	node.mode_lo=inf.get_8()
	node.mix_value=inf.get_float()
	node.clamp_mix_value=inf.get_float()
	node.isolate=float(bool(inf.get_8()))
	node.amplitude=inf.get_float()
	node.power=inf.get_float()
	node.decay=inf.get_float()
	node.dc=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
