extends NodeComponentIO
class_name ClipNodeWriter


func serialize(out:ChunkedFile,node:ClipNodeComponent)->FileResult:
	_serialize_start(out,node,CLIP_ID,CLIP_VERSION)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
