extends NodeComponentIO
class_name MuxNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,MuxNodeComponent,header,MUX_ID,MUX_VERSION
	)
	if fr.has_error():
		return fr
	var node:MuxNodeComponent=fr.data
	node.selector=inf.get_float()
	node.clip=inf.get_8()
	node.resize_inputs(inf.get_8())
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
