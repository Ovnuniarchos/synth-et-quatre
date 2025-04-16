extends NodeComponentIO
class_name DecimateNodeWriter


func serialize(out:ChunkedFile,node:DecimateNodeComponent)->FileResult:
	_serialize_start(out,node,DECIMATE_ID,DECIMATE_VERSION)
	out.store_16(node.samples_value)
	out.store_float(node.use_full_value)
	out.store_8(node.lerp_value)
	out.store_float(node.mix_value)
	out.store_float(node.clamp_mix_value)
	out.store_8(node.isolate)
	out.store_float(node.amplitude)
	out.store_float(node.power)
	out.store_float(node.decay)
	out.store_float(node.dc)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
