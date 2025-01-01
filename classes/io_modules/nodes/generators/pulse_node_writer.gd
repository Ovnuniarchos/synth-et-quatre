extends NodeComponentIO
class_name PulseNodeWriter


func serialize(out:ChunkedFile,node:PulseNodeComponent)->FileResult:
	_serialize_start(out,node,PULSE_ID,PULSE_VERSION)
	out.store_float(node.ppulse_start)
	out.store_float(node.ppulse_length)
	out.store_float(node.ppulse_amplitude)
	out.store_float(node.npulse_start)
	out.store_float(node.npulse_length)
	out.store_float(node.npulse_amplitude)
	out.store_float(node.frequency)
	out.store_float(node.amplitude)
	out.store_float(node.phi0)
	out.store_float(node.decay)
	out.store_float(node.dc)
	var fr:FileResult=_serialize_end(out,node)
	return fr if fr.has_error() else FileResult.new()
