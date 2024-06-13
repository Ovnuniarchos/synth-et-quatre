extends MacroIO
class_name ArpeggioWriter


func write(path:String,arp:Arpeggio)->FileResult:
	var out:ChunkedFile=ChunkedFile.new()
	out.open(path,File.WRITE)
	# Signature: SFAD\0xc\0xa\0x1a\0xa
	var err:int=out.start_file(ARPEGGIO_FILE_SIGNATURE,ARPEGGIO_FILE_VERSION)
	if err!=OK:
		out.close()
		return FileResult.new(err,{FileResult.ERRV_FILE:out.get_path()})
	var fr:FileResult=serialize(out,arp)
	out.close()
	return fr


func serialize(out:ChunkedFile,arp:Arpeggio)->FileResult:
	_serialize_start(out,arp,ARPEGGIO_ID,ARPEGGIO_VERSION)
	out.store_pascal_string(arp.name)
	return _serialize_end(out,arp)
