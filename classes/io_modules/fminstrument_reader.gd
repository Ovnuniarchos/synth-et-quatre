extends FmInstrumentIO
class_name FmInstrumentReader

const REPEAT:=FmInstrument.REPEAT

func read(path:String)->FileResult:
	if not GLOBALS.song.can_add_instrument():
		return FileResult.new(FileResult.ERR_SONG_MAX_INSTRUMENTS,{"i_max_instrs":SongLimits.MAX_INSTRUMENTS})
	var f:ChunkedFile=ChunkedFile.new()
	f.open(path,File.READ)
	# Signature
	var err:int=f.start_file(FILE_SIGNATURE,FILE_VERSION)
	if err!=OK:
		f.close()
		return FileResult.new(err,[path,FILE_VERSION])
	# Instrument
	var hdr:Dictionary=f.get_chunk_header()
	var fr:FileResult=deserialize(f,hdr)
	if fr.has_error():
		f.close()
		return fr
	var inst:FmInstrument=fr.data
	f.skip_chunk(hdr)
	hdr=f.get_chunk_header()
	if f.eof_reached():
		f.close()
		return FileResult.new(OK,inst)
	if hdr[ChunkedFile.CHUNK_ID]!=SongIO.CHUNK_WAVES:
		f.close()
		return FileResult.new()
	fr=deserialize_wave_list(f,hdr)
	if fr.has_error():
		return fr
	f.close()
	# Scan for equal waves
	var wave_list:Array=fr.data
	var waves_add:int=wave_list.size()
	for in_w in wave_list.size():
		for song_w in GLOBALS.song.wave_list.size():
			if GLOBALS.song.wave_list[song_w].equals(wave_list[in_w]):
				wave_list[in_w]=song_w+FmInstrument.WAVE.CUSTOM
				waves_add-=1
				break
	if !GLOBALS.song.can_add_wave(waves_add):
		return FileResult.new(FileResult.ERR_SONG_MAX_WAVES,{"i_max_waves":SongLimits.MAX_WAVES})
	# Add waveforms
	var new_wave_i:int
	var in_w:int=FmInstrument.WAVE.CUSTOM
	var xlat:Dictionary={}
	for wav in wave_list:
		if typeof(wav)==TYPE_OBJECT:
			new_wave_i=GLOBALS.song.wave_list.size()+FmInstrument.WAVE.CUSTOM
			GLOBALS.song.add_wave(wav)
			wav.calculate()
			SYNCER.send_wave(wav)
			xlat[in_w]=new_wave_i
		else:
			xlat[in_w]=wav
		in_w+=1
	# Translate waveforms
	for inst_w in 4:
		if inst.waveforms[inst_w] in xlat:
			inst.waveforms[inst_w]=xlat[inst.waveforms[inst_w]]
		for mac_w in inst.wave_macros[inst_w].values.size():
			if inst.wave_macros[inst_w].values[mac_w] in xlat:
				inst.wave_macros[inst_w].values[mac_w]=xlat[inst.wave_macros[inst_w].values[mac_w]]
	# Add instrument
	inst.file_name=path.get_file()
	GLOBALS.song.add_instrument(inst)
	return FileResult.new()


func deserialize_wave_list(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,SongIO.CHUNK_WAVES,SongIO.CHUNK_WAVES_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:SongIO.CHUNK_WAVES,
			FileResult.ERRV_EXP_VERSION:SongIO.CHUNK_WAVES_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var hdr:Dictionary
	var wav_l:Array=[]
	var wav_r:WaveformReader=WaveformReader.new()
	var fr:FileResult
	wav_l.resize(inf.get_16())
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
	return FileResult.new(OK,wav_l)


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,CHUNK_ID,CHUNK_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:CHUNK_ID,
			FileResult.ERRV_EXP_VERSION:CHUNK_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var ins:FmInstrument=FmInstrument.new()
	ins.op_mask=inf.get_8()
	if version>0:
		ins.clip=bool(inf.get_8())
	else:
		ins.clip=0
	for i in 4:
		if version>4:
			ins.pre_attacks[i]=inf.get_8()
			ins.pre_attack_levels[i]=inf.get_8()
		ins.attacks[i]=inf.get_8()
		if version>4:
			ins.pre_decays[i]=inf.get_8()
			ins.pre_decay_levels[i]=inf.get_8()
		ins.decays[i]=inf.get_8()
		ins.sustains[i]=inf.get_8()
		ins.sustain_levels[i]=inf.get_8()
		ins.releases[i]=inf.get_8()
		if version>4:
			ins.repeats[i]=inf.get_8()
		else:
			ins.repeats[i]=[REPEAT.OFF,REPEAT.ATTACK,REPEAT.DECAY,REPEAT.SUSTAIN,REPEAT.RELEASE][inf.get_8()%5]
		ins.multipliers[i]=inf.get_8()+(1 if version>3 else 0)
		ins.dividers[i]=inf.get_8()
		ins.detunes[i]=inf.get_signed_16()
		if version>2:
			ins.detune_modes[i]=inf.get_8()
		elif ins.multipliers[i]==0:
			ins.detune_modes[i]=FmInstrument.DETMODE_FIXED
		else:
			ins.multipliers[i]=int(max(0,ins.multipliers[i]-1))
			ins.detune_modes[i]=FmInstrument.DETMODE_NORMAL
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
	var fr:FileResult
	if version>1:
		fr=deserialize_macros(inf,ins)
		if fr.has_error():
			return fr
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new(OK,ins)


func deserialize_macros(inf:ChunkedFile,ins:FmInstrument)->FileResult:
	var count:int=inf.get_16()
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	var pmr:ParamMacroReader=ParamMacroReader.new()
	var fr:FileResult
	while count>0:
		count-=1
		fr=pmr.deserialize(inf)
		if fr.has_error():
			return fr
		if not ins.set_macro(fr.data["type"],fr.data["op"],fr.data["macro"]):
			return FileResult.new(FileResult.ERR_INVALID_MACRO,{
				FileResult.ERRV_FILE:inf.get_path(),
				FileResult.ERRV_TYPE:fr.data["type"],
				FileResult.ERRV_OP:fr.data["op"]
			})
	return FileResult.new()
