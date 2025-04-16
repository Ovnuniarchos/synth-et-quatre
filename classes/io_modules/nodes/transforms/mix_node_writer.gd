extends NodeComponentIO
class_name MixNodeWriter


func serialize(out:ChunkedFile,node:MixNodeComponent)->FileResult:
	_serialize_start(out,node,MIX_ID,MIX_VERSION)
	out.store_float(node.a_value)
	out.store_float(node.b_value)
	out.store_8(node.op_value)
	out.store_float(node.mix_value)
	out.store_float(node.clamp_mix_value)
	out.store_boolean(node.isolate)
	out.store_float(node.power)
	out.store_float(node.decay)
	out.store_float(node.dc)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
