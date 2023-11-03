extends FmInstrumentIO
class_name FmInstrumentWriter


var _waves:Array


func _init(waves:Array)->void:
	_waves=waves


func write(path:String,inst:FmInstrument,waves:Array)->FileResult:
	var out:ChunkedFile=ChunkedFile.new()
	out.open(path,File.WRITE)
	inst=inst.duplicate()
	# Pack waveforms
	var wave_list:Dictionary={}
	var min_wave:int=FmInstrument.WAVE.CUSTOM
	for i in 4:
		var w:int=inst.waveforms[i]
		if w in wave_list:
			inst.waveforms[i]=wave_list[w]
		elif w>FmInstrument.WAVE.NOISE and not w in wave_list:
			wave_list[w]=min_wave
			min_wave+=1
	# Signature: SFMM\0xc\0xa\0x1a\0xa
	var err:int=out.start_file(FILE_SIGNATURE,FILE_VERSION)
	if err!=OK:
		return FileResult.new(err,[path,FILE_VERSION])
	var res:FileResult=serialize(out,inst)
	if res.has_error():
		return res
	res=serialize_waves(out,inst)
	return FileResult.new()


func serialize(out:ChunkedFile,inst:FmInstrument)->FileResult:
	out.start_chunk(CHUNK_ID,CHUNK_VERSION)
	out.store_8(inst.op_mask)
	out.store_8(int(inst.clip))
	for i in 4:
		out.store_8(inst.attacks[i])
		out.store_8(inst.decays[i])
		out.store_8(inst.sustains[i])
		out.store_8(inst.sustain_levels[i])
		out.store_8(inst.releases[i])
		out.store_8(inst.repeats[i])
		out.store_8(inst.multipliers[i])
		out.store_8(inst.dividers[i])
		out.store_16(inst.detunes[i])
		out.store_8(inst.duty_cycles[i])
		out.store_8(inst.waveforms[i])
		out.store_8(inst.am_intensity[i])
		out.store_8(inst.am_lfo[i])
		out.store_16(inst.fm_intensity[i])
		out.store_8(inst.fm_lfo[i])
		out.store_8(inst.key_scalers[i])
	for r in inst.routings:
		for v in r:
			out.store_8(v)
	out.store_pascal_string(inst.name)
	out.end_chunk()
	return FileResult.new()


func serialize_waves(out:ChunkedFile,inst:FmInstrument)->FileResult:
	out.start_chunk(SongIO.CHUNK_WAVES,SongIO.CHUNK_WAVES_VERSION)
	out.store_16(_waves.size())
	var syn_w:SynthWaveWriter=SynthWaveWriter.new()
	var sam_w:SampleWaveWriter=SampleWaveWriter.new()
	for wave in _waves:
		if wave is SynthWave:
			syn_w.serialize(out,wave)
		elif wave is SampleWave:
			sam_w.serialize(out,wave)
	out.end_chunk()
	return FileResult.new()
