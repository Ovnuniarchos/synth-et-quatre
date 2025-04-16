extends NodeComponentIO
class_name MapWaveNodeWriter


func serialize(out:ChunkedFile,node:MapWaveNodeComponent)->FileResult:
	_serialize_start(out,node,MAP_WAVE_ID,MAP_WAVE_VERSION)
	out.store_8(node.lerp_value)
	out.store_8(node.extrapolate)
	out.store_boolean(node.map_empty)
	out.store_float(node.mix_value)
	out.store_float(node.clamp_mix_value)
	out.store_boolean(node.isolate)
	out.store_float(node.amplitude)
	out.store_float(node.power)
	out.store_float(node.decay)
	out.store_float(node.dc)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
