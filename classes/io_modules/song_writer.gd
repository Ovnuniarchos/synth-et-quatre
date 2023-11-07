extends SongIO
class_name SongWriter


func write(path:String,song:Song)->FileResult:
	var out:ChunkedFile=ChunkedFile.new()
	out.open(path,File.WRITE)
	# Signature: SFMM\0xc\0xa\0x1a\0xa
	var err:int=out.start_file(FILE_SIGNATURE,FILE_VERSION)
	if err!=OK:
		return FileResult.new(err,{"file":out.get_path()})
	var fr:FileResult=serialize(out,song)
	if fr.has_error():
		ALERT.alert(fr.get_message())
	return fr


func serialize(out:ChunkedFile,song:Song)->FileResult:
	var fr:FileResult=serialize_header(out,song)
	if fr!=null:
		return fr
	fr=serialize_highlights(out,song)
	if fr!=null:
		return fr
	fr=serialize_channels(out,song)
	if fr!=null:
		return fr
	fr=serialize_instruments(out,song)
	if fr!=null:
		return fr
	# Orders
	out.start_chunk(CHUNK_ORDERS,CHUNK_ORDERS_VERSION)
	out.store_16(song.orders.size())
	for ordr in song.orders:
		for chn in song.num_channels:
			out.store_8(ordr[chn])
	out.end_chunk()
	# pattern_list
	var pat_w:PatternWriter=PatternWriter.new(song.pattern_length)
	out.start_chunk(CHUNK_PATTERNS,CHUNK_PATTERNS_VERSION)
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	for i in song.num_channels:
		var chn:Array=song.pattern_list[i]
		out.store_16(chn.size())
		for pat in chn:
			fr=pat_w.serialize(out,pat,song.num_fxs[i])
			if fr.has_error():
				return fr
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	return FileResult.new()


func serialize_header(out:ChunkedFile,song:Song)->FileResult:
	out.start_chunk(CHUNK_HEADER,CHUNK_HEADER_VERSION)
	out.store_16(song.pattern_length)
	out.store_16(song.ticks_second)
	out.store_16(song.ticks_row)
	out.store_pascal_string(song.title)
	out.store_pascal_string(song.author)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	return null


func serialize_highlights(out:ChunkedFile,song:Song)->FileResult:
	out.start_chunk(CHUNK_HIGHLIGHTS,CHUNK_HIGHLIGHTS_VERSION)
	out.store_16(song.minor_highlight)
	out.store_16(song.major_highlight)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	return null


func serialize_channels(out:ChunkedFile,song:Song)->FileResult:
	out.start_chunk(CHUNK_CHANNELS,CHUNK_CHANNELS_VERSION)
	out.store_16(song.num_channels)
	for i in song.num_channels:
		out.store_string(CHANNEL_FM4) # Unused
		out.store_8(song.num_fxs[i])
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	return null


func serialize_instruments(out:ChunkedFile,song:Song)->FileResult:
	var fr:FileResult
	out.start_chunk(CHUNK_INSTRUMENTS,CHUNK_INSTRUMENTS_VERSION)
	for i in 4:
		out.store_16(song.lfo_frequencies[i]*256.0)
		out.store_8(song.lfo_waves[i])
		out.store_8(song.lfo_duty_cycles[i])
	out.store_16(song.instrument_list.size())
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	var ins_w:FmInstrumentWriter=FmInstrumentWriter.new(song.wave_list)
	for inst in song.instrument_list:
		fr=ins_w.serialize(out,inst)
		if fr.has_error():
			return fr
	fr=serialize_waveforms(out,song)
	if fr!=null:
		return fr
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	return null


func serialize_waveforms(out:ChunkedFile,song:Song)->FileResult:
	var fr:FileResult
	out.start_chunk(CHUNK_WAVES,CHUNK_WAVES_VERSION)
	out.store_16(song.wave_list.size())
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	var syn_w:SynthWaveWriter=SynthWaveWriter.new()
	var sam_w:SampleWaveWriter=SampleWaveWriter.new()
	for wave in song.wave_list:
		if wave is SynthWave:
			fr=syn_w.serialize(out,wave)
		elif wave is SampleWave:
			fr=sam_w.serialize(out,wave)
		else:
			fr=FileResult.new(FileResult.ERR_INVALID_WAVE_TYPE,{
				"type":wave.get_class(),
				"file":out.get_path()
			})
		if fr.has_error():
			return fr
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{"file":out.get_path()})
	return null
