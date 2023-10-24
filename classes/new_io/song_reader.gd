extends SongIO
class_name SongReader


func read(path:String)->FileResult:
	var f:ChunkedFile=ChunkedFile.new()
	f.open(path,File.READ)
	var err:int=f.start_file(FILE_SIGNATURE,FILE_VERSION)
	if err!=OK:
		return FileResult.new(err,[path,FILE_VERSION])
	var res:FileResult=deserialize(f)
	f.close()
	if not res.has_error():
		res.data.file_name=path.get_file()
		AUDIO.tracker.stop()
		AUDIO.tracker.reset()
		GLOBALS.set_song(res.data)
	return FileResult.new()


func deserialize(inf:ChunkedFile)->FileResult:
	var song:Song=Song.new()
	# Header
	var hdr:Dictionary=inf.get_chunk_header()
	if not inf.is_chunk_valid(hdr,CHUNK_HEADER,CHUNK_HEADER_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_VERSION)
	song.pattern_length=inf.get_16()
	song.ticks_second=inf.get_16()
	song.ticks_row=inf.get_16()
	song.title=inf.get_pascal_string()
	song.author=inf.get_pascal_string()
	inf.skip_chunk(hdr)
	#
	while true:
		hdr=inf.get_chunk_header()
		if inf.eof_reached():
			break
		match hdr[ChunkedFile.CHUNK_ID]:
			CHUNK_HIGHLIGHTS:
				deserialize_highlights(inf,song,hdr)
			CHUNK_CHANNELS:
				deserialize_channel_list(inf,song,hdr)
			CHUNK_ORDERS:
				deserialize_order_list(inf,song,hdr)
			CHUNK_PATTERNS:
				deserialize_pattern_list(inf,song,hdr)
			CHUNK_INSTRUMENTS:
				deserialize_instrument_list(inf,song,hdr)
			CHUNK_WAVES:
				deserialize_wave_list(inf,song,hdr)
			_:
				inf.invalid_chunk(hdr)
		inf.skip_chunk(hdr)
	#
	# TODO: Check orders' patterns validity
	# TODO: Check patterns' instruments/arpeggios validity (instruments may be null)
	# TODO: Check instruments' waves validity
	#
	return FileResult.new(OK,song)


func deserialize_highlights(inf:ChunkedFile,song:Song,header:Dictionary)->void:
	if inf.is_chunk_valid(header,CHUNK_HIGHLIGHTS,CHUNK_HIGHLIGHTS_VERSION):
		song.minor_highlight=inf.get_16()
		song.major_highlight=inf.get_16()


func deserialize_channel_list(inf:ChunkedFile,song:Song,header:Dictionary)->void:
	if not inf.is_chunk_valid(header,CHUNK_CHANNELS,CHUNK_CHANNELS_VERSION):
		return
	var nc:int=inf.get_16()
	song.num_channels=nc
	for i in nc:
		inf.get_ascii(4) # Unused
		var nfx:int=inf.get_8()
		song.num_fxs[i]=nfx


func deserialize_pattern_list(inf:ChunkedFile,song:Song,header:Dictionary)->void:
	if not inf.is_chunk_valid(header,CHUNK_PATTERNS,CHUNK_PATTERNS_VERSION):
		return
	var hdr:Dictionary
	var pat_l:Array=[]
	var pat_r:PatternReader=PatternReader.new(song.pattern_length)
	pat_l.resize(SongLimits.MAX_CHANNELS)
	for i in song.num_channels:
		pat_l[i]=[]
		pat_l[i].resize(inf.get_16())
		for j in pat_l[i].size():
			hdr=inf.get_chunk_header()
			pat_l[i][j]=pat_r.deserialize(inf,hdr)
			inf.skip_chunk(hdr)
	for i in range(song.num_channels,SongLimits.MAX_CHANNELS):
		pat_l[i]=[Pattern.new()]
	song.pattern_list=pat_l


func deserialize_order_list(inf:ChunkedFile,song:Song,header:Dictionary)->void:
	if not inf.is_chunk_valid(header,CHUNK_ORDERS,CHUNK_ORDERS_VERSION):
		return
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


func deserialize_instrument_list(inf:ChunkedFile,song:Song,header:Dictionary)->void:
	if not inf.is_chunk_valid(header,CHUNK_INSTRUMENTS,CHUNK_INSTRUMENTS_VERSION):
		return
	var hdr:Dictionary
	var inst_l:Array=[]
	var ins_r:FmInstrumentReader=FmInstrumentReader.new()
	for i in 4:
		song.lfo_frequencies[i]=inf.get_16()/256.0
		song.lfo_waves[i]=inf.get_8()
		song.lfo_duty_cycles[i]=inf.get_8()
	inst_l.resize(inf.get_16())
	for i in inst_l.size():
		hdr=inf.get_chunk_header()
		match hdr[ChunkedFile.CHUNK_ID]:
			FmInstrumentIO.CHUNK_ID:
				inst_l[i]=ins_r.deserialize(inf,hdr)
			_:
				inf.invalid_chunk(hdr)
		inf.skip_chunk(hdr)
	song.instrument_list=inst_l
	if header[ChunkedFile.CHUNK_VERSION]==0:
		hdr=inf.get_chunk_header()
		if hdr[ChunkedFile.CHUNK_ID]==CHUNK_WAVES:
			deserialize_wave_list(inf,song,hdr)
			inf.skip_chunk(hdr)
		else:
			inf.rewind_chunk(hdr)


func deserialize_wave_list(inf:ChunkedFile,song:Song,header:Dictionary)->void:
	if not inf.is_chunk_valid(header,CHUNK_WAVES,CHUNK_WAVES_VERSION):
		return
	var hdr:Dictionary
	var wav_l:Array=[]
	var syn_r:SynthWaveReader=SynthWaveReader.new()
	var sam_r:SampleWaveReader=SampleWaveReader.new()
	wav_l.resize(inf.get_16())
	for i in wav_l.size():
		hdr=inf.get_chunk_header()
		match hdr[ChunkedFile.CHUNK_ID]:
			SynthWaveReader.CHUNK_ID:
				wav_l[i]=syn_r.deserialize(inf,hdr)
			SampleWaveReader.CHUNK_ID:
				wav_l[i]=sam_r.deserialize(inf,hdr)
			_:
				inf.invalid_chunk(hdr)
		inf.skip_chunk(hdr)
	song.wave_list=wav_l
