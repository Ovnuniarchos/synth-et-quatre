extends NodeComponentIO
class_name NoiseNodeWriter


func serialize(out:ChunkedFile,node:NoiseNodeComponent)->FileResult:
	_serialize_start(out,node,NOISE_ID,NOISE_VERSION)
	out.store_32(node.noise_seed)
	out.store_float(node.amplitude)
	out.store_float(node.decay)
	out.store_float(node.power)
	out.store_float(node.dc)
	out.store_8(node.octaves)
	out.store_float(node.frequency)
	out.store_float(node.persistence)
	out.store_float(node.lacunarity)
	out.store_float(node.randomness)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
