extends NodeComponentIO
class_name BandRejectNodeWriter


func serialize(out:ChunkedFile,node:BandRejectNodeComponent)->FileResult:
	_serialize_start(out,node,BANDREJECT_ID,BANDREJECT_VERSION)
	out.store_16(node.cutofflo)
	out.store_16(node.cutoffhi)
	out.store_float(node.attenuation)
	out.store_float(node.resonance)
	out.store_16(node.steps)
	out.store_float(node.mix_value)
	out.store_float(node.clamp_mix_value)
	out.store_8(node.isolate)
	out.store_float(node.amplitude)
	out.store_float(node.power)
	out.store_float(node.decay)
	out.store_float(node.dc)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
