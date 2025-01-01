extends NodeComponentIO
class_name NoiseNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,NoiseNodeComponent,header,NOISE_ID,NOISE_VERSION
	)
	if fr.has_error():
		return fr
	var node:NoiseNodeComponent=fr.data
	node.noise_seed=inf.get_32()-0x80000000
	node.amplitude=inf.get_float()
	node.decay=inf.get_float()
	node.power=inf.get_float()
	node.dc=inf.get_float()
	node.octaves=inf.get_8()
	node.frequency=inf.get_float()
	node.persistence=inf.get_float()
	node.lacunarity=inf.get_float()
	node.randomness=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
