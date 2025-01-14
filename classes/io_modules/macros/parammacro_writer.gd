extends MacroIO
class_name ParamMacroWriter


var macro_id:String=""
var macro_op:int=-INF


func set_macro(id:String,op:int=-1)->void:
	macro_id=id
	macro_op=op


func serialize(out:ChunkedFile,m:ParamMacro)->FileResult:
	if not is_valid_macro(macro_id,macro_op):
		return FileResult.new(FileResult.ERR_INVALID_MACRO,{
			FileResult.ERRV_FILE:out.get_path(),
			FileResult.ERRV_TYPE:macro_id,
			FileResult.ERRV_OP:macro_op
		})
	if m.steps<1:
		return FileResult.new()
	_serialize_start(out,m,MACRO_ID,MACRO_VERSION)
	out.store_8(m.mode)
	out.store_16(m.tick_div)
	out.store_ascii(macro_id)
	out.store_8(macro_op)
	return _serialize_end(out,m)
