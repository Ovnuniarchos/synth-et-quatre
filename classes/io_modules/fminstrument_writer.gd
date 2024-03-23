extends FmInstrumentIO
class_name FmInstrumentWriter


var _waves:Array


func _init(waves:Array)->void:
	_waves=waves


func write(path:String,inst:FmInstrument)->FileResult:
	inst=inst.duplicate()
	# Pack waveforms
	var wave_list:Dictionary={}
	var min_wave:int=FmInstrument.WAVE.CUSTOM
	for i in 4:
		var w:int=inst.waveforms[i]
		if w in wave_list:
			inst.waveforms[i]=wave_list[w]
		elif w>FmInstrument.WAVE.NOISE and not w in wave_list:
			inst.waveforms[i]=min_wave
			wave_list[w]=min_wave
			min_wave+=1
	# Signature: SFID\0xc\0xa\0x1a\0xa
	var out:ChunkedFile=ChunkedFile.new()
	out.open(path,File.WRITE)
	var err:int=out.start_file(FILE_SIGNATURE,FILE_VERSION)
	if err!=OK:
		return FileResult.new(err,{FileResult.ERRV_FILE:out.get_path()})
	var res:FileResult=serialize(out,inst)
	if res.has_error():
		return res
	res=serialize_waves(out,wave_list)
	if res.has_error():
		return res
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
	var fr:FileResult=serialize_macros(out,inst)
	if fr.has_error():
		return fr
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()


func serialize_macros(out:ChunkedFile,inst:FmInstrument)->FileResult:
	var pw:ParamMacroWriter=ParamMacroWriter.new()
	var macros:Dictionary=inst.macros_as_dict()
	var count:int=0
	for m0 in macros.values():
		if typeof(m0)==TYPE_ARRAY:
			for m1 in m0:
				if m1.steps>0:
					count+=1
		elif m0.steps>0:
			count+=1
	out.store_16(count)
	var fr:FileResult
	for k in macros:
		var type:String=k.trim_prefix("$")
		if typeof(macros[k])==TYPE_ARRAY:
			for opm in macros[k].size():
				pw.set_macro(type,opm)
				fr=pw.serialize(out,macros[k][opm])
				if fr.has_error():
					return fr
		else:
			pw.set_macro(type)
			fr=pw.serialize(out,macros[k])
			if fr.has_error():
				return fr
	return FileResult.new()


func serialize_waves(out:ChunkedFile,packed_waves:Dictionary)->FileResult:
	out.start_chunk(SongIO.CHUNK_WAVES,SongIO.CHUNK_WAVES_VERSION)
	out.store_16(packed_waves.size())
	var syn_w:SynthWaveWriter=SynthWaveWriter.new()
	var sam_w:SampleWaveWriter=SampleWaveWriter.new()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	var fr:FileResult
	for wix in packed_waves.keys():
		var wave:Waveform=_waves[wix-FmInstrument.WAVE.CUSTOM]
		if wave is SynthWave:
			fr=syn_w.serialize(out,wave)
		elif wave is SampleWave:
			fr=sam_w.serialize(out,wave)
		else:
			fr=FileResult.new(FileResult.ERR_INVALID_WAVE_TYPE,{
				FileResult.ERRV_TYPE:wave.get_class(),
				FileResult.ERRV_FILE:out.get_path()
			})
		if fr.has_error():
			return fr
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()
