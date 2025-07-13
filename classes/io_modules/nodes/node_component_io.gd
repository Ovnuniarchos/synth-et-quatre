extends Reference
class_name NodeComponentIO


const OUTPUT_ID:String="oUTN"
const OUTPUT_VERSION:int=0
const NOISE_ID:String="nOIN"
const NOISE_VERSION:int=0
const PULSE_ID:String="pULN"
const PULSE_VERSION:int=0
const RAMP_ID:String="rAMN"
const RAMP_VERSION:int=0
const SAW_ID:String="sAWN"
const SAW_VERSION:int=0
const SINE_ID:String="sINN"
const SINE_VERSION:int=0
const TRIANGLE_ID:String="tRIN"
const TRIANGLE_VERSION:int=0
const CLAMP_ID:String="cLMN"
const CLAMP_VERSION:int=0
const CLIP_ID:String="cLIN"
const CLIP_VERSION:int=0
const MAP_RANGE_ID:String="mARN"
const MAP_RANGE_VERSION:int=1
const MAP_WAVE_ID:String="mWAN"
const MAP_WAVE_VERSION:int=0
const MIX_ID:String="mIXN"
const MIX_VERSION:int=0
const NORMALIZE_ID:String="nORN"
const NORMALIZE_VERSION:int=0
const DECAY_ID:String="dECN"
const DECAY_VERSION:int=0
const POWER_ID:String="pOWN"
const POWER_VERSION:int=0
const MUX_ID:String="mUXN"
const MUX_VERSION:int=0
const QUANTIZE_ID:String="qUAN"
const QUANTIZE_VERSION:int=0
const DECIMATE_ID:String="dECI"
const DECIMATE_VERSION:int=0
const LOWPASS_ID:String="lOWP"
const LOWPASS_VERSION:int=0
const HIGHPASS_ID:String="hIGP"
const HIGHPASS_VERSION:int=0
const BANDPASS_ID:String="bPSF"
const BANDPASS_VERSION:int=0
const BANDREJECT_ID:String="bPRF"
const BANDREJECT_VERSION:int=0


func _serialize_start(out:ChunkedFile,comp:WaveNodeComponent,tag:String,version:int)->void:
	out.start_chunk(tag,version)
	out.store_float(comp.viz_rect.position.x)
	out.store_float(comp.viz_rect.position.y)
	out.store_float(comp.viz_rect.size.x)
	out.store_float(comp.viz_rect.size.y)
	if tag!=OUTPUT_ID:
		out.store_float(comp.range_from)
		out.store_float(comp.range_length)


func _serialize_end(out:ChunkedFile,comp:WaveNodeComponent)->FileResult:
	var inputs_connected:int=0
	for input in comp.inputs:
		if not input[WaveNodeComponent.SLOT_IN].empty():
			inputs_connected+=1
	out.store_16(inputs_connected)
	var wave:NodeWave=comp.wave.get_ref()
	for input in comp.inputs:
		if input[WaveNodeComponent.SLOT_IN].empty():
			continue
		out.store_ascii(input[WaveNodeComponent.SLOT_ID])
		out.store_16(input[WaveNodeComponent.SLOT_IN].size())
		for comp_from in input[WaveNodeComponent.SLOT_IN]:
			out.store_16(wave.find_component(comp_from))
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()


func _deserialize_start(inf:ChunkedFile,comp:GDScript,header:Dictionary,tag:String,version:int)->FileResult:
	if not inf.is_chunk_valid(header,tag,version):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:tag,
			FileResult.ERRV_EXP_VERSION:version,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var c:WaveNodeComponent=comp.new()
	c.viz_rect.position.x=inf.get_float()
	c.viz_rect.position.y=inf.get_float()
	c.viz_rect.size.x=inf.get_float()
	c.viz_rect.size.y=inf.get_float()
	if comp!=OutputNodeComponent:
		c.range_from=inf.get_float()
		c.range_length=inf.get_float()
	return FileResult.new(OK,c)


func _deserialize_end(inf:ChunkedFile,comp:WaveNodeComponent)->FileResult:
	var input_count:int=inf.get_16()
	var in_id:String
	for i in input_count:
		in_id=inf.get_ascii(4)
		var slot:Dictionary=comp.get_slot(in_id)
		if slot.empty():
			return FileResult.new(FileResult.ERR_INVALID_INPUT_SLOT,{
				FileResult.ERRV_TYPE:in_id,
				FileResult.ERRV_COMPONENT:comp.NODE_TYPE
			})
		var connection_count:int=inf.get_16()
		for j in connection_count:
			slot[WaveNodeComponent.SLOT_IN].append(inf.get_16())
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new()
