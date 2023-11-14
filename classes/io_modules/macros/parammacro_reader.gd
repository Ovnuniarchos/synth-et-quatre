extends MacroIO
class_name ParamMacroReader


func deserialize(inf:ChunkedFile)->FileResult:
	var fr:FileResult=_deserialize_start(inf,MACRO_ID,MACRO_VERSION)
	if fr.has_error():
		inf.skip_chunk(fr.error_data["header"])
		return fr
	var hdr:Dictionary=fr.data["header"]
	var params:Dictionary=fr.data["data"]
	var pm:ParamMacro=ParamMacro.new()
	pm.relative=bool(inf.get_8())
	pm.tick_div=inf.get_16()
	var type:String=inf.get_ascii(4)
	var op:int=inf.get_8()
	fr=_deserialize_end(inf,params)
	if fr.has_error():
		inf.skip_chunk(hdr)
		return fr
	pm.set_parameters(params)
	inf.skip_chunk(hdr)
	return FileResult.new(OK,{"op":op if op!=255 else -1,"type":type,"macro":pm})
