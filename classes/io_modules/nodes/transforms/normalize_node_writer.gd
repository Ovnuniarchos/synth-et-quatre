extends NodeComponentIO
class_name NormalizeNodeWriter


func serialize(out:ChunkedFile,node:NormalizeNodeComponent)->FileResult:
	_serialize_start(out,node,NORMALIZE_ID,NORMALIZE_VERSION)
	out.store_float(node.keep_0)
	out.store_float(node.use_full)
	out.store_float(node.mix_value)
	out.store_float(node.clamp_mix_value)
	out.store_boolean(node.isolate)
	out.store_float(node.amplitude)
	out.store_float(node.power)
	out.store_float(node.decay)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
