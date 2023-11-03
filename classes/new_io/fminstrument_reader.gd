extends FmInstrumentIO
class_name FmInstrumentReader


func read(path:String)->FileResult:
	if !GLOBALS.song.can_add_instrument():
		return null
	var f:ChunkedFile=ChunkedFile.new()
	f.open(path,File.READ)
	# Signature
	var err:int=f.start_file(FILE_SIGNATURE,FILE_VERSION)
	if err!=OK:
		return FileResult.new(err,[path,FILE_VERSION])
	# Instrument
	var hdr:Dictionary=f.get_chunk_header()
	var inst:FmInstrument=deserialize(f,hdr)
	f.skip_chunk(hdr)
	if inst==null:
		return null
	hdr=f.get_chunk_header()
	if f.eof_reached():
		return FileResult.new()
	if hdr[ChunkedFile.CHUNK_ID]!=SongIO.CHUNK_WAVES:
		return null
	var fr:FileResult=deserialize_wave_list(f,hdr)
	if fr==null:
		return null
	f.close()
	# Scan for equal waves
	var wave_list:Array=fr.data[0]
	var waves_add:int=wave_list.size()
	for in_w in wave_list.size():
		for song_w in GLOBALS.song.wave_list.size():
			if GLOBALS.song.wave_list[song_w].equals(wave_list[in_w]):
				wave_list[in_w]=song_w+FmInstrument.WAVE.CUSTOM
				waves_add-=1
				break
	if !GLOBALS.song.can_add_wave(waves_add):
		return null
	# Add waveforms
	var new_wave_i:int
	var in_w:int=FmInstrument.WAVE.CUSTOM
	var tmp_waves:Array=inst.waveforms.duplicate()
	for wav in wave_list:
		if typeof(wav)==TYPE_OBJECT:
			new_wave_i=GLOBALS.song.wave_list.size()+FmInstrument.WAVE.CUSTOM
			GLOBALS.song.add_wave(wav)
			wav.calculate()
			SYNCER.send_wave(wav)
			for inst_w in 4:
				if tmp_waves[inst_w]==in_w:
					inst.waveforms[inst_w]=new_wave_i
		else:
			for inst_w in 4:
				if tmp_waves[inst_w]==in_w:
					inst.waveforms[inst_w]=wav
		in_w+=1
	# Add instrument
	inst.file_name=path.get_file()
	GLOBALS.song.add_instrument(inst)
	return FileResult.new()


func deserialize_wave_list(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,SongIO.CHUNK_WAVES,SongIO.CHUNK_WAVES_VERSION):
		return null
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
	return FileResult.new(OK,[wav_l])


func deserialize(inf:ChunkedFile,header:Dictionary)->FmInstrument:
	if not inf.is_chunk_valid(header,CHUNK_ID,CHUNK_VERSION):
		return null
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var ins:FmInstrument=FmInstrument.new()
	ins.op_mask=inf.get_8()
	if version>0:
		ins.clip=bool(inf.get_8())
	else:
		ins.clip=0
	for i in 4:
		ins.attacks[i]=inf.get_8()
		ins.decays[i]=inf.get_8()
		ins.sustains[i]=inf.get_8()
		ins.sustain_levels[i]=inf.get_8()
		ins.releases[i]=inf.get_8()
		ins.repeats[i]=inf.get_8()
		ins.multipliers[i]=inf.get_8()
		ins.dividers[i]=inf.get_8()
		ins.detunes[i]=inf.get_signed_16()
		ins.duty_cycles[i]=inf.get_8()
		ins.waveforms[i]=inf.get_8()
		ins.am_intensity[i]=inf.get_8()
		ins.am_lfo[i]=inf.get_8()
		ins.fm_intensity[i]=inf.get_16()
		ins.fm_lfo[i]=inf.get_8()
		ins.key_scalers[i]=inf.get_8()
	for i in 4:
		for j in 5:
			ins.routings[i][j]=inf.get_8()
	ins.name=inf.get_pascal_string()
	return ins
