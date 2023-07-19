extends Instrument
class_name FmInstrument

enum WAVE{RECTANGLE,SAW,TRIANGLE,NOISE,CUSTOM}
enum REPEAT{OFF,RELEASE,SUSTAIN,DECAY,ATTACK}
const TYPE:String="FmInstrument"
const CHUNK_ID:String="fM4I"
const CHUNK_VERSION:int=1

var op_mask:int=1
var clip:bool=false
var attacks:Array=[240,240,240,240]
var decays:Array=[192,192,192,192]
var sustains:Array=[0,0,0,0]
var sustain_levels:Array=[192,192,192,192]
var releases:Array=[32,32,32,32]
var key_scalers:Array=[0,0,0,0]
var repeats:Array=[REPEAT.OFF,REPEAT.OFF,REPEAT.OFF,REPEAT.OFF]
var multipliers:Array=[1,1,1,1]
var dividers:Array=[0,0,0,0]
var detunes:Array=[0,0,0,0]
var duty_cycles:Array=[0,0,0,0]
var waveforms:Array=[WAVE.TRIANGLE,WAVE.TRIANGLE,WAVE.TRIANGLE,WAVE.TRIANGLE]
var am_intensity:Array=[0,0,0,0]
var am_lfo:Array=[0,0,0,0]
var fm_intensity:Array=[0,0,0,0]
var fm_lfo:Array=[0,0,0,0]
var routings:Array=[
	[64,0,0,0,255],
	[0,0,0,0,0],
	[0,0,0,0,0],
	[0,0,0,0,0]
]
var freq_macro:ParamMacro=ParamMacro.new()
var op_freq_macro:Array=[ParamMacro.new(),ParamMacro.new(),ParamMacro.new(),ParamMacro.new()]
var volume_macro:ParamMacro=ParamMacro.new()
var pan_macro:ParamMacro=ParamMacro.new()
var chanl_invert_macro:ParamMacro=ParamMacro.new(false)
var clip_macro:ParamMacro=ParamMacro.new(false)
var duty_macros:Array=[ParamMacro.new(),ParamMacro.new(),ParamMacro.new(),ParamMacro.new()]
var wave_macros:Array=[ParamMacro.new(false),ParamMacro.new(false),ParamMacro.new(false),ParamMacro.new(false)]
var attack_macros:Array=[ParamMacro.new(),ParamMacro.new(),ParamMacro.new(),ParamMacro.new()]
var decay_macros:Array=[ParamMacro.new(),ParamMacro.new(),ParamMacro.new(),ParamMacro.new()]
var sus_level_macros:Array=[ParamMacro.new(),ParamMacro.new(),ParamMacro.new(),ParamMacro.new()]
var sus_rate_macros:Array=[ParamMacro.new(),ParamMacro.new(),ParamMacro.new(),ParamMacro.new()]
var release_macros:Array=[ParamMacro.new(),ParamMacro.new(),ParamMacro.new(),ParamMacro.new()]

func _init()->void:
	name=TYPE

func duplicate()->Instrument:
	var ni:FmInstrument=.duplicate() as FmInstrument
	ni.op_mask=op_mask
	ni.clip=clip
	ni.attacks=attacks.duplicate()
	ni.decays=decays.duplicate()
	ni.sustains=sustains.duplicate()
	ni.sustain_levels=sustain_levels.duplicate()
	ni.releases=releases.duplicate()
	ni.repeats=repeats.duplicate()
	ni.multipliers=multipliers.duplicate()
	ni.dividers=dividers.duplicate()
	ni.detunes=detunes.duplicate()
	ni.duty_cycles=duty_cycles.duplicate()
	ni.waveforms=waveforms.duplicate()
	ni.am_intensity=am_intensity.duplicate()
	ni.fm_intensity=fm_intensity.duplicate()
	ni.routings=routings.duplicate(true)
	ni.freq_macro=freq_macro.duplicate()
	ni.volume_macro=volume_macro.duplicate()
	ni.pan_macro=pan_macro.duplicate()
	ni.chanl_invert_macro=chanl_invert_macro.duplicate()
	ni.clip_macro=clip_macro.duplicate()
	return ni

func copy(from:Instrument,full:bool=false)->void:
	.copy(from,full)
	if from.get("TYPE")=="FmInstrument":
		op_mask=from.op_mask
		clip=from.clip
		attacks=from.attacks.duplicate()
		decays=from.decays.duplicate()
		sustains=from.sustains.duplicate()
		sustain_levels=from.sustain_levels.duplicate()
		releases=from.releases.duplicate()
		repeats=from.repeats.duplicate()
		multipliers=from.multipliers.duplicate()
		dividers=from.dividers.duplicate()
		detunes=from.detunes.duplicate()
		duty_cycles=from.duty_cycles.duplicate()
		waveforms=from.waveforms.duplicate()
		am_intensity=from.am_intensity.duplicate()
		fm_intensity=from.fm_intensity.duplicate()
		routings=from.routings.duplicate(true)

func delete_waveform(w_ix:int)->void:
	for i in range(4):
		if waveforms[i]>=w_ix:
			waveforms[i]-=1
			if waveforms[i]==WAVE.NOISE:
				waveforms[i]=WAVE.TRIANGLE

func copy_op(from:int,to:int)->void:
	attacks[to]=attacks[from]
	decays[to]=decays[from]
	sustains[to]=sustains[from]
	sustain_levels[to]=sustain_levels[from]
	releases[to]=releases[from]
	key_scalers[to]=key_scalers[from]
	repeats[to]=repeats[from]
	multipliers[to]=multipliers[from]
	dividers[to]=dividers[from]
	detunes[to]=detunes[from]
	duty_cycles[to]=duty_cycles[from]
	waveforms[to]=waveforms[from]
	am_intensity[to]=am_intensity[from]
	am_lfo[to]=am_lfo[from]
	fm_intensity[to]=fm_intensity[from]
	fm_lfo[to]=fm_lfo[from]
	routings[to]=routings[from].duplicate()

#

func serialize(out:ChunkedFile)->void:
	out.start_chunk(CHUNK_ID,CHUNK_VERSION)
	out.store_8(op_mask)
	out.store_8(int(clip))
	for i in range(4):
		out.store_8(attacks[i])
		out.store_8(decays[i])
		out.store_8(sustains[i])
		out.store_8(sustain_levels[i])
		out.store_8(releases[i])
		out.store_8(repeats[i])
		out.store_8(multipliers[i])
		out.store_8(dividers[i])
		out.store_16(detunes[i])
		out.store_8(duty_cycles[i])
		out.store_8(waveforms[i])
		out.store_8(am_intensity[i])
		out.store_8(am_lfo[i])
		out.store_16(fm_intensity[i])
		out.store_8(fm_lfo[i])
		out.store_8(key_scalers[i])
	for r in routings:
		for v in r:
			out.store_8(v)
	out.store_pascal_string(name)
	out.end_chunk()

#

func deserialize(inf:ChunkedFile,ins:FmInstrument,version:int)->void:
	ins.op_mask=inf.get_8()
	if version>0:
		ins.clip=bool(inf.get_8())
	else:
		ins.clip=0
	for i in range(4):
		ins.attacks[i]=inf.get_8()
		ins.decays[i]=inf.get_8()
		ins.sustains[i]=inf.get_8()
		ins.sustain_levels[i]=inf.get_8()
		ins.releases[i]=inf.get_8()
		ins.repeats[i]=inf.get_8()
		ins.multipliers[i]=inf.get_8()
		ins.dividers[i]=inf.get_8()
		ins.detunes[i]=inf.get_signed_16()
		ins.duty_cycles[i]=inf.get_8()
		ins.waveforms[i]=inf.get_8()
		ins.am_intensity[i]=inf.get_8()
		ins.am_lfo[i]=inf.get_8()
		ins.fm_intensity[i]=inf.get_16()
		ins.fm_lfo[i]=inf.get_8()
		ins.key_scalers[i]=inf.get_8()
	for i in range(4):
		for j in range(5):
			routings[i][j]=inf.get_8()
	ins.name=inf.get_pascal_string()
