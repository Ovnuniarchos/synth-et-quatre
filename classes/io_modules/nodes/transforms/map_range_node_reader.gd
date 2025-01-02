extends NodeComponentIO
class_name MapRangeNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,MapRangeNodeComponent,header,MAP_RANGE_ID,MAP_RANGE_VERSION
	)
	if fr.has_error():
		return fr
	var node:MapRangeNodeComponent=fr.data
	node.min_in_value=inf.get_float()
	node.max_in_value=inf.get_float()
	node.min_out_value=inf.get_float()
	node.max_out_value=inf.get_float()
	inf.get_8() # FUTURE: bool extrapolate_min|extrapolate_max
	node.mix_value=inf.get_float()
	node.clamp_mix_value=inf.get_float()
	node.isolate=float(bool(inf.get_8()))
	node.amplitude=inf.get_float()
	node.power=inf.get_float()
	node.decay=inf.get_float()
	node.dc=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
