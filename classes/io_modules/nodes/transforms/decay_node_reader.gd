extends NodeComponentIO
class_name DecayNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,DecayNodeComponent,header,DECAY_ID,DECAY_VERSION
	)
	if fr.has_error():
		return fr
	var node:DecayNodeComponent=fr.data
	node.mix_value=inf.get_float()
	node.clamp_mix_value=inf.get_float()
	node.isolate=inf.get_boolean()
	node.amplitude=inf.get_float()
	node.power=inf.get_float()
	node.decay=inf.get_float()
	node.dc=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
