extends Reference
class_name OutputNodeReader


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,NodeComponentIO.OUTPUT_ID,NodeComponentIO.OUTPUT_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:NodeComponentIO.OUTPUT_ID,
			FileResult.ERRV_EXP_VERSION:NodeComponentIO.OUTPUT_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var node:OutputNodeComponent=OutputNodeComponent.new()
	node.clip=inf.get_float()
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new(OK,node)
