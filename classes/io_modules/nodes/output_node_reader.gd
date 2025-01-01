extends NodeComponentIO
class_name OutputNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,OutputNodeComponent,header,OUTPUT_ID,OUTPUT_VERSION
	)
	if fr.has_error():
		return fr
	var node:OutputNodeComponent=fr.data
	node.clip=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
