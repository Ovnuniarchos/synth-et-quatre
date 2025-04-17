extends NodeComponentIO
class_name MapRangeNodeWriter


func serialize(out:ChunkedFile,node:MapRangeNodeComponent)->FileResult:
	_serialize_start(out,node,MAP_RANGE_ID,MAP_RANGE_VERSION)
	out.store_float(node.min_in_value)
	out.store_float(node.max_in_value)
	out.store_float(node.min_out_value)
	out.store_float(node.max_out_value)
	out.store_float(node.xerp_in_value)
	out.store_float(node.xerp_out_value)
	out.store_float(node.mix_value)
	out.store_float(node.clamp_mix_value)
	out.store_boolean(node.isolate)
	out.store_float(node.amplitude)
	out.store_float(node.power)
	out.store_float(node.decay)
	out.store_float(node.dc)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
