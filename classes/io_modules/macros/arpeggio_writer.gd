extends MacroIO
class_name ArpeggioWriter


func serialize(out:ChunkedFile,a:Arpeggio)->FileResult:
	_serialize_start(out,a,ARPEGGIO_ID,ARPEGGIO_VERSION)
	out.store_pascal_string(a.name)
	return _serialize_end(out,a)
