extends WaveformIO
class_name WaveformReader


func read(path:String)->FileResult:
	if !GLOBALS.song.can_add_wave():
		return FileResult.new(FileResult.ERR_SONG_MAX_WAVES,{"i_max_waves":SongLimits.MAX_WAVES})
	var f:ChunkedFile=ChunkedFile.new()
	f.open(path,File.READ)
	# Signature
	var err:int=f.start_file(FILE_SIGNATURE,FILE_VERSION)
	if err!=OK:
		return FileResult.new(err,[path,FILE_VERSION])
	# Waveform
	var hdr:Dictionary=f.get_chunk_header()
	var fr:FileResult=deserialize(f,hdr)
	if fr.has_error():
		return fr
	GLOBALS.song.add_wave(fr.data)
	return FileResult.new()


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	match header[ChunkedFile.CHUNK_ID]:
		SynthWaveReader.CHUNK_ID:
			return SynthWaveReader.new().deserialize(inf,header)
		SampleWaveReader.CHUNK_ID:
			return SampleWaveReader.new().deserialize(inf,header)
	return FileResult.new(FileResult.ERR_INVALID_WAVE_TYPE,{
		FileResult.ERRV_TYPE:header[ChunkedFile.CHUNK_ID],
		FileResult.ERRV_FILE:inf.get_path()
	})
