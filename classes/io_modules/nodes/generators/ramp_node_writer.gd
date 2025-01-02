extends NodeComponentIO
class_name RampNodeWriter


func serialize(out:ChunkedFile,node:RampNodeComponent)->FileResult:
	_serialize_start(out,node,RAMP_ID,RAMP_VERSION)
	out.store_float(node.ramp_from)
	out.store_float(node.ramp_to)
	out.store_float(node.curve)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
