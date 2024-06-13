extends MacroIO
class_name ArpeggioReader


func read(path:String)->FileResult:
	if !GLOBALS.song.can_add_arp():
		return FileResult.new(FileResult.ERR_SONG_MAX_WAVES,{"i_max_arps":SongLimits.MAX_ARPEGGIOS})
	var f:ChunkedFile=ChunkedFile.new()
	f.open(path,File.READ)
	# Signature
	var err:int=f.start_file(ARPEGGIO_FILE_SIGNATURE,ARPEGGIO_FILE_VERSION)
	if err!=OK:
		f.close()
		return FileResult.new(err,[path,ARPEGGIO_FILE_VERSION])
	# Arpeggio
	var fr:FileResult=deserialize(f)
	f.close()
	if fr.has_error():
		return fr
	fr.data.file_name=path.get_file()
	GLOBALS.song.add_arp(fr.data)
	return FileResult.new()


func deserialize(inf:ChunkedFile)->FileResult:
	var fr:FileResult=_deserialize_start(inf,ARPEGGIO_ID,ARPEGGIO_VERSION)
	if fr.has_error():
		inf.skip_chunk(fr.error_data["header"])
		return fr
	var hdr:Dictionary=fr.data["header"]
	var params:Dictionary=fr.data["data"]
	var arp:Arpeggio=Arpeggio.new()
	arp.name=inf.get_pascal_string()
	fr=_deserialize_end(inf,params)
	if fr.has_error():
		inf.skip_chunk(hdr)
		return fr
	arp.set_parameters(params)
	inf.skip_chunk(hdr)
	return FileResult.new(OK,arp)
