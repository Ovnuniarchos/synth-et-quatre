extends FmInstrumentIO
class_name FmInstrumentReader


# TODO: File reader


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
