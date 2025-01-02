extends NodeComponentIO
class_name ClipNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,ClipNodeComponent,header,CLIP_ID,CLIP_VERSION
	)
	if fr.has_error():
		return fr
	var node:ClipNodeComponent=fr.data
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
