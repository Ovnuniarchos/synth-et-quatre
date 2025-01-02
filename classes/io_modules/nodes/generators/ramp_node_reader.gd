extends NodeComponentIO
class_name RampNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,RampNodeComponent,header,RAMP_ID,RAMP_VERSION
	)
	if fr.has_error():
		return fr
	var node:RampNodeComponent=fr.data
	node.ramp_from=inf.get_float()
	node.ramp_to=inf.get_float()
	node.ramp_curve=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
