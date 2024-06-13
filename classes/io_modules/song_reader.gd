extends SongIO
class_name SongReader


var clear_insts:bool


func read(path:String)->FileResult:
	var f:ChunkedFile=ChunkedFile.new()
	var err:int=f.open(path,File.READ)
	err=f.start_file(FILE_SIGNATURE,FILE_VERSION) if err==OK else err
	if err!=OK:
		f.close()
		return FileResult.new(err,{
			FileResult.ERRV_FILE:path,FileResult.ERRV_VERSION:FILE_VERSION,FileResult.ERRV_TYPE:"song"
		})
	var res:FileResult=deserialize(f)
	f.close()
	if res.is_ok():
		res.data.file_name=path.get_file()
		AUDIO.tracker.stop()
		AUDIO.tracker.reset()
		GLOBALS.set_song(res.data)
	return res


func deserialize(inf:ChunkedFile)->FileResult:
	var song:Song=Song.new()
	clear_insts=true
	# Header
	var hdr:Dictionary=inf.get_chunk_header()
	if not inf.is_chunk_valid(hdr,CHUNK_HEADER,CHUNK_HEADER_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(hdr),
			FileResult.ERRV_VERSION:inf.get_chunk_version(hdr),
			FileResult.ERRV_EXP_CHUNK:CHUNK_HEADER,
			FileResult.ERRV_EXP_VERSION:CHUNK_HEADER_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	song.pattern_length=inf.get_16()
	song.ticks_second=inf.get_16()
	song.ticks_row=inf.get_16()
	song.title=inf.get_pascal_string()
	song.author=inf.get_pascal_string()
	inf.skip_chunk(hdr)
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_EXP_CHUNK:inf.get_path()})
	#
	var fr:FileResult
	while true:
		hdr=inf.get_chunk_header()
		if inf.eof_reached():
			break
		match hdr[ChunkedFile.CHUNK_ID]:
			CHUNK_HIGHLIGHTS:
				fr=deserialize_highlights(inf,song,hdr)
			CHUNK_CHANNELS:
				fr=deserialize_channel_list(inf,song,hdr)
			CHUNK_ORDERS:
				fr=deserialize_order_list(inf,song,hdr)
			CHUNK_PATTERNS:
				fr=deserialize_pattern_list(inf,song,hdr)
			CHUNK_INSTRUMENTS:
				fr=deserialize_instrument_list(inf,song,hdr)
			CHUNK_WAVES:
				fr=deserialize_wave_list(inf,song,hdr)
			CHUNK_ARPEGGIOS:
				fr=deserialize_arpeggios(inf,song,hdr)
			_:
				fr=FileResult.new()
				inf.invalid_chunk(hdr)
		inf.skip_chunk(hdr)
		if fr.has_error():
			return fr
	return FileResult.new(OK,song)


func deserialize_highlights(inf:ChunkedFile,song:Song,header:Dictionary)->FileResult:
	if inf.is_chunk_valid(header,CHUNK_HIGHLIGHTS,CHUNK_HIGHLIGHTS_VERSION):
		song.minor_highlight=inf.get_16()
		song.major_highlight=inf.get_16()
		if inf.get_error():
			return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
		return FileResult.new()
	return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
		FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
		FileResult.ERRV_VERSION:inf.get_chunk_version(header),
		FileResult.ERRV_EXP_CHUNK:CHUNK_HIGHLIGHTS,
		FileResult.ERRV_EXP_VERSION:CHUNK_HIGHLIGHTS_VERSION,
		FileResult.ERRV_EXP_FILE:inf.get_path()
	})


func deserialize_channel_list(inf:ChunkedFile,song:Song,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,CHUNK_CHANNELS,CHUNK_CHANNELS_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:CHUNK_CHANNELS,
			FileResult.ERRV_EXP_VERSION:CHUNK_CHANNELS_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var nc:int=inf.get_16()
	song.num_channels=nc
	for i in nc:
		inf.get_ascii(4) # Unused
		var nfx:int=inf.get_8()
		song.num_fxs[i]=nfx
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new()


func deserialize_pattern_list(inf:ChunkedFile,song:Song,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,CHUNK_PATTERNS,CHUNK_PATTERNS_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:CHUNK_PATTERNS,
			FileResult.ERRV_EXP_VERSION:CHUNK_PATTERNS_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var hdr:Dictionary
	var pat_l:Array=[]
	var pat_r:PatternReader=PatternReader.new(song.pattern_length)
	pat_l.resize(SongLimits.MAX_CHANNELS)
	var fr:FileResult
	for i in song.num_channels:
		pat_l[i]=[]
		pat_l[i].resize(inf.get_16())
		for j in pat_l[i].size():
			hdr=inf.get_chunk_header()
			fr=pat_r.deserialize(inf,hdr)
			if fr.has_error():
				return fr
			pat_l[i][j]=fr.data
			inf.skip_chunk(hdr)
	for i in range(song.num_channels,SongLimits.MAX_CHANNELS):
		pat_l[i]=[Pattern.new()]
	song.pattern_list=pat_l
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new()


func deserialize_order_list(inf:ChunkedFile,song:Song,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,CHUNK_ORDERS,CHUNK_ORDERS_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:CHUNK_ORDERS,
			FileResult.ERRV_EXP_VERSION:CHUNK_ORDERS_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var ord_l:Array=[]
	ord_l.resize(inf.get_16())
	for i in range(ord_l.size()):
		ord_l[i]=[]
		ord_l[i].resize(SongLimits.MAX_CHANNELS)
		for j in song.num_channels:
			ord_l[i][j]=inf.get_8()
		for j in range(song.num_channels,SongLimits.MAX_CHANNELS):
			ord_l[i][j]=0
	song.orders=ord_l
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new()


func deserialize_instrument_list(inf:ChunkedFile,song:Song,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,CHUNK_INSTRUMENTS,CHUNK_INSTRUMENTS_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:CHUNK_INSTRUMENTS,
			FileResult.ERRV_EXP_VERSION:CHUNK_INSTRUMENTS_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var hdr:Dictionary
	var inst_l:Array=[]
	var ins_r:FmInstrumentReader=FmInstrumentReader.new()
	for i in 4:
		song.lfo_frequencies[i]=inf.get_16()/256.0
		song.lfo_waves[i]=inf.get_8()
		song.lfo_duty_cycles[i]=inf.get_8()
	inst_l.resize(inf.get_16())
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	var fr:FileResult
	for i in inst_l.size():
		hdr=inf.get_chunk_header()
		match hdr[ChunkedFile.CHUNK_ID]:
			FmInstrumentIO.CHUNK_ID:
				fr=ins_r.deserialize(inf,hdr)
				if fr.has_error():
					return fr
				inst_l[i]=fr.data
			_:
				inf.invalid_chunk(hdr)
		inf.skip_chunk(hdr)
	if clear_insts:
		song.instrument_list.clear()
		clear_insts=false
	song.instrument_list.append_array(inst_l)
	if header[ChunkedFile.CHUNK_VERSION]==0:
		hdr=inf.get_chunk_header()
		if inf.get_error():
			return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
		if hdr[ChunkedFile.CHUNK_ID]==CHUNK_WAVES:
			fr=deserialize_wave_list(inf,song,hdr)
			if fr.has_error():
				return fr
			inf.skip_chunk(hdr)
		else:
			inf.rewind_chunk(hdr)
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new()


func deserialize_wave_list(inf:ChunkedFile,song:Song,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,CHUNK_WAVES,CHUNK_WAVES_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:CHUNK_WAVES,
			FileResult.ERRV_EXP_VERSION:CHUNK_WAVES_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var hdr:Dictionary
	var wav_l:Array=[]
	var wav_r:WaveformReader=WaveformReader.new()
	wav_l.resize(inf.get_16())
	var fr:FileResult
	for i in wav_l.size():
		hdr=inf.get_chunk_header()
		if inf.get_error():
			return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
		fr=wav_r.deserialize(inf,hdr)
		inf.skip_chunk(hdr)
		if fr.has_error():
			return fr
		wav_l[i]=fr.data
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	song.wave_list.append_array(wav_l)
	return FileResult.new()


func deserialize_arpeggios(inf:ChunkedFile,song:Song,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,CHUNK_ARPEGGIOS,CHUNK_ARPEGGIOS_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:CHUNK_ARPEGGIOS,
			FileResult.ERRV_EXP_VERSION:CHUNK_ARPEGGIOS_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var arp_r:ArpeggioReader=ArpeggioReader.new()
	song.arp_list.resize(inf.get_16())
	var fr:FileResult
	for i in song.arp_list.size():
		fr=arp_r.deserialize(inf)
		if fr.has_error():
			return fr
		song.arp_list[i]=fr.data
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new()
