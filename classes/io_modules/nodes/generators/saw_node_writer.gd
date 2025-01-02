extends NodeComponentIO
class_name SawNodeWriter


func serialize(out:ChunkedFile,node:SawNodeComponent)->FileResult:
	_serialize_start(out,node,SAW_ID,SAW_VERSION)
	out.store_float(node.frequency)
	out.store_float(node.amplitude)
	out.store_float(node.phi0)
	out.store_float(node.power)
	out.store_float(node.decay)
	out.store_float(node.dc)
	for i in 4:
		out.store_8(node.quarters[i])
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
