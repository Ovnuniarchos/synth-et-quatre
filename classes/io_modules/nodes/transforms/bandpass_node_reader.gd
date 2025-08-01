extends NodeComponentIO
class_name BandpassNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,BandpassNodeComponent,header,BANDPASS_ID,BANDPASS_VERSION
	)
	if fr.has_error():
		return fr
	var node:HighpassNodeComponent=fr.data
	node.cutofflo=inf.get_16()
	node.cutoffhi=inf.get_16()
	node.attenuation=inf.get_float()
	node.resonance=inf.get_float()
	node.steps=inf.get_16()
	node.mix_value=inf.get_float()
	node.clamp_mix_value=inf.get_float()
	node.isolate=inf.get_boolean()
	node.amplitude=inf.get_float()
	node.power=inf.get_float()
	node.decay=inf.get_float()
	node.dc=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
