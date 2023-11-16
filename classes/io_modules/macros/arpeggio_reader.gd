extends MacroIO
class_name ArpeggioReader


func deserialize(inf:ChunkedFile)->FileResult:
	var fr:FileResult=_deserialize_start(inf,ARPEGGIO_ID,ARPEGGIO_VERSION)
	if fr.has_error():
		inf.skip_chunk(fr.error_data["header"])
		return fr
	var hdr:Dictionary=fr.data["header"]
	var params:Dictionary=fr.data["data"]
	var arp:Arpeggio=Arpeggio.new()
	arp.name=inf.get_pascal_string()
	var index:int=inf.get_8()
	fr=_deserialize_end(inf,params)
	if fr.has_error():
		inf.skip_chunk(hdr)
		return fr
	arp.set_parameters(params)
	inf.skip_chunk(hdr)
	return FileResult.new(OK,{"index":index,"arpeggio":arp})
