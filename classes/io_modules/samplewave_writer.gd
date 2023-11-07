extends SampleWaveIO
class_name SampleWaveWriter


func serialize(out:ChunkedFile,wave:SampleWave)->FileResult:
	out.start_chunk(CHUNK_ID,CHUNK_VERSION)
	out.store_32(wave.original_data.size())
	out.store_8(wave.bits_sample)
	out.store_32(wave.loop_start)
	out.store_32(wave.loop_end)
	out.store_float(wave.record_freq)
	out.store_float(wave.sample_freq)
	out.store_pascal_string(wave.name)
	if wave.bits_sample==8:
		for sam in wave.original_data:
			out.store_8(sam+0x80)
	elif wave.bits_sample==16:
		for sam in wave.original_data:
			out.store_16(sam+0x8000)
	elif wave.bits_sample==32:
		for sam in wave.original_data:
			out.store_float(sam)
	else:
		for sam in wave.original_data:
			sam+=0x800000
			out.store_8(sam>>16)
			out.store_16(sam&0xffff)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	return FileResult.new()
