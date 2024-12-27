extends Reference
class_name NodeComponentIO


const OUTPUT_ID:String="oUTN"
const OUTPUT_VERSION:int=0


func _serialize_start(out:ChunkedFile,c:WaveComponent,tag:String,version:int)->void:
	out.start_chunk(tag,version)
