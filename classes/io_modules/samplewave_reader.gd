extends SampleWaveIO
class_name SampleWaveReader


func deserialize(inf:ChunkedFile,header:Dictionary)->SampleWave:
	if not inf.is_chunk_valid(header,CHUNK_ID,CHUNK_VERSION):
		return null
	var w:SampleWave=SampleWave.new()
	w.size=inf.get_32()
	w.original_data.resize(w.size)
	w.bits_sample=inf.get_8()
	w.loop_start=inf.get_32()
	w.loop_end=inf.get_32()
	w.record_freq=inf.get_float()
	w.sample_freq=inf.get_float()
	w.name=inf.get_pascal_string()
	match w.bits_sample:
		8:
			for i in w.size:
				w.original_data[i]=inf.get_8()-0x80
		16:
			for i in w.size:
				w.original_data[i]=inf.get_16()-0x8000
		32:
			for i in w.size:
				w.original_data[i]=inf.get_float()
		_:
			for i in w.size:
				w.original_data[i]=((inf.get_8()<<16)|inf.get_16())-0x800000
	w.calculate()
	return w
