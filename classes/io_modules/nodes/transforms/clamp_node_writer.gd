extends NodeComponentIO
class_name ClampNodeWriter


func serialize(out:ChunkedFile,node:ClampNodeComponent)->FileResult:
	_serialize_start(out,node,CLAMP_ID,CLAMP_VERSION)
	out.store_float(node.level_hi_value)
	out.store_float(node.clamp_hi_value)
	out.store_8(node.mode_hi)
	out.store_float(node.level_lo_value)
	out.store_float(node.clamp_lo_value)
	out.store_8(node.mode_lo)
	out.store_float(node.mix_value)
	out.store_float(node.clamp_mix_value)
	out.store_boolean(node.isolate)
	out.store_float(node.amplitude)
	out.store_float(node.power)
	out.store_float(node.decay)
	out.store_float(node.dc)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
