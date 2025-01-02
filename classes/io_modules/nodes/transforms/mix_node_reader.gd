extends NodeComponentIO
class_name MixNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,MixNodeComponent,header,MIX_ID,MIX_VERSION
	)
	if fr.has_error():
		return fr
	var node:MixNodeComponent=fr.data
	node.a_value=inf.get_float()
	node.b_value=inf.get_float()
	node.op_value=inf.get_8()
	node.mix_value=inf.get_float()
	node.clamp_mix_value=inf.get_float()
	node.isolate=float(bool(inf.get_8()))
	node.power=inf.get_float()
	node.decay=inf.get_float()
	node.dc=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
