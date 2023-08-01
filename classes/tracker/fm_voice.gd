extends FmInstrument
class_name FmVoice

const CONSTS=preload("res://classes/tracker/fm_voice_constants.gd")
const TRCK=preload("res://classes/tracker/tracker_constants.gd")
const ATTRS=Pattern.ATTRS

enum {KON_PASS,KON_STD,KON_LEGATO,KON_STACCATO,KON_OFF,KON_STOP}

const LEGATO2KON:Dictionary={
	Pattern.LEGATO_MODE.OFF:KON_STD,
	Pattern.LEGATO_MODE.LEGATO:KON_LEGATO,
	Pattern.LEGATO_MODE.STACCATO:KON_STACCATO
}

# Index by track
var fx_cmds:Array=[0,0,0,0]
var fx_opmasks:Array=[0,0,0,0]
var fx_apply:Array=[false,false,false,false]
# Index by command
var fx_vals:Array

var arpeggio_tick:int=0
var row_tick:int=0
var macro_tick:int=0
var release_tick:int=-1
var freqs:Array=[0,0,0,0]
var base_freqs:Array=[0,0,0,0]
var next_freqs:Array=[0,0,0,0]
var arp_freqs:Array=[0,0,0,0]
var velocity:int=255
var panning:int=0x1F

var instrument_dirty:bool=false
var clip_dirty:bool=true
var key_dirty_any:bool=true
var key_dirty:Array=[KON_PASS,KON_PASS,KON_PASS,KON_PASS]
var freqs_dirty_any:bool=true
var freqs_dirty:Array=[false,false,false,false]
var fms_dirty_any:bool=true
var fms_dirty:Array=[false,false,false,false]
var fml_dirty_any:bool=true
var fml_dirty:Array=[false,false,false,false]
var multiplier_dirty_any:bool=false
var multiplier_dirty:Array=[false,false,false,false]
var divider_dirty_any:bool=false
var divider_dirty:Array=[false,false,false,false]
var detune_dirty_any:bool=false
var detune_dirty:Array=[false,false,false,false]
var velocity_dirty:bool=false
var panning_dirty:bool=false
var attack_dirty:Array=[false,false,false,false]
var attack_dirty_any:bool=false
var decay_dirty:Array=[false,false,false,false]
var decay_dirty_any:bool=false
var suslev_dirty:Array=[false,false,false,false]
var suslev_dirty_any:bool=false
var susrate_dirty:Array=[false,false,false,false]
var susrate_dirty_any:bool=false
var release_dirty:Array=[false,false,false,false]
var release_dirty_any:bool=false
var ksr_dirty:Array=[false,false,false,false]
var ksr_dirty_any:bool=false
var repeat_dirty:Array=[false,false,false,false]
var repeat_dirty_any:bool=false
var ams_dirty_any:bool=true
var ams_dirty:Array=[false,false,false,false]
var aml_dirty_any:bool=true
var aml_dirty:Array=[false,false,false,false]
var pm_level_dirty_any:Array=[false,false,false,false]
var pm_level_dirty:Array=[
		[false,false,false,false],
		[false,false,false,false],
		[false,false,false,false],
		[false,false,false,false]
	]
var output_dirty_any:bool=true
var output_dirty:Array=[false,false,false,false]
var wave_dirty_any:bool=true
var wave_dirty:Array=[false,false,false,false]
var duty_cycle_dirty_any:bool=false
var duty_cycle_dirty:Array=[false,false,false,false]
var phase_dirty_any:bool=false
var phase_dirty:Array=[false,false,false,false]
var phases:Array=[0,0,0,0]
var lfo_wave_dirty_any:bool=true
var lfo_wave_dirty:Array=[false,false,false,false]
var lfo_waves:Array=[0,0,0,0]
var lfo_freq_dirty_any:bool=true
var lfo_freq_dirty:Array=[false,false,false,false]
var lfo_freqs:Array=[0,0,0,0]
var lfo_duty_cycle_dirty_any:bool=false
var lfo_duty_cycle_dirty:Array=[false,false,false,false]
var lfo_duty_cycles:Array=[0,0,0,0]
var lfo_phase_dirty_any:bool=false
var lfo_phase_dirty:Array=[false,false,false,false]
var lfo_phases:Array=[0,0,0,0]


func _init()->void:
	fx_vals.resize(256)
	reset()

func reset()->void:
	# trigger=CONSTS.TRG_KEEP
	fx_cmds=[0,0,0,0]
	fx_opmasks=[0,0,0,0]
	fx_apply=[false,false,false,false]
	for i in range(256):
		if i==CONSTS.FX_FRQ_PORTA:
			fx_vals[i]=[0,0,0,0,0]
		elif i==CONSTS.FX_ARPEGGIO:
			fx_vals[i]=[0,0,0]
		elif i==CONSTS.FX_RPT_ON or i==CONSTS.FX_RPT_RETRIG or i==CONSTS.FX_RPT_PHI0:
			fx_vals[i]=[0,0]
		else:
			fx_vals[i]=0
	arpeggio_tick=0
	row_tick=0
	macro_tick=0
	release_tick=-1
	freqs=[0,0,0,0]
	base_freqs=[0,0,0,0]
	next_freqs=[0,0,0,0]
	arp_freqs=[0,0,0,0]
	velocity=255
	panning=0x1F
	instrument_dirty=false
	clip_dirty=true
	freqs_dirty_any=true
	freqs_dirty=[false,false,false,false]
	key_dirty_any=false
	key_dirty=[KON_PASS,KON_PASS,KON_PASS,KON_PASS]
	fms_dirty_any=true
	fms_dirty=[false,false,false,false]
	fml_dirty_any=true
	fml_dirty=[false,false,false,false]
	multiplier_dirty_any=false
	multiplier_dirty=[false,false,false,false]
	divider_dirty_any=false
	divider_dirty=[false,false,false,false]
	detune_dirty_any=false
	detune_dirty=[false,false,false,false]
	velocity_dirty=false
	panning_dirty=false
	attack_dirty=[false,false,false,false]
	attack_dirty_any=false
	decay_dirty=[false,false,false,false]
	decay_dirty_any=false
	suslev_dirty=[false,false,false,false]
	suslev_dirty_any=false
	susrate_dirty=[false,false,false,false]
	susrate_dirty_any=false
	release_dirty=[false,false,false,false]
	release_dirty_any=false
	ksr_dirty=[false,false,false,false]
	ksr_dirty_any=false
	repeat_dirty=[false,false,false,false]
	repeat_dirty_any=false
	ams_dirty_any=true
	ams_dirty=[false,false,false,false]
	aml_dirty_any=true
	aml_dirty=[false,false,false,false]
	pm_level_dirty_any=[false,false,false,false]
	pm_level_dirty=[
			[false,false,false,false],
			[false,false,false,false],
			[false,false,false,false],
			[false,false,false,false]
		]
	output_dirty_any=true
	output_dirty=[false,false,false,false]
	wave_dirty_any=true
	wave_dirty=[false,false,false,false]
	duty_cycle_dirty_any=false
	duty_cycle_dirty=[false,false,false,false]
	phase_dirty_any=false
	phase_dirty=[false,false,false,false]
	phases=[0,0,0,0]
	lfo_wave_dirty_any=true
	lfo_wave_dirty=[false,false,false,false]
	lfo_waves=[0,0,0,0]
	lfo_freq_dirty_any=true
	lfo_freq_dirty=[false,false,false,false]
	lfo_freqs=[0,0,0,0]
	lfo_duty_cycle_dirty_any=false
	lfo_duty_cycle_dirty=[false,false,false,false]
	lfo_duty_cycles=[0,0,0,0]
	lfo_phase_dirty_any=false
	lfo_phase_dirty=[false,false,false,false]
	lfo_phases=[0,0,0,0]

func process_tick(song:Song,channel:int,curr_order:int,curr_row:int,curr_tick:int)->int:
	var pat:Pattern=song.get_order_pattern(curr_order,channel)
	var note:Array=pat.notes[curr_row]
	var fx_cmd:int
	if curr_tick==0:
		# Reset delay counters
		for i in range(CONSTS.FX_DLY_OFF,CONSTS.FX_DLY_RETRIG+1):
			fx_vals[i]=0
		fx_vals[CONSTS.FX_DELAY]=0
		fx_vals[CONSTS.FX_DELAY_SONG]=0
		row_tick=0
		#
		var j:int=0
		for i in range(song.num_fxs[channel]):
			fx_cmd=get_fx_cmd(note[ATTRS.FX0+j],i)
			if fx_cmd==CONSTS.FX_DELAY or fx_cmd==CONSTS.FX_DELAY_SONG:
				fx_vals[fx_cmd]=get_fx_val(note[ATTRS.FV0+j],note[ATTRS.NOTE],fx_cmd,i)
			j+=3
	var tracker_cmd:int=0
	if fx_vals[CONSTS.FX_DELAY_SONG]!=0:
		if curr_tick==0:
			return fx_vals[CONSTS.FX_DELAY_SONG]|TRCK.SIG_DELAY_SONG
	if fx_vals[CONSTS.FX_DELAY]==0:
		if row_tick==0:
			tracker_cmd=process_tick_0(note,song,song.num_fxs[channel])
		else:
			process_tick_n(song,channel)
		row_tick+=1
		macro_tick+=1
		arpeggio_tick=(arpeggio_tick+1)%3
	else:
		fx_vals[CONSTS.FX_DELAY]-=1
	return tracker_cmd

func process_tick_0(note:Array,song:Song,num_fxs:int)->int:
	var legato:int=KON_STD if note[ATTRS.LG_MODE]==null else LEGATO2KON[note[ATTRS.LG_MODE]]
	if note[ATTRS.NOTE]!=null:
		if legato!=KON_LEGATO:
			macro_tick=0
			release_tick=-1
		if note[ATTRS.NOTE]>=0:
			for i in 4:
				key_dirty[i]=legato if op_mask&(1<<i) else KON_STOP
				key_dirty_any=true
			set_frequency(note[ATTRS.NOTE]*100,15)
		elif note[ATTRS.NOTE]==-1:
			for i in 4:
				key_dirty[i]=KON_OFF
			key_dirty_any=true
			release_tick=macro_tick
		else:
			for i in 4:
				key_dirty[i]=KON_STOP
			key_dirty_any=true
	if note[ATTRS.INSTR]!=null:
		set_instrument(song.get_instrument(note[ATTRS.INSTR]) as FmInstrument)
	set_velocity(note[ATTRS.VOL])
	set_panning(note[ATTRS.PAN])
	var j:int=0
	var fx_cmd:int=0
	var fx_opm
	var fx_val
	arp_freqs[0]=0
	arp_freqs[1]=0
	arp_freqs[2]=0
	arp_freqs[3]=0
	var tracker_cmd:int=0
	for i in range(num_fxs):
		fx_apply[i]=false
		fx_cmd=get_fx_cmd(note[ATTRS.FX0+j],i)
		fx_val=get_fx_val(note[ATTRS.FV0+j],note[ATTRS.NOTE],fx_cmd,i)
		if fx_apply[i]:
			fx_opm=note[ATTRS.FM0+j]
			if fx_opm!=null and fx_opm!=0:
				fx_opmasks[i]=fx_opm
			else:
				fx_opm=fx_opmasks[i]
			if fx_cmd==CONSTS.FX_FRQ_SET:
				set_frequency(fx_val,fx_opm)
			elif fx_cmd==CONSTS.FX_FRQ_ADJ or fx_cmd==CONSTS.FX_FRQ_SLIDE:
				slide_frequency(fx_val,fx_opm)
			elif fx_cmd==CONSTS.FX_FRQ_PORTA:
				slide_frequency_to(fx_val,fx_opm)
			elif fx_cmd==CONSTS.FX_ARPEGGIO:
				freqs_dirty_any=set_opmasked(fx_vals[0x04][arpeggio_tick],\
						arp_freqs,freqs_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_FMS_SET:
				fms_dirty_any=set_opmasked(fx_val,fm_intensity,fms_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_FMS_ADJ or fx_cmd==CONSTS.FX_FMS_SLIDE:
				slide_fms(fx_val,fx_opm)
			elif fx_cmd==CONSTS.FX_FMS_LFO:
				fml_dirty_any=set_opmasked(fx_val,fm_lfo,fml_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_MUL_SET:
				multiplier_dirty_any=set_opmasked(fx_val,multipliers,multiplier_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_DIV_SET:
				divider_dirty_any=set_opmasked(fx_val,dividers,divider_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_DET_SET:
				detune_dirty_any=set_opmasked(fx_val,detunes,detune_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_DET_ADJ or fx_cmd==CONSTS.FX_DET_SLIDE:
				slide_detune(fx_val,fx_opm)
			elif fx_cmd==CONSTS.FX_ATK_SET:
				attack_dirty_any=set_opmasked(fx_val,attacks,attack_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_DEC_SET:
				decay_dirty_any=set_opmasked(fx_val,decays,decay_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_SUL_SET:
				suslev_dirty_any=set_opmasked(fx_val,sustain_levels,suslev_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_SUR_SET:
				susrate_dirty_any=set_opmasked(fx_val,sustains,susrate_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_REL_SET:
				release_dirty_any=set_opmasked(fx_val,releases,release_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_KS_SET:
				ksr_dirty_any=set_opmasked(fx_val,key_scalers,ksr_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_RPM_SET:
				repeat_dirty_any=set_opmasked(fx_val,repeats,repeat_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_AMS_SET:
				ams_dirty_any=set_opmasked(fx_val,am_intensity,ams_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_AMS_LFO:
				aml_dirty_any=set_opmasked(fx_val,am_lfo,aml_dirty,fx_opm)
			elif fx_cmd>=CONSTS.FX_MOD_SET_MIN and fx_cmd<=CONSTS.FX_MOD_SET_MAX:
				set_fm_level(fx_val,fx_cmd&3,fx_opm)
			elif fx_cmd==CONSTS.FX_OUT_SET:
				set_output(fx_val,fx_opm)
			elif fx_cmd==CONSTS.FX_WAVE_SET:
				wave_dirty_any=set_opmasked(fx_val,waveforms,wave_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_DUC_SET:
				duty_cycle_dirty_any=set_opmasked(fx_val,duty_cycles,duty_cycle_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_PHI_SET:
				phase_dirty_any=set_opmasked(fx_val,phases,phase_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_LFO_WAVE_SET:
				lfo_wave_dirty_any=set_opmasked(fx_val,lfo_waves,lfo_wave_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_LFO_DUC_SET:
				lfo_duty_cycle_dirty_any=set_opmasked(fx_val,lfo_duty_cycles,
						lfo_duty_cycle_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_LFO_PHI_SET:
				lfo_phase_dirty_any=set_opmasked(fx_val,lfo_phases,lfo_phase_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_LFO_FREQ_SET:
				lfo_freq_dirty_any=set_lfo_freq(fx_val,fx_opm,0,4)
			elif fx_cmd==CONSTS.FX_LFO_FREQ_SET_HI:
				lfo_freq_dirty_any=set_lfo_freq(fx_val,fx_opm,0xFF,8)
			elif fx_cmd==CONSTS.FX_LFO_FREQ_SET_LO:
				lfo_freq_dirty_any=set_lfo_freq(fx_val,fx_opm,0xFF00,0)
			elif fx_cmd==CONSTS.FX_CLIP_SET:
				clip_dirty=set_clip(fx_val)
			elif fx_cmd==CONSTS.FX_GOTO_ORDER:
				tracker_cmd=fx_val|TRCK.SIG_GOTO_ORDER
			elif fx_cmd==CONSTS.FX_GOTO_NEXT and tracker_cmd==0:
				tracker_cmd=fx_val|TRCK.SIG_GOTO_NEXT
			elif fx_cmd==CONSTS.FX_TICKSROW_SET:
				song.ticks_row=fx_val+1
			elif fx_cmd==CONSTS.FX_TICKSSEC_SET:
				song.ticks_second=fx_val+1
			elif fx_cmd==CONSTS.FX_DEBUG:
				breakpoint
		j+=3
	apply_macros()
	return tracker_cmd

func process_tick_n(song:Song,channel:int)->void:
	var fx_cmd:int
	for i in range(song.num_fxs[channel]):
		if not fx_apply[i]:
			continue
		fx_cmd=fx_cmds[i]
		if fx_cmd==CONSTS.FX_FRQ_SLIDE:
			slide_frequency(fx_vals[CONSTS.FX_FRQ_SLIDE],fx_opmasks[i])
		elif fx_cmd==CONSTS.FX_FRQ_PORTA:
			slide_frequency_to(fx_vals[CONSTS.FX_FRQ_PORTA],fx_opmasks[i])
		elif fx_cmd==CONSTS.FX_ARPEGGIO:
			freqs_dirty_any=set_opmasked(fx_vals[0x04][arpeggio_tick],\
					arp_freqs,freqs_dirty,fx_opmasks[i])
		elif fx_cmd==CONSTS.FX_FMS_SLIDE:
			slide_fms(fx_vals[CONSTS.FX_FMS_SLIDE],fx_opmasks[i])
		elif fx_cmd==CONSTS.FX_DET_SLIDE:
			slide_detune(fx_vals[CONSTS.FX_DET_SLIDE],fx_opmasks[i])
		elif fx_cmd==CONSTS.FX_DLY_OFF or fx_cmd==CONSTS.FX_DLY_CUT\
				or fx_cmd==CONSTS.FX_DLY_ON or fx_cmd==CONSTS.FX_DLY_RETRIG:
			set_delayed_triggers(fx_cmd)
		elif fx_cmd==CONSTS.FX_DLY_PHI0:
			set_delayed_phi_zero(fx_opmasks[i])
		elif fx_cmd==CONSTS.FX_RPT_ON or fx_cmd==CONSTS.FX_RPT_RETRIG:
			set_repeated_triggers(fx_cmd)
		elif fx_cmd==CONSTS.FX_RPT_PHI0:
			set_repeated_phi_zero(fx_opmasks[i])
	apply_macros()

func apply_macros()->void:
	var old:int
	var val:int
	# Global volume
	old=velocity
	velocity=volume_macro.get_value(macro_tick,release_tick,velocity)
	velocity_dirty=velocity_dirty or old!=velocity
	for i in 4:
		# Global+Op tone
		old=freqs[i]
		base_freqs[i]=next_freqs[i]
		freqs[i]=op_freq_macro[i].get_value(macro_tick,release_tick,freq_macro.get_value(macro_tick,release_tick,base_freqs[i]))+arp_freqs[i]
		freqs_dirty[i]=freqs_dirty[i] or old!=freqs[i]
		freqs_dirty_any=freqs_dirty_any or freqs_dirty[i]
		# Global+op key
		val=op_key_macro[i].get_value(macro_tick,release_tick,key_macro.get_value(macro_tick,release_tick,key_dirty[i]))
		key_dirty_any=key_dirty_any or val!=key_dirty[i]
		key_dirty[i]=val


func get_fx_cmd(c,i:int)->int:
	if c!=null:
		fx_cmds[i]=c
		fx_apply[i]=true
	return fx_cmds[i]

func get_fx_val(v,note,cmd:int,cmd_col:int)->int:
	if v==null:
		return fx_vals[cmd]
	if cmd==CONSTS.FX_FRQ_SET:
		fx_vals[cmd]=clamp((v*50)+CONSTS.MIN_FREQ,CONSTS.MIN_FREQ,CONSTS.MAX_FREQ)
	elif cmd==CONSTS.FX_DET_SET:
		fx_vals[cmd]=clamp((v-128)*100,-12000,12000)
	elif cmd==CONSTS.FX_FRQ_ADJ or cmd==CONSTS.FX_FRQ_SLIDE\
			or cmd==CONSTS.FX_FMS_ADJ or cmd==CONSTS.FX_FMS_SLIDE\
			or cmd==CONSTS.FX_DET_ADJ or cmd==CONSTS.FX_DET_SLIDE:
		fx_vals[cmd]=v-128
	elif cmd==CONSTS.FX_FRQ_PORTA:
		fx_vals[cmd][0]=v
		if note!=null:
			note*=100
			fx_vals[cmd][1]=note
			fx_vals[cmd][2]=note
			fx_vals[cmd][3]=note
			fx_vals[cmd][4]=note
	elif cmd==CONSTS.FX_ARPEGGIO:
		fx_vals[cmd][1]=clamp((v>>4)*100,CONSTS.MIN_FREQ,CONSTS.MAX_FREQ)
		fx_vals[cmd][2]=clamp((v&15)*100,CONSTS.MIN_FREQ,CONSTS.MAX_FREQ)
	elif cmd==CONSTS.FX_FMS_SET:
		fx_vals[cmd]=clamp(v*50,0,12000)
	elif cmd==CONSTS.FX_FMS_LFO or cmd==CONSTS.FX_AMS_LFO:
		fx_vals[cmd]=clamp(v,0,3)
	elif cmd==CONSTS.FX_MUL_SET:
		fx_vals[cmd]=clamp(v,0,32)
	elif cmd==CONSTS.FX_DIV_SET:
		fx_vals[cmd]=clamp(v,0,31)
	elif cmd==CONSTS.FX_DELAY or cmd==CONSTS.FX_DELAY_SONG:
		fx_apply[cmd_col]=false
		return v
	elif cmd==CONSTS.FX_RPT_ON or cmd==CONSTS.FX_RPT_RETRIG or cmd==CONSTS.FX_RPT_PHI0:
		fx_vals[cmd][0]=0
		fx_vals[cmd][1]=v
	elif cmd==CONSTS.FX_KS_SET:
		fx_vals[cmd]=clamp(v,0,7)
	elif cmd==CONSTS.FX_RPM_SET:
		fx_vals[cmd]=clamp(v,0,4)
	else:
		fx_vals[cmd]=v
	fx_apply[cmd_col]=true
	return fx_vals[cmd]

#

func commit(channel:int,cmds:Array,ptr:int)->int:
	if instrument_dirty:
		ptr=commit_instrument(channel,cmds,ptr)
	if key_dirty_any:
		ptr=commit_retrigger(channel,cmds,ptr)
	if clip_dirty:
		ptr=commit_clip(channel,cmds,ptr)
	if freqs_dirty_any:
		ptr=commit_opmasked_long(channel,cmds,ptr,CONSTS.CMD_FREQ,freqs_dirty,freqs)
		freqs_dirty_any=false
	if velocity_dirty:
		ptr=commit_velocity(channel,cmds,ptr)
	if panning_dirty:
		ptr=commit_panning(channel,cmds,ptr)
	if fms_dirty_any:
		ptr=commit_opmasked_long(channel,cmds,ptr,CONSTS.CMD_FMS,fms_dirty,fm_intensity)
		fms_dirty_any=false
	if fml_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_FML,fml_dirty,fm_lfo)
		fml_dirty_any=false
	if multiplier_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_MULT,multiplier_dirty,
				multipliers)
		multiplier_dirty_any=false
	if divider_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_DIV,divider_dirty,dividers)
		divider_dirty_any=false
	if detune_dirty_any:
		ptr=commit_opmasked_long(channel,cmds,ptr,CONSTS.CMD_DET,detune_dirty,detunes)
		detune_dirty_any=false
	if attack_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_AR,attack_dirty,attacks)
		attack_dirty_any=false
	if decay_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_DR,decay_dirty,decays)
		decay_dirty_any=false
	if suslev_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_SL,suslev_dirty,sustain_levels)
		suslev_dirty_any=false
	if susrate_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_SR,susrate_dirty,sustains)
		susrate_dirty_any=false
	if release_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_RR,release_dirty,releases)
		release_dirty_any=false
	if ksr_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_KSR,ksr_dirty,key_scalers)
		ksr_dirty_any=false
	if repeat_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_RM,repeat_dirty,repeats)
		repeat_dirty_any=false
	if ams_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_AMS,ams_dirty,am_intensity)
		ams_dirty_any=false
	if aml_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_AML,aml_dirty,am_lfo)
		aml_dirty_any=false
	for i in range(4):
		if pm_level_dirty_any[i]:
			ptr=commit_pm_level(channel,cmds,ptr,i,pm_level_dirty[i],routings[i])
	if output_dirty_any:
		ptr=commit_output(channel,cmds,ptr)
	if wave_dirty_any:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_WAV,wave_dirty,waveforms)
		wave_dirty_any=false
	if duty_cycle_dirty_any:
		ptr=commit_opmasked_long(channel,cmds,ptr,CONSTS.CMD_DUC,duty_cycle_dirty,
				duty_cycles,16)
		duty_cycle_dirty_any=false
	if phase_dirty_any:
		ptr=commit_opmasked_long(channel,cmds,ptr,CONSTS.CMD_PHI,phase_dirty,phases,16)
		phase_dirty_any=false
	if lfo_wave_dirty_any:
		ptr=commit_lfo_short(cmds,ptr,CONSTS.CMD_LFO_WAVE,lfo_wave_dirty,lfo_waves)
		lfo_wave_dirty_any=false
	if lfo_freq_dirty_any:
		ptr=commit_lfo_long(cmds,ptr,CONSTS.CMD_LFO_FREQ,lfo_freq_dirty,lfo_freqs)
		lfo_freq_dirty_any=false
	if lfo_duty_cycle_dirty_any:
		ptr=commit_lfo_long(cmds,ptr,CONSTS.CMD_LFO_DUC,lfo_duty_cycle_dirty,
				lfo_duty_cycles,16)
		lfo_duty_cycle_dirty_any=false
	if lfo_phase_dirty_any:
		ptr=commit_lfo_long(cmds,ptr,CONSTS.CMD_LFO_PHI,lfo_phase_dirty,lfo_phases,16)
		lfo_phase_dirty_any=false
	return ptr

func commit_lfo_long(cmds:Array,ptr:int,cmd:int,dirties:Array,values:Array,
		shift:int=0)->int:
	for i in range(4):
		if dirties[i]:
			dirties[i]=false
			cmds[ptr]=cmd|(i<<8)
			cmds[ptr+1]=values[i]<<shift
			ptr+=2
	return ptr

func commit_lfo_short(cmds:Array,ptr:int,cmd:int,dirties:Array,values:Array)->int:
	for i in range(4):
		if dirties[i]:
			dirties[i]=false
			cmds[ptr]=cmd|(i<<8)|(values[i]<<16)
			ptr+=1
	return ptr

func commit_output(channel:int,cmds:Array,ptr:int)->int:
	for i in range(4):
		if output_dirty[i]:
			output_dirty[i]=false
			cmds[ptr]=CONSTS.CMD_OUT|(channel<<8)|(0x10000<<i)|(routings[i][4]<<24)
			ptr+=1
	output_dirty_any=false
	return ptr

func commit_pm_level(channel:int,cmds:Array,ptr:int,from:int,dirties:Array,
		values:Array)->int:
	pm_level_dirty_any[from]=false
	for i in range(4):
		if dirties[i]:
			dirties[i]=false
			cmds[ptr]=CONSTS.CMD_PM|(channel<<8)|(0x10000<<i)|(from<<24)
			cmds[ptr+1]=values[i]
			ptr+=2
	return ptr

func commit_opmasked_short(channel:int,cmds:Array,ptr:int,cmd:int,dirties:Array,
		values:Array)->int:
	for i in range(4):
		if dirties[i]:
			dirties[i]=false
			cmds[ptr]=cmd|(channel<<8)|(0x10000<<i)|(values[i]<<24)
			ptr+=1
	return ptr

func commit_opmasked_long(channel:int,cmds:Array,ptr:int,cmd:int,dirties:Array,
		values:Array,shift:int=0)->int:
	for i in range(4):
		if dirties[i]:
			dirties[i]=false
			cmds[ptr]=cmd|(channel<<8)|(0x10000<<i)
			cmds[ptr+1]=values[i]<<shift
			ptr+=2
	return ptr

func commit_panning(channel:int,cmds:Array,ptr:int)->int:
	cmds[ptr]=CONSTS.CMD_PAN|(channel<<8)|(panning<<16)
	panning_dirty=false
	return ptr+1

func commit_clip(channel:int,cmds:Array,ptr:int)->int:
	cmds[ptr]=CONSTS.CMD_CLIP|(channel<<8)|(int(clip)<<24)
	clip_dirty=false
	return ptr+1

func commit_velocity(channel:int,cmds:Array,ptr:int)->int:
	cmds[ptr]=CONSTS.CMD_VEL|(channel<<8)|(velocity<<16)
	velocity_dirty=false
	return ptr+1

func commit_retrigger(channel:int,cmds:Array,ptr:int)->int:
	# Somewhere commands>32bit are generated
	var optr:int=ptr
	for i in 4:
		if key_dirty[i]==KON_PASS:
			continue
		elif key_dirty[i]==KON_STD:
			cmds[ptr]=CONSTS.CMD_KEYON|(channel<<8)|(op_mask<<16)|(velocity<<24)
		elif key_dirty[i]==KON_LEGATO:
			cmds[ptr]=CONSTS.CMD_KEYON_LEGATO|(channel<<8)|(op_mask<<16)|(velocity<<24)
		elif key_dirty[i]==KON_STACCATO:
			cmds[ptr]=CONSTS.CMD_KEYON_STACCATO|(channel<<8)|(op_mask<<16)|(velocity<<24)
		elif key_dirty[i]==KON_OFF:
			cmds[ptr]=CONSTS.CMD_KEYOFF|(channel<<8)|(0x10000<<i)
		elif key_dirty[i]==KON_STOP:
			cmds[ptr]=CONSTS.CMD_STOP|(channel<<8)|(0x10000<<i)
		ptr+=1
	if optr!=ptr:
		ptr=commit_panning(channel,cmds,ptr)
	key_dirty_any=false
	for i in 4:
		key_dirty[i]=KON_PASS
	velocity_dirty=false
	return ptr

func commit_instrument(channel:int,cmds:Array,ptr:int)->int:
	instrument_dirty=false
	clip_dirty=false
	fms_dirty_any=false
	fml_dirty_any=false
	multiplier_dirty_any=false
	divider_dirty_any=false
	attack_dirty_any=false
	decay_dirty_any=false
	suslev_dirty_any=false
	susrate_dirty_any=false
	release_dirty_any=false
	ksr_dirty_any=false
	repeat_dirty_any=false
	ams_dirty_any=false
	aml_dirty_any=false
	output_dirty_any=false
	wave_dirty_any=false
	duty_cycle_dirty_any=false
	cmds[ptr]=CONSTS.CMD_CLIP|(channel<<8)|(int(clip)<<24)
	ptr+=1
	for i in range(4):
		fms_dirty[i]=false
		fml_dirty[i]=false
		multiplier_dirty[i]=false
		divider_dirty[i]=false
		attack_dirty[i]=false
		decay_dirty[i]=false
		suslev_dirty[i]=false
		susrate_dirty[i]=false
		release_dirty[i]=false
		ksr_dirty[i]=false
		repeat_dirty[i]=false
		ams_dirty[i]=false
		aml_dirty[i]=false
		pm_level_dirty_any[i]=false
		output_dirty[i]=false
		wave_dirty[i]=false
		duty_cycle_dirty[i]=false
		var opm:int=1<<i
		var chn_opm:int=(channel<<8)|(opm<<16)
		cmds[ptr]=CONSTS.CMD_AR|chn_opm|(attacks[i]<<24)
		cmds[ptr+1]=CONSTS.CMD_DR|chn_opm|(decays[i]<<24)
		cmds[ptr+2]=CONSTS.CMD_SL|chn_opm|(sustain_levels[i]<<24)
		cmds[ptr+3]=CONSTS.CMD_SR|chn_opm|(sustains[i]<<24)
		cmds[ptr+4]=CONSTS.CMD_RR|chn_opm|(releases[i]<<24)
		cmds[ptr+5]=CONSTS.CMD_RM|chn_opm|(repeats[i]<<24)
		cmds[ptr+6]=CONSTS.CMD_WAV|chn_opm|(waveforms[i]<<24)
		cmds[ptr+7]=CONSTS.CMD_DUC|chn_opm
		cmds[ptr+8]=duty_cycles[i]<<16
		cmds[ptr+9]=CONSTS.CMD_MULT|chn_opm|(multipliers[i]<<24)
		cmds[ptr+10]=CONSTS.CMD_DIV|chn_opm|(dividers[i]<<24)
		cmds[ptr+11]=CONSTS.CMD_DET|chn_opm
		cmds[ptr+12]=detunes[i]
		cmds[ptr+13]=CONSTS.CMD_FMS|chn_opm
		cmds[ptr+14]=fm_intensity[i]
		cmds[ptr+15]=CONSTS.CMD_FML|chn_opm|(fm_lfo[i]<<24)
		cmds[ptr+16]=CONSTS.CMD_AMS|chn_opm|(am_intensity[i]<<24)
		cmds[ptr+17]=CONSTS.CMD_AML|chn_opm|(am_lfo[i]<<24)
		cmds[ptr+18]=CONSTS.CMD_KSR|chn_opm|(key_scalers[i]<<24)
		ptr+=19
		for j in range(4):
			pm_level_dirty[i][j]=false
			cmds[ptr]=CONSTS.CMD_PM|(channel<<8)|(j<<16)|(i<<24)
			cmds[ptr+1]=routings[i][j]
			ptr+=2
		cmds[ptr]=CONSTS.CMD_OUT|chn_opm|(routings[i][4]<<24)
		ptr+=1
	cmds[ptr]=CONSTS.CMD_ENABLE|(channel<<8)|0xFF0000|(op_mask<<24)
	return ptr+1

#

func set_instrument(inst:FmInstrument)->void:
	if inst==null:
		return
	copy(inst)
	instrument_dirty=true

#

func set_clip(value:int)->bool:
	clip=bool(value)
	return true

func set_lfo_freq(value:int,lfo_mask:int,val_mask:int,val_shift:int)->bool:
	if (lfo_mask&15)==0:
		return false
	for i in range(4):
		if lfo_mask&1:
			lfo_freq_dirty[i]=true
			lfo_freqs[i]=(lfo_freqs[i]&val_mask)|(value<<val_shift)
		lfo_mask>>=1
	return true

func set_opmasked(value:int,params:Array,dirties:Array,op:int)->bool:
	if (op&15)==0:
		return false
	for i in range(4):
		if op&1:
			dirties[i]=true
			params[i]=value
		op>>=1
	return true

func set_output(value:int,op:int)->void:
	if (op&15)==0:
		return
	for i in range(4):
		if op&1:
			output_dirty[i]=true
			routings[i][4]=value
		op>>=1
	output_dirty_any=true

func set_fm_level(value:int,from:int,op:int)->void:
	if (op&15)==0:
		return
	for i in range(4):
		if op&1:
			pm_level_dirty[from][i]=true
			routings[from][i]=value
		op>>=1
	pm_level_dirty_any[from]=true

func set_frequency(f,op:int)->void:
	if (op&15)==0:
		return
	f=clamp(f,CONSTS.MIN_FREQ,CONSTS.MAX_FREQ)
	for i in range(4):
		if op&1:
			freqs_dirty[i]=true
			fx_vals[CONSTS.FX_FRQ_PORTA][1+i]=f
			next_freqs[i]=f
		op>>=1
	freqs_dirty_any=true

func slide_frequency(d,op:int)->void:
	if (op&15)==0:
		return
	for i in range(4):
		if op&1:
			freqs_dirty[i]=true
			next_freqs[i]=clamp(next_freqs[i]+d,CONSTS.MIN_FREQ,CONSTS.MAX_FREQ)
			fx_vals[CONSTS.FX_FRQ_PORTA][1+i]=clamp(
					fx_vals[CONSTS.FX_FRQ_PORTA][1+i]+d,CONSTS.MIN_FREQ,CONSTS.MAX_FREQ)
		op>>=1
	freqs_dirty_any=true

func slide_frequency_to(d:Array,op:int)->void:
	if (op&15)==0:
		return
	for i in range(4):
		if op&1:
			freqs_dirty[i]=true
			if freqs[i]>d[i+1]:
				next_freqs[i]=clamp(base_freqs[i]-d[0],d[i+1],CONSTS.MAX_FREQ)
			else:
				next_freqs[i]=clamp(base_freqs[i]+d[0],CONSTS.MIN_FREQ,d[i+1])
		op>>=1
	freqs_dirty_any=true

func slide_fms(d:int,op:int)->void:
	if (op&15)==0:
		return
	for i in range(4):
		if op&1:
			fms_dirty[i]=true
			fm_intensity[i]=clamp(fm_intensity[i]+d,0,12000)
		op>>=1
	fms_dirty_any=true

func slide_detune(d:int,op:int)->void:
	if (op&15)==0:
		return
	for i in range(4):
		if op&1:
			detune_dirty[i]=true
			detunes[i]=clamp(detunes[i]+d,-12000,12000)
		op>>=1
	detune_dirty_any=true

#

func set_velocity(v)->void:
	if v!=null:
		velocity_dirty=true
		velocity=v

#

func set_panning(p)->void:
	if p!=null:
		panning_dirty=true
		panning=p

#

func set_repeated_triggers(fx_cmd:int)->void:
	fx_vals[fx_cmd][0]-=1
	if fx_vals[fx_cmd][0]<=0:
		fx_vals[fx_cmd][0]=fx_vals[fx_cmd][1]
		macro_tick=0
		release_tick=-1
		key_dirty_any=true
		var legato=KON_STD if fx_cmd==CONSTS.FX_RPT_ON else KON_STACCATO
		for i in 4:
			key_dirty[i]=legato if op_mask&(1<<i) else KON_STOP


func set_delayed_triggers(fx_cmd:int)->void:
	fx_vals[fx_cmd]-=1
	if fx_vals[fx_cmd]<=0:
		if fx_cmd==CONSTS.FX_DLY_OFF:
			for i in 4:
				key_dirty[i]=KON_OFF
			release_tick=macro_tick
			key_dirty_any=true
		elif fx_cmd==CONSTS.FX_DLY_CUT:
			for i in 4:
				key_dirty[i]=KON_STOP
			key_dirty_any=true
		elif fx_cmd==CONSTS.FX_DLY_ON:
			macro_tick=0
			release_tick=-1
			for i in 4:
				key_dirty[i]=KON_STD if op_mask&(1<<i) else KON_STOP
			key_dirty_any=true
		elif fx_cmd==CONSTS.FX_DLY_RETRIG:
			macro_tick=0
			release_tick=-1
			for i in 4:
				key_dirty[i]=KON_STACCATO if op_mask&(1<<i) else KON_STOP
			key_dirty_any=true

func set_repeated_phi_zero(op:int)->void:
	fx_vals[CONSTS.FX_RPT_PHI0][0]-=1
	if fx_vals[CONSTS.FX_RPT_PHI0][0]<=0:
		fx_vals[CONSTS.FX_RPT_PHI0][0]=fx_vals[CONSTS.FX_RPT_PHI0][1]
	if (op&15)==0:
		return
	for i in range(4):
		if op&1:
			phase_dirty[i]=true
			phases[i]=0
		op>>=1
	phase_dirty_any=true

func set_delayed_phi_zero(op:int)->void:
	fx_vals[CONSTS.FX_DLY_PHI0]-=1
	if fx_vals[CONSTS.FX_DLY_PHI0]>0 or (op&15)==0:
		return
	for i in range(4):
		if op&1:
			phase_dirty[i]=true
			phases[i]=0
		op>>=1
	phase_dirty_any=true
