extends SongIO
class_name SongWriter


func write(path:String,song:Song)->FileResult:
	var out:ChunkedFile=ChunkedFile.new()
	out.open(path,File.WRITE)
	# Signature: SFMM\0xc\0xa\0x1a\0xa
	var err:int=out.start_file(FILE_SIGNATURE,FILE_VERSION)
	if err!=OK:
		return FileResult.new(err,[path,FILE_VERSION])
	return deserialize(out,song)


func deserialize(out:ChunkedFile,song:Song)->FileResult:
	# Header
	out.start_chunk(CHUNK_HEADER,CHUNK_HEADER_VERSION)
	out.store_16(song.pattern_length)
	out.store_16(song.ticks_second)
	out.store_16(song.ticks_row)
	out.store_pascal_string(song.title)
	out.store_pascal_string(song.author)
	out.end_chunk()
	# Highlights
	out.start_chunk(CHUNK_HIGHLIGHTS,CHUNK_HIGHLIGHTS_VERSION)
	out.store_16(song.minor_highlight)
	out.store_16(song.major_highlight)
	out.end_chunk()
	# Channels
	out.start_chunk(CHUNK_CHANNELS,CHUNK_CHANNELS_VERSION)
	out.store_16(song.num_channels)
	for i in song.num_channels:
		out.store_string(CHANNEL_FM4)
		out.store_8(song.num_fxs[i])
	out.end_chunk()
	# Instruments
	out.start_chunk(CHUNK_INSTRUMENTS,CHUNK_INSTRUMENTS_VERSION)
	for i in 4:
		out.store_16(song.lfo_frequencies[i]*256.0)
		out.store_8(song.lfo_waves[i])
		out.store_8(song.lfo_duty_cycles[i])
	out.store_16(song.instrument_list.size())
	var ins_w:FmInstrumentWriter=FmInstrumentWriter.new(song.wave_list)
	for inst in song.instrument_list:
		ins_w.serialize(out,inst)
	# Waveforms
	out.start_chunk(CHUNK_WAVES,CHUNK_WAVES_VERSION)
	out.store_16(song.wave_list.size())
	for wave in song.wave_list:
		wave.serialize(out) # TODO: Wave serializer
	out.end_chunk()
	out.end_chunk()
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
	for i in song.num_channels:
		var chn:Array=song.pattern_list[i]
		out.store_16(chn.size())
		for pat in chn:
			pat_w.serialize(out,pat,song.num_fxs[i])
	out.end_chunk()
	return FileResult.new()
