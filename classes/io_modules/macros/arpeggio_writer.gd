extends MacroIO
class_name ArpeggioWriter


var arpeggio_ix:int

func set_arpeggio(ix:int)->void:
	arpeggio_ix=ix


func serialize(out:ChunkedFile,a:Arpeggio)->FileResult:
	if a.steps<1:
		return FileResult.new()
	_serialize_start(out,a,ARPEGGIO_ID,ARPEGGIO_VERSION)
	out.store_pascal_string(a.name)
	out.store_8(arpeggio_ix)
	return _serialize_end(out,a)
