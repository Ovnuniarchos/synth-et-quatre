extends Instrument
class_name FmInstrument

enum WAVE{RECTANGLE,SAW,TRIANGLE,NOISE,CUSTOM}
enum REPEAT{OFF,RELEASE,SUSTAIN,DECAY,ATTACK}
enum {DETMODE_NORMAL,DETMODE_FIXED,DETMODE_DELTA}
const TYPE:String="FmInstrument"
const MLIMITS:Dictionary=MacroIO.MACRO_LIMITS


var op_mask:int=1
var clip:bool=false
var attacks:Array=[255,255,255,255]
var decays:Array=[255,255,255,255]
var sustains:Array=[0,0,0,0]
var sustain_levels:Array=[255,255,255,255]
var releases:Array=[255,255,255,255]
var key_scalers:Array=[0,0,0,0]
var repeats:Array=[REPEAT.OFF,REPEAT.OFF,REPEAT.OFF,REPEAT.OFF]
var multipliers:Array=[1,1,1,1]
var dividers:Array=[1,1,1,1]
var detunes:Array=[0,0,0,0]
var detune_modes:Array=[DETMODE_NORMAL,DETMODE_NORMAL,DETMODE_NORMAL,DETMODE_NORMAL]
var duty_cycles:Array=[0,0,0,0]
var waveforms:Array=[WAVE.TRIANGLE,WAVE.TRIANGLE,WAVE.TRIANGLE,WAVE.TRIANGLE]
var am_intensity:Array=[0,0,0,0]
var am_lfo:Array=[0,0,0,0]
var fm_intensity:Array=[0,0,0,0]
var fm_lfo:Array=[0,0,0,0]
var routings:Array=[
	[0,0,0,0,255],
	[0,0,0,0,255],
	[0,0,0,0,255],
	[0,0,0,0,255]
]
var freq_macro:ParamMacro=ParamMacro.new(MLIMITS[MacroIO.MACRO_TONE])
var op_freq_macro:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_TONE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_TONE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_TONE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_TONE])]
var volume_macro:ParamMacro=ParamMacro.new(MLIMITS[MacroIO.MACRO_VOLUME])
var pan_macro:ParamMacro=ParamMacro.new(MLIMITS[MacroIO.MACRO_PAN])
var key_macro:ParamMacro=ParamMacro.new(MLIMITS[MacroIO.MACRO_KEY_ON],ParamMacro.PMM_ABSOLUTE)
var op_key_macro:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_KEY_ON],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_KEY_ON],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_KEY_ON],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_KEY_ON],ParamMacro.PMM_ABSOLUTE)]
var op_enable_macro:ParamMacro=ParamMacro.new(MLIMITS[MacroIO.MACRO_OP_ENABLE],ParamMacro.PMM_MASK)
var chanl_invert_macro:ParamMacro=ParamMacro.new(MLIMITS[MacroIO.MACRO_CHANNEL_INVERT],ParamMacro.PMM_MASK)
var clip_macro:ParamMacro=ParamMacro.new(MLIMITS[MacroIO.MACRO_CLIP],ParamMacro.PMM_MASK)
var duty_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_DUTY_CYCLE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DUTY_CYCLE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DUTY_CYCLE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DUTY_CYCLE])]
var wave_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_WAVE],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_WAVE],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_WAVE],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_WAVE],ParamMacro.PMM_ABSOLUTE)]
var attack_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_ATTACK]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_ATTACK]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_ATTACK]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_ATTACK])]
var decay_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_DECAY]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DECAY]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DECAY]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DECAY])]
var sus_level_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_SUSTAIN_LEVEL]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_SUSTAIN_LEVEL]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_SUSTAIN_LEVEL]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_SUSTAIN_LEVEL])]
var sus_rate_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_SUSTAIN_RATE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_SUSTAIN_RATE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_SUSTAIN_RATE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_SUSTAIN_RATE])]
var release_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_RELEASE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_RELEASE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_RELEASE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_RELEASE])]
var repeat_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_REPEAT],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_REPEAT],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_REPEAT],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_REPEAT],ParamMacro.PMM_ABSOLUTE)]
var ami_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_AM_INTENSITY]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_AM_INTENSITY]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_AM_INTENSITY]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_AM_INTENSITY])]
var ksr_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_KEY_SCALING]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_KEY_SCALING]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_KEY_SCALING]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_KEY_SCALING])]
var multiplier_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_MULTIPLIER]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_MULTIPLIER]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_MULTIPLIER]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_MULTIPLIER])]
var divider_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_DIVIDER]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DIVIDER]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DIVIDER]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DIVIDER])]
var detune_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_DETUNE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DETUNE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DETUNE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DETUNE])]
var detune_mode_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_DETUNE_MODE],false),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DETUNE_MODE],false),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DETUNE_MODE],false),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_DETUNE_MODE],false)]
var fmi_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_FM_INTENSITY]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_FM_INTENSITY]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_FM_INTENSITY]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_FM_INTENSITY])]
var am_lfo_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_AM_LFO],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_AM_LFO],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_AM_LFO],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_AM_LFO],ParamMacro.PMM_ABSOLUTE)]
var fm_lfo_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_FM_LFO],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_FM_LFO],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_FM_LFO],ParamMacro.PMM_ABSOLUTE),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_FM_LFO],ParamMacro.PMM_ABSOLUTE)]
var phase_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_PHASE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_PHASE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_PHASE]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_PHASE])]
var op_macros:Array=[
	[ParamMacro.new(MLIMITS[MacroIO.MACRO_OP1]),
		ParamMacro.new(MLIMITS[MacroIO.MACRO_OP1]),
		ParamMacro.new(MLIMITS[MacroIO.MACRO_OP1]),
		ParamMacro.new(MLIMITS[MacroIO.MACRO_OP1])],
	[ParamMacro.new(MLIMITS[MacroIO.MACRO_OP2]),
		ParamMacro.new(MLIMITS[MacroIO.MACRO_OP2]),
		ParamMacro.new(MLIMITS[MacroIO.MACRO_OP2]),
		ParamMacro.new(MLIMITS[MacroIO.MACRO_OP2])],
	[ParamMacro.new(MLIMITS[MacroIO.MACRO_OP3]),
		ParamMacro.new(MLIMITS[MacroIO.MACRO_OP3]),
		ParamMacro.new(MLIMITS[MacroIO.MACRO_OP3]),
		ParamMacro.new(MLIMITS[MacroIO.MACRO_OP3])],
	[ParamMacro.new(MLIMITS[MacroIO.MACRO_OP4]),
		ParamMacro.new(MLIMITS[MacroIO.MACRO_OP4]),
		ParamMacro.new(MLIMITS[MacroIO.MACRO_OP4]),
		ParamMacro.new(MLIMITS[MacroIO.MACRO_OP4])]
]
var out_macros:Array=[ParamMacro.new(MLIMITS[MacroIO.MACRO_OUTPUT]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_OUTPUT]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_OUTPUT]),
	ParamMacro.new(MLIMITS[MacroIO.MACRO_OUTPUT])]

func _init()->void:
	name=tr("DEFN_FM_INSTRUMENT")

func duplicate_op_macros(macros:Array)->Array:
	var nm:Array=macros.duplicate(true)
	for i in nm.size():
		nm[i]=nm[i].duplicate()
	return nm

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
	ni.detune_modes=detune_modes.duplicate()
	ni.duty_cycles=duty_cycles.duplicate()
	ni.waveforms=waveforms.duplicate()
	ni.am_intensity=am_intensity.duplicate()
	ni.fm_intensity=fm_intensity.duplicate()
	ni.routings=routings.duplicate(true)
	ni.freq_macro=freq_macro.duplicate()
	ni.op_freq_macro=duplicate_op_macros(op_freq_macro)
	ni.volume_macro=volume_macro.duplicate()
	ni.pan_macro=pan_macro.duplicate()
	ni.key_macro=key_macro.duplicate()
	ni.op_key_macro=duplicate_op_macros(op_key_macro)
	ni.op_enable_macro=op_enable_macro.duplicate()
	ni.chanl_invert_macro=chanl_invert_macro.duplicate()
	ni.clip_macro=clip_macro.duplicate()
	ni.duty_macros=duplicate_op_macros(duty_macros)
	ni.wave_macros=duplicate_op_macros(wave_macros)
	ni.attack_macros=duplicate_op_macros(attack_macros)
	ni.decay_macros=duplicate_op_macros(decay_macros)
	ni.sus_level_macros=duplicate_op_macros(sus_level_macros)
	ni.sus_rate_macros=duplicate_op_macros(sus_rate_macros)
	ni.release_macros=duplicate_op_macros(release_macros)
	ni.repeat_macros=duplicate_op_macros(repeat_macros)
	ni.ami_macros=duplicate_op_macros(ami_macros)
	ni.ksr_macros=duplicate_op_macros(ksr_macros)
	ni.multiplier_macros=duplicate_op_macros(multiplier_macros)
	ni.divider_macros=duplicate_op_macros(divider_macros)
	ni.detune_macros=duplicate_op_macros(detune_macros)
	ni.detune_mode_macros=duplicate_op_macros(detune_mode_macros)
	ni.fmi_macros=duplicate_op_macros(fmi_macros)
	ni.am_lfo_macros=duplicate_op_macros(am_lfo_macros)
	ni.fm_lfo_macros=duplicate_op_macros(fm_lfo_macros)
	ni.phase_macros=duplicate_op_macros(phase_macros)
	ni.op_macros=[null,null,null,null]
	for i in 4:
		ni.op_macros[i]=duplicate_op_macros(op_macros[i])
	return ni

func copy(from:Instrument,full:bool=false)->void:
	if from.get("TYPE")=="FmInstrument":
		.copy(from,full)
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
		detune_modes=from.detune_modes.duplicate()
		duty_cycles=from.duty_cycles.duplicate()
		waveforms=from.waveforms.duplicate()
		am_intensity=from.am_intensity.duplicate()
		fm_intensity=from.fm_intensity.duplicate()
		routings=from.routings.duplicate(true)
		freq_macro=from.freq_macro.duplicate()
		op_freq_macro=duplicate_op_macros(from.op_freq_macro)
		volume_macro=from.volume_macro.duplicate()
		pan_macro=from.pan_macro.duplicate()
		key_macro=from.key_macro.duplicate()
		op_key_macro=duplicate_op_macros(from.op_key_macro)
		op_enable_macro=from.op_enable_macro.duplicate()
		chanl_invert_macro=from.chanl_invert_macro.duplicate()
		clip_macro=from.clip_macro.duplicate()
		duty_macros=duplicate_op_macros(from.duty_macros)
		wave_macros=duplicate_op_macros(from.wave_macros)
		attack_macros=duplicate_op_macros(from.attack_macros)
		decay_macros=duplicate_op_macros(from.decay_macros)
		sus_level_macros=duplicate_op_macros(from.sus_level_macros)
		sus_rate_macros=duplicate_op_macros(from.sus_rate_macros)
		release_macros=duplicate_op_macros(from.release_macros)
		repeat_macros=duplicate_op_macros(from.repeat_macros)
		ami_macros=duplicate_op_macros(from.ami_macros)
		ksr_macros=duplicate_op_macros(from.ksr_macros)
		multiplier_macros=duplicate_op_macros(from.multiplier_macros)
		divider_macros=duplicate_op_macros(from.divider_macros)
		detune_macros=duplicate_op_macros(from.detune_macros)
		detune_mode_macros=duplicate_op_macros(from.detune_mode_macros)
		fmi_macros=duplicate_op_macros(from.fmi_macros)
		am_lfo_macros=duplicate_op_macros(from.am_lfo_macros)
		fm_lfo_macros=duplicate_op_macros(from.fm_lfo_macros)
		phase_macros=duplicate_op_macros(from.phase_macros)
		op_macros=[null,null,null,null]
		for i in 4:
			op_macros[i]=duplicate_op_macros(from.op_macros[i])
		out_macros=duplicate_op_macros(from.out_macros)

func delete_waveform(w_ix:int)->void:
	for i in 4:
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
	detune_modes[to]=detune_modes[from]
	duty_cycles[to]=duty_cycles[from]
	waveforms[to]=waveforms[from]
	am_intensity[to]=am_intensity[from]
	am_lfo[to]=am_lfo[from]
	fm_intensity[to]=fm_intensity[from]
	fm_lfo[to]=fm_lfo[from]
	routings[to]=routings[from].duplicate()

func macros_as_dict()->Dictionary:
	return {
		MacroIO.MACRO_TONE:freq_macro,
		"$"+MacroIO.MACRO_TONE:op_freq_macro,
		MacroIO.MACRO_VOLUME:volume_macro,
		MacroIO.MACRO_PAN:pan_macro,
		MacroIO.MACRO_KEY_ON:key_macro,
		"$"+MacroIO.MACRO_KEY_ON:op_key_macro,
		MacroIO.MACRO_OP_ENABLE:op_enable_macro,
		MacroIO.MACRO_CHANNEL_INVERT:chanl_invert_macro,
		MacroIO.MACRO_CLIP:clip_macro,
		MacroIO.MACRO_DUTY_CYCLE:duty_macros,
		MacroIO.MACRO_WAVE:wave_macros,
		MacroIO.MACRO_ATTACK:attack_macros,
		MacroIO.MACRO_DECAY:decay_macros,
		MacroIO.MACRO_SUSTAIN_LEVEL:sus_level_macros,
		MacroIO.MACRO_SUSTAIN_RATE:sus_rate_macros,
		MacroIO.MACRO_RELEASE:release_macros,
		MacroIO.MACRO_REPEAT:repeat_macros,
		MacroIO.MACRO_AM_INTENSITY:ami_macros,
		MacroIO.MACRO_KEY_SCALING:ksr_macros,
		MacroIO.MACRO_MULTIPLIER:multiplier_macros,
		MacroIO.MACRO_DIVIDER:divider_macros,
		MacroIO.MACRO_DETUNE:detune_macros,
		MacroIO.MACRO_DETUNE_MODE:detune_mode_macros,
		MacroIO.MACRO_FM_INTENSITY:fmi_macros,
		MacroIO.MACRO_AM_LFO:am_lfo_macros,
		MacroIO.MACRO_FM_LFO:fm_lfo_macros,
		MacroIO.MACRO_PHASE:phase_macros,
		MacroIO.MACRO_OP1:op_macros[0],
		MacroIO.MACRO_OP2:op_macros[1],
		MacroIO.MACRO_OP3:op_macros[2],
		MacroIO.MACRO_OP4:op_macros[3],
		MacroIO.MACRO_OUTPUT:out_macros
	}

func set_macro(id:String,op:int,macro:ParamMacro)->bool:
	if op<-1 or op>3:
		return false
	match id:
		MacroIO.MACRO_TONE:
			if op==-1:
				freq_macro=macro
			else:
				op_freq_macro[op]=macro
		MacroIO.MACRO_VOLUME:
			volume_macro=macro
		MacroIO.MACRO_PAN:
			pan_macro=macro
		MacroIO.MACRO_KEY_ON:
			if op==-1:
				key_macro=macro
			else:
				op_key_macro[op]=macro
		MacroIO.MACRO_OP_ENABLE:
			op_enable_macro=macro
		MacroIO.MACRO_CHANNEL_INVERT:
			chanl_invert_macro=macro
		MacroIO.MACRO_CLIP:
			clip_macro=macro
		MacroIO.MACRO_DUTY_CYCLE:
			duty_macros[op]=macro
		MacroIO.MACRO_WAVE:
			wave_macros[op]=macro
		MacroIO.MACRO_ATTACK:
			attack_macros[op]=macro
		MacroIO.MACRO_DECAY:
			decay_macros[op]=macro
		MacroIO.MACRO_SUSTAIN_LEVEL:
			sus_level_macros[op]=macro
		MacroIO.MACRO_SUSTAIN_RATE:
			sus_rate_macros[op]=macro
		MacroIO.MACRO_RELEASE:
			release_macros[op]=macro
		MacroIO.MACRO_REPEAT:
			repeat_macros[op]=macro
		MacroIO.MACRO_AM_INTENSITY:
			ami_macros[op]=macro
		MacroIO.MACRO_KEY_SCALING:
			ksr_macros[op]=macro
		MacroIO.MACRO_MULTIPLIER:
			multiplier_macros[op]=macro
		MacroIO.MACRO_DIVIDER:
			divider_macros[op]=macro
		MacroIO.MACRO_DETUNE:
			detune_macros[op]=macro
		MacroIO.MACRO_DETUNE_MODE:
			detune_mode_macros[op]=macro
		MacroIO.MACRO_FM_INTENSITY:
			fmi_macros[op]=macro
		MacroIO.MACRO_AM_LFO:
			am_lfo_macros[op]=macro
		MacroIO.MACRO_FM_LFO:
			fm_lfo_macros[op]=macro
		MacroIO.MACRO_PHASE:
			phase_macros[op]=macro
		MacroIO.MACRO_OP1:
			op_macros[0][op]=macro
		MacroIO.MACRO_OP2:
			op_macros[1][op]=macro
		MacroIO.MACRO_OP3:
			op_macros[2][op]=macro
		MacroIO.MACRO_OP4:
			op_macros[3][op]=macro
		MacroIO.MACRO_OUTPUT:
			out_macros[op]=macro
		_:
			return false
	return true
