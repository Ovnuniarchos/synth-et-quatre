extends NodeComponentIO
class_name LowpassNodeWriter


func serialize(out:ChunkedFile,node:LowpassNodeComponent)->FileResult:
	_serialize_start(out,node,LOWPASS_ID,LOWPASS_VERSION)
	out.store_16(node.cutoff)
	out.store_float(node.attenuation)
	out.store_float(node.resonance)
	out.store_float(node.mix_value)
	out.store_float(node.clamp_mix_value)
	out.store_8(node.isolate)
	out.store_float(node.amplitude)
	out.store_float(node.power)
	out.store_float(node.decay)
	out.store_float(node.dc)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
