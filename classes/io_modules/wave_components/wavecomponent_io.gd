extends Reference
class_name WaveComponentIO


const NOISE_ID:String="nOIW"
const NOISE_VERSION:int=0
const RECTANGLE_ID:String="rECW"
const RECTANGLE_VERSION:int=0
const SAW_ID:String="sAWW"
const SAW_VERSION:int=0
const SINE_ID:String="sINW"
const SINE_VERSION:int=0
const TRIANGLE_ID:String="tRIW"
const TRIANGLE_VERSION:int=0
const BPF_ID:String="bPFF"
const BPF_VERSION:int=0
const BRF_ID:String="bRFF"
const BRF_VERSION:int=0
const CLAMP_ID:String="cLAF"
const CLAMP_VERSION:int=0
const HPF_ID:String="hPFF"
const HPF_VERSION:int=0
const LPF_ID:String="lPFF"
const LPF_VERSION:int=0
const NORMALIZE_ID:String="nORF"
const NORMALIZE_VERSION:int=0
const QUANTIZE_ID:String="qUAF"
const QUANTIZE_VERSION:int=0


var components:Array


func _init(wc:Array)->void:
	components=wc


func _deserialize_start(inf:ChunkedFile,c:WaveComponent,_version:int)->void:
	c.output_mode=inf.get_8()
	c.vol=inf.get_float()
	c.am=inf.get_float()
	c.xm=inf.get_float()
	var ic:int=inf.get_signed_16()
	if ic<0:
		c.input_comp=null
	elif ic<components.size():
		c.input_comp=components[ic]
	else:
		c.input_comp=c


func deserialize(_inf:ChunkedFile,_header:Dictionary)->FileResult:
	return null


func _serialize_start(out:ChunkedFile,c:WaveComponent,tag:String,version:int)->void:
	out.start_chunk(tag,version)
	out.store_8(c.output_mode)
	out.store_float(c.vol)
	out.store_float(c.am)
	out.store_float(c.xm)
	out.store_16(components.find(c.input_comp))
