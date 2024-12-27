extends Reference
class_name OutputNodeWriter


func serialize(out:ChunkedFile,node:OutputNodeComponent)->FileResult:
	out.start_chunk(NodeComponentIO.OUTPUT_ID,NodeComponentIO.OUTPUT_VERSION)
	out.store_float(node.clip)
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()
