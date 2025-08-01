extends Resource
class_name MacroIO

const ARPEGGIO_FILE_SIGNATURE:String="SFAD\u000d\u000a\u001a\u000a"
const ARPEGGIO_FILE_VERSION:int=0

const ARPEGGIO_ID:String="aRPG"
const ARPEGGIO_VERSION:int=0
const MACRO_ID:String="mACR"
const MACRO_VERSION:int=0
const MACRO_TONE:String="mTON"
const MACRO_VOLUME:String="mVOL"
const MACRO_PAN:String="mPAN"
const MACRO_CHANNEL_INVERT:String="mCHI"
const MACRO_KEY_ON:String="mKON"
const MACRO_OP_ENABLE:String="mOPN"
const MACRO_CLIP:String="mCLI"
const MACRO_DUTY_CYCLE:String="mDUC"
const MACRO_WAVE:String="mWAV"
const MACRO_PRE_ATTACK:String="mPAR"
const MACRO_PRE_ATTACK_LEVEL:String="mPAL"
const MACRO_ATTACK:String="mATR"
const MACRO_PRE_DECAY:String="mPDR"
const MACRO_PRE_DECAY_LEVEL:String="mPDL"
const MACRO_DECAY:String="mDER"
const MACRO_SUSTAIN_LEVEL:String="mSUL"
const MACRO_SUSTAIN_RATE:String="mSUR"
const MACRO_RELEASE:String="mRER"
const MACRO_REPEAT:String="mRPT"
const MACRO_AM_INTENSITY:String="mAMI"
const MACRO_KEY_SCALING:String="mKSC"
const MACRO_MULTIPLIER:String="mMUL"
const MACRO_DIVIDER:String="mDIV"
const MACRO_DETUNE:String="mDET"
const MACRO_DETUNE_MODE:String="mDTM"
const MACRO_FM_INTENSITY:String="mFMI"
const MACRO_AM_LFO:String="mAML"
const MACRO_FM_LFO:String="mFML"
const MACRO_PHASE:String="mPHI"
const MACRO_OP1:String="mOP1"
const MACRO_OP2:String="mOP2"
const MACRO_OP3:String="mOP3"
const MACRO_OP4:String="mOP4"
const MACRO_OUTPUT:String="mOUT"
const VALID_MACROS:Array=[MACRO_TONE,MACRO_VOLUME,MACRO_PAN,
	MACRO_CHANNEL_INVERT,MACRO_KEY_ON,MACRO_OP_ENABLE,MACRO_CLIP,MACRO_DUTY_CYCLE,
	MACRO_WAVE,MACRO_PRE_ATTACK,MACRO_PRE_ATTACK_LEVEL,MACRO_ATTACK,
	MACRO_PRE_DECAY,MACRO_PRE_DECAY_LEVEL,MACRO_DECAY,MACRO_SUSTAIN_LEVEL,MACRO_SUSTAIN_RATE,
	MACRO_RELEASE,MACRO_REPEAT,MACRO_AM_INTENSITY,MACRO_KEY_SCALING,
	MACRO_MULTIPLIER,MACRO_DIVIDER,MACRO_DETUNE,MACRO_DETUNE_MODE,MACRO_FM_INTENSITY,
	MACRO_AM_LFO,MACRO_FM_LFO,MACRO_PHASE,MACRO_OP1,MACRO_OP2,MACRO_OP3,MACRO_OP4,MACRO_OUTPUT]
const GLOBAL_MACROS:Array=[MACRO_TONE,MACRO_VOLUME,MACRO_PAN,MACRO_CHANNEL_INVERT,
	MACRO_KEY_ON,MACRO_OP_ENABLE,MACRO_CLIP]
const MACRO_LIMITS:Dictionary={
	MACRO_TONE:[-200,14300],
	MACRO_VOLUME:[0,255],
	MACRO_PAN:[1,255],
	MACRO_CHANNEL_INVERT:[0,0],
	MACRO_KEY_ON:[1,5],
	MACRO_OP_ENABLE:[0,0],
	MACRO_CLIP:[0,0],
	MACRO_DUTY_CYCLE:[0,255],
	MACRO_WAVE:[0,255],
	MACRO_PRE_ATTACK:[0,255],
	MACRO_PRE_ATTACK_LEVEL:[0,255],
	MACRO_ATTACK:[0,255],
	MACRO_PRE_DECAY:[0,255],
	MACRO_PRE_DECAY_LEVEL:[0,255],
	MACRO_DECAY:[0,255],
	MACRO_SUSTAIN_LEVEL:[0,255],
	MACRO_SUSTAIN_RATE:[0,255],
	MACRO_RELEASE:[0,255],
	MACRO_REPEAT:[0,4],
	MACRO_AM_INTENSITY:[0,255],
	MACRO_KEY_SCALING:[0,7],
	MACRO_MULTIPLIER:[1,32],
	MACRO_DIVIDER:[1,32],
	MACRO_DETUNE:[-12000,12000],
	MACRO_DETUNE_MODE:[0,2],
	MACRO_FM_INTENSITY:[0,255],
	MACRO_AM_LFO:[0,3],
	MACRO_FM_LFO:[0,3],
	MACRO_PHASE:[0,255],
	MACRO_OP1:[0,255],
	MACRO_OP2:[0,255],
	MACRO_OP3:[0,255],
	MACRO_OP4:[0,255],
	MACRO_OUTPUT:[0,255]
}


func _serialize_start(out:ChunkedFile,m:Macro,chunk:String,version:int)->void:
	out.start_chunk(chunk,version)
	out.store_16(m.loop_start)
	out.store_16(m.loop_end)
	out.store_16(m.release_loop_start)
	out.store_16(m.steps)
	out.store_16(m.delay)


func _deserialize_start(inf:ChunkedFile,chunk:String,version:int)->FileResult:
	var hdr:Dictionary=inf.get_chunk_header()
	if not inf.is_chunk_valid(hdr,chunk,version):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			"header":hdr,
			FileResult.ERRV_CHUNK:inf.get_chunk_id(hdr),
			FileResult.ERRV_VERSION:inf.get_chunk_version(hdr),
			FileResult.ERRV_EXP_CHUNK:chunk,
			FileResult.ERRV_EXP_VERSION:version,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var m:Dictionary={
		Macro.PARAM_LOOP_START:inf.get_signed_16(),
		Macro.PARAM_LOOP_END:inf.get_signed_16(),
		Macro.PARAM_RELEASE_LOOP_START:inf.get_signed_16(),
		Macro.PARAM_STEPS:inf.get_16(),
		Macro.PARAM_DELAY:inf.get_16()
	}
	return FileResult.new(inf.get_error(),{"header":hdr,FileResult.ERRV_FILE:inf.get_path(),"data":m})


func _serialize_end(out:ChunkedFile,m:Macro)->FileResult:
	for i in m.steps:
		out.store_64(m.values[i])
	out.end_chunk()
	if out.get_error():
		return FileResult.new(out.get_error(),{FileResult.ERRV_FILE:out.get_path()})
	return FileResult.new()


func _deserialize_end(inf:ChunkedFile,m:Dictionary)->FileResult:
	m[Macro.PARAM_VALUES]=[]
	m[Macro.PARAM_VALUES].resize(m[Macro.PARAM_STEPS])
	for i in m[Macro.PARAM_STEPS]:
		m[Macro.PARAM_VALUES][i]=inf.get_64()
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new()


func is_valid_macro(id:String,op:int)->bool:
	if op==-1:
		return id in GLOBAL_MACROS
	return op>=0 and op<=3 and id in VALID_MACROS
