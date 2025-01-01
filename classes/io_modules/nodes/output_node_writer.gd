extends NodeComponentIO
class_name OutputNodeWriter


func serialize(out:ChunkedFile,node:OutputNodeComponent)->FileResult:
	_serialize_start(out,node,OUTPUT_ID,OUTPUT_VERSION)
	out.store_float(node.clip)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
