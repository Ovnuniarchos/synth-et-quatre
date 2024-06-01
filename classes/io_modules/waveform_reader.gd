extends WaveformIO
class_name WaveformReader


func read(path:String)->FileResult:
	if !GLOBALS.song.can_add_wave():
		return null
	var f:ChunkedFile=ChunkedFile.new()
	f.open(path,File.READ)
	# Signature
	var err:int=f.start_file(FILE_SIGNATURE,FILE_VERSION)
	if err!=OK:
		return FileResult.new(err,[path,FILE_VERSION])
	# Instrument
	var hdr:Dictionary=f.get_chunk_header()
	var fr:FileResult=deserialize(f,hdr)
	if fr.has_error():
		return fr
	GLOBALS.song.add_wave(fr.data)
	return FileResult.new()

func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	var fr:FileResult
	match header[ChunkedFile.CHUNK_ID]:
		SynthWaveReader.CHUNK_ID:
			fr=SynthWaveReader.new().deserialize(inf,header)
		SampleWaveReader.CHUNK_ID:
			fr=SampleWaveReader.new().deserialize(inf,header)
		_:
			fr=FileResult.new(FileResult.ERR_INVALID_WAVE_TYPE,{
				FileResult.ERRV_TYPE:header[ChunkedFile.CHUNK_ID],
				FileResult.ERRV_FILE:inf.get_path()
			})
	return fr
