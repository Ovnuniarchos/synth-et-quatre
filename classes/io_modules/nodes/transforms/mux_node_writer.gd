extends NodeComponentIO
class_name MuxNodeWriter


func serialize(out:ChunkedFile,node:MuxNodeComponent)->FileResult:
	_serialize_start(out,node,MUX_ID,MUX_VERSION)
	out.store_float(node.selector)
	out.store_8(node.clip)
	out.store_8(node.get_inputs_size())
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
