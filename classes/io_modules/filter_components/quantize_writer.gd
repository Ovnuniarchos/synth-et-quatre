extends WaveComponentIO
class_name QuantizeFilterWriter


func _init(wc:Array).(wc)->void:
	pass


func serialize(out:ChunkedFile,f:QuantizeFilter)->void:
	_serialize_start(out,f,QUANTIZE_ID,QUANTIZE_VERSION)
	out.store_8(f.steps)
	out.end_chunk()
