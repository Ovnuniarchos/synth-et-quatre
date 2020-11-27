extends Reference
class_name IOInstrument


const FILE_SIGNATURE:String="SFID\u000d\u000a\u001a\u000a"


func obj_save(path:String)->void:
	var inst:FmInstrument=GLOBALS.song.instrument_list[GLOBALS.curr_instrument]
	var sinst:FmInstrument=inst.duplicate()
	var wave_list:Dictionary={}
	for i in range(4):
		if inst.waveforms[i]>FmInstrument.WAVE.NOISE and !wave_list.has(inst.waveforms[i]):
			var w_new:int=wave_list.size()+FmInstrument.WAVE.CUSTOM
			var w_old:int=inst.waveforms[i]
			for _j in range(4):
				if sinst.waveforms[i]==w_old:
					sinst.waveforms[i]=-w_new
			wave_list[w_old]=w_old
	for i in range(4):
		sinst.waveforms[i]=abs(sinst.waveforms[i])
	var f:ChunkedFile=ChunkedFile.new()
	f.open(path,File.WRITE)
	# Signature: SFMM\0xc\0xa\0x1a\0xa
	f.store_string(FILE_SIGNATURE)
	f.store_16(0)
	# Serialize instrument
	sinst.serialize(f)
	# Serialize waveforms
	f.start_chunk(Song.CHUNK_WAVES,0)
	f.store_16(wave_list.size())
	for wi in wave_list:
		GLOBALS.song.wave_list[wi-FmInstrument.WAVE.NOISE-1].serialize(f)
	#
	inst.file_name=path.get_file()
	f.close()


func obj_load(path:String)->void:
	if !GLOBALS.song.can_add_instrument():
		return
	var f:ChunkedFile=ChunkedFile.new()
	f.open(path,File.READ)
	# Signature
	var sig:String=f.get_ascii(8)
	var file_version:int=f.get_16()
	if sig!=FILE_SIGNATURE:
		return
	# Instrument data
	var hdr:Dictionary=f.get_chunk_header()
	if hdr[ChunkedFile.CHUNK_ID]!=FmInstrument.CHUNK_ID:
		return
	var ni:FmInstrument=FmInstrument.new()
	ni.deserialize(f,ni)
	# Waveforms
	hdr=f.get_chunk_header()
	if hdr[ChunkedFile.CHUNK_ID]!=Song.CHUNK_WAVES:
		return
	var wav_l:Array=[]
	wav_l.resize(f.get_16())
	for i in range(wav_l.size()):
		hdr=f.get_chunk_header()
		match hdr[ChunkedFile.CHUNK_ID]:
			SynthWave.CHUNK_ID:
				var n:SynthWave=SynthWave.new()
				n.deserialize(f,n)
				wav_l[i]=n
			SampleWave.CHUNK_ID:
				var n:SampleWave=SampleWave.new()
				n.deserialize(f,n)
				wav_l[i]=n
			_:
				print("Unrecognized chunk [%s]"%[hdr[ChunkedFile.CHUNK_ID]])
	#
	f.close()
	# Scan for equal waves
	var waves_add:int=wav_l.size()
	for in_w in range(wav_l.size()):
		for song_w in range(GLOBALS.song.wave_list.size()):
			if GLOBALS.song.wave_list[song_w].equals(wav_l[in_w]):
				wav_l[in_w]=song_w+FmInstrument.WAVE.CUSTOM
				waves_add-=1
				break
	if !GLOBALS.song.can_add_wave(waves_add):
		return
	# Add waveforms
	var new_wave_i:int
	var in_w:int=FmInstrument.WAVE.CUSTOM
	for wav in wav_l:
		if typeof(wav)==TYPE_OBJECT:
			new_wave_i=GLOBALS.song.wave_list.size()+FmInstrument.WAVE.CUSTOM
			GLOBALS.song.add_wave(wav)
			wav.calculate()
			GLOBALS.song.send_wave(wav,SYNTH)
			for inst_w in range(4):
				if ni.waveforms[inst_w]==in_w:
					ni.waveforms[inst_w]=new_wave_i
		else:
			for inst_w in range(4):
				if ni.waveforms[inst_w]==in_w:
					ni.waveforms[inst_w]=wav_l[wav-FmInstrument.WAVE.CUSTOM]
		in_w+=1
	# Add instrument
	ni.file_name=path.get_file()
	GLOBALS.song.add_instrument(ni)
