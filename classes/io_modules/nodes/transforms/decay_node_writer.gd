extends NodeComponentIO
class_name DecayNodeWriter


func serialize(out:ChunkedFile,node:DecayNodeComponent)->FileResult:
	_serialize_start(out,node,DECAY_ID,DECAY_VERSION)
	out.store_float(node.mix_value)
	out.store_float(node.clamp_mix_value)
	out.store_8(int(node.isolate>=0.5))
	out.store_float(node.amplitude)
	out.store_float(node.power)
	out.store_float(node.decay)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
