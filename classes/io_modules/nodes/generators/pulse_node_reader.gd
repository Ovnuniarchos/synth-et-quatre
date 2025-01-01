extends NodeComponentIO
class_name PulseNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult=_deserialize_start(
		inf,PulseNodeComponent,header,PULSE_ID,PULSE_VERSION
	)
	if fr.has_error():
		return fr
	var node:PulseNodeComponent=fr.data
	node.ppulse_start=inf.get_float()
	node.ppulse_length=inf.get_float()
	node.ppulse_amplitude=inf.get_float()
	node.npulse_start=inf.get_float()
	node.npulse_length=inf.get_float()
	node.npulse_amplitude=inf.get_float()
	node.frequency=inf.get_float()
	node.amplitude=inf.get_float()
	node.phi0=inf.get_float()
	node.decay=inf.get_float()
	node.dc=inf.get_float()
	fr=_deserialize_end(inf,node)
	return fr if fr.has_error() else FileResult.new(OK,node)
