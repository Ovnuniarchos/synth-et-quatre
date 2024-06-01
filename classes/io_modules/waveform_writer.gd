extends WaveformIO
class_name WaveformWriter


func write(path:String,wave:Waveform)->FileResult:
	var out:ChunkedFile=ChunkedFile.new()
	out.open(path,File.WRITE)
	# Signature: SFMM\0xc\0xa\0x1a\0xa
	var err:int=out.start_file(FILE_SIGNATURE,FILE_VERSION)
	if err!=OK:
		return FileResult.new(err,{FileResult.ERRV_FILE:out.get_path()})
	return serialize(out,wave)


func serialize(out:ChunkedFile,wave:Waveform)->FileResult:
	var fr:FileResult
	if wave is SynthWave:
		fr=SynthWaveWriter.new().serialize(out,wave)
	elif wave is SampleWave:
		fr=SampleWaveWriter.new().serialize(out,wave)
	else:
		fr=FileResult.new(FileResult.ERR_INVALID_WAVE_TYPE,{
			FileResult.ERRV_TYPE:wave.get_class(),
			FileResult.ERRV_FILE:out.get_path()
		})
	if fr.has_error():
		return fr
	return FileResult.new()
