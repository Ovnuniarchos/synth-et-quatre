extends NodeComponentIO
class_name SineNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,SineNodeComponent,header,SINE_ID,SINE_VERSION
	)
	if fr.has_error():
		return fr
	var node:SineNodeComponent=fr.data
	node.frequency=inf.get_float()
	node.amplitude=inf.get_float()
	node.phi0=inf.get_float()
	node.power=inf.get_float()
	node.decay=inf.get_float()
	node.dc=inf.get_float()
	for i in 4:
		node.quarters[i]=inf.get_8()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
