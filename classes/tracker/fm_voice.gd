extends FmInstrument
class_name FmVoice

signal delay_song(delay)
signal goto_order(order)
signal goto_next(row)
signal ticks_sec(ticks)
signal ticks_row(ticks)

const CONSTS=preload("res://classes/tracker/fm_voice_constants.gd")
const TRCK=preload("res://classes/tracker/tracker_constants.gd")
const ATTRS=Pattern.ATTRS
const FAST_ARP_IX:int=0
const FAST_ARP_SPEED:int=1

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

var row_tick:int=0
var macro_tick:int=0
var release_tick:int=-1
var freqs_sent:Array
var base_freqs:Array
var next_freqs:Array
var arpeggio:Arpeggio
var arpeggio_speed:int
var velocity:int
var panning:int
var channel_invert:int

var clip_dirty:bool
var clip_sent=null
var key_dirty:Array=[KON_PASS,KON_PASS,KON_PASS,KON_PASS]
var key_dirty_sent:Array=[KON_PASS,KON_PASS,KON_PASS,KON_PASS]
var enable_mask:int=0
var enable_bits:int=0
var enable_dirty:bool=true
var freqs_dirty:Array=[true,true,true,true]
var fmi_dirty:Array=[true,true,true,true]
var fmi_values:Array=[0,0,0,0]
var fml_dirty:Array=[true,true,true,true]
var fml_values:Array=[0,0,0,0]
var multiplier_dirty:Array=[true,true,true,true]
var multiplier_values:Array=[1,1,1,1]
var divider_dirty:Array=[true,true,true,true]
var divider_values:Array=[1,1,1,1]
var detune_dirty:Array=[true,true,true,true]
var detune_values:Array=[0,0,0,0]
var detune_mode_dirty:Array=[true,true,true,true]
var detune_mode_values:Array=[0,0,0,0]
var velocity_dirty:bool=true
var velocity_sent=null
var panning_dirty:bool=true
var panning_sent:int=0
var channel_invert_sent:int=0
var attack_dirty:Array=[true,true,true,true]
var attack_values:Array=[0,0,0,0]
var decay_dirty:Array=[true,true,true,true]
var decay_values:Array=[0,0,0,0]
var suslev_dirty:Array=[true,true,true,true]
var suslev_values:Array=[0,0,0,0]
var susrate_dirty:Array=[true,true,true,true]
var susrate_values:Array=[0,0,0,0]
var release_dirty:Array=[true,true,true,true]
var release_values:Array=[0,0,0,0]
var ksr_dirty:Array=[true,true,true,true]
var ksr_values:Array=[0,0,0,0]
var repeat_dirty:Array=[true,true,true,true]
var repeat_values:Array=[0,0,0,0]
var ami_dirty:Array=[true,true,true,true]
var ami_values:Array=[0,0,0,0]
var aml_dirty:Array=[true,true,true,true]
var aml_values:Array=[0,0,0,0]
var pm_level_dirty:Array=[
		[true,true,true,true],
		[true,true,true,true],
		[true,true,true,true],
		[true,true,true,true]
	]
var pml_values:Array=[
	[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]
]
var output_dirty:Array=[true,true,true,true]
var out_values:Array=[0,0,0,0]
var wave_dirty:Array=[true,true,true,true]
var wave_values:Array=[0,0,0,0]
var duty_cycle_dirty:Array=[true,true,true,true]
var duty_values:Array=[0,0,0,0]
var phase_dirty:Array=[true,true,true,true]
var phases:Array=[0,0,0,0]
var phases_rel:Array=[true,true,true,true]
var lfo_wave_dirty:Array=[true,true,true,true]
var lfo_waves:Array=[0,0,0,0]
var lfo_freq_dirty:Array=[true,true,true,true]
var lfo_freqs:Array=[0,0,0,0]
var lfo_duty_cycle_dirty:Array=[true,true,true,true]
var lfo_duty_cycles:Array=[0,0,0,0]
var lfo_phase_dirty:Array=[true,true,true,true]
var lfo_phases:Array=[0,0,0,0]

var apply_debug:bool=false


func _init()->void:
	fx_vals.resize(256)
	reset()


func reset()->void:
	fx_cmds=[0,0,0,0]
	fx_opmasks=[0,0,0,0]
	fx_apply=[false,false,false,false]
	for i in 256:
		if i==CONSTS.FX_FRQ_PORTA:
			fx_vals[i]=[0,0,0,0,0]
		elif i==CONSTS.FX_ARPEGGIO:
			fx_vals[i]=[0,3]
		elif i==CONSTS.FX_RPT_ON or i==CONSTS.FX_RPT_RETRIG or i==CONSTS.FX_RPT_PHI0:
			fx_vals[i]=[0,0]
		else:
			fx_vals[i]=0
	row_tick=0
	macro_tick=0
	release_tick=-1
	freqs_sent=[0,0,0,0]
	base_freqs=[0,0,0,0]
	next_freqs=[0,0,0,0]
	arpeggio=null
	arpeggio_speed=3
	velocity=255
	velocity_sent=null
	velocity_dirty=false
	panning=0x1F
	clip_sent=null
	clip_dirty=false
	freqs_dirty=[false,false,false,false]
	key_dirty=[KON_PASS,KON_PASS,KON_PASS,KON_PASS]
	enable_mask=0
	enable_bits=0
	enable_dirty=false
	fmi_dirty=[false,false,false,false]
	fml_dirty=[false,false,false,false]
	multiplier_dirty=[false,false,false,false]
	divider_dirty=[false,false,false,false]
	detune_dirty=[false,false,false,false]
	attack_dirty=[false,false,false,false]
	decay_dirty=[false,false,false,false]
	suslev_dirty=[false,false,false,false]
	susrate_dirty=[false,false,false,false]
	release_dirty=[false,false,false,false]
	ksr_dirty=[false,false,false,false]
	repeat_dirty=[false,false,false,false]
	ami_dirty=[false,false,false,false]
	aml_dirty=[false,false,false,false]
	pm_level_dirty=[
			[false,false,false,false],
			[false,false,false,false],
			[false,false,false,false],
			[false,false,false,false]
		]
	output_dirty=[false,false,false,false]
	wave_dirty=[false,false,false,false]
	duty_cycle_dirty=[false,false,false,false]
	phase_dirty=[false,false,false,false]
	lfo_wave_dirty=[false,false,false,false]
	lfo_freq_dirty=[false,false,false,false]
	lfo_duty_cycle_dirty=[false,false,false,false]
	lfo_phase_dirty=[false,false,false,false]
	apply_debug=false


func process_tick(song:Song,channel:int,curr_order:int,curr_row:int,curr_tick:int)->void:
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
		if curr_row==0:
			fx_cmds=[0,0,0,0]
		#
		var j:int=0
		for i in range(song.num_fxs[channel]):
			fx_cmd=get_fx_cmd(note[ATTRS.FX0+j],i)
			if fx_cmd==CONSTS.FX_DELAY or fx_cmd==CONSTS.FX_DELAY_SONG:
				fx_vals[fx_cmd]=get_fx_val(note[ATTRS.FV0+j],note[ATTRS.NOTE],fx_cmd,i)
			j+=3
	if fx_vals[CONSTS.FX_DELAY_SONG]!=0:
		if curr_tick==0:
			emit_signal("delay_song",fx_vals[CONSTS.FX_DELAY_SONG])
			return
	if fx_vals[CONSTS.FX_DELAY]==0:
		if row_tick==0:
			process_tick_0(note,song,song.num_fxs[channel])
		else:
			process_tick_n(song,channel)
		row_tick+=1
		macro_tick+=1
	else:
		fx_vals[CONSTS.FX_DELAY]-=1


func process_tick_0(note:Array,song:Song,num_fxs:int)->void:
	apply_debug=false
	var legato:int=KON_STD if note[ATTRS.LG_MODE]==null else LEGATO2KON[note[ATTRS.LG_MODE]]
	if note[ATTRS.INSTR]!=null:
		set_instrument(song.get_instrument(note[ATTRS.INSTR]) as FmInstrument)
	if note[ATTRS.NOTE]!=null:
		if legato!=KON_LEGATO:
			macro_tick=0
			release_tick=-1
		if note[ATTRS.NOTE]>=0:
			for i in 4:
				key_dirty[i]=legato if op_mask&(1<<i) else KON_STOP
			set_frequency(note[ATTRS.NOTE]*100,15)
		elif note[ATTRS.NOTE]==-1:
			for i in 4:
				key_dirty[i]=KON_OFF
			release_tick=macro_tick
		else:
			for i in 4:
				key_dirty[i]=KON_STOP
	set_velocity(note[ATTRS.VOL])
	set_panning(note[ATTRS.PAN],note[ATTRS.INVL],note[ATTRS.INVR])
	var j:int=0
	var fx_cmd:int=0
	var fx_opm
	var fx_val
	arpeggio=null
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
				arpeggio=song.get_arp(fx_vals[fx_cmd][FAST_ARP_IX])
				arpeggio_speed=fx_vals[fx_cmd][FAST_ARP_SPEED]
			elif fx_cmd==CONSTS.FX_FMI_SET:
				set_opmasked(fx_val,fm_intensity,fmi_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_FMI_ADJ or fx_cmd==CONSTS.FX_FMI_SLIDE:
				slide_fmi(fx_val,fx_opm)
			elif fx_cmd==CONSTS.FX_FMI_LFO:
				set_opmasked(fx_val,fm_lfo,fml_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_MUL_SET:
				set_opmasked(fx_val,multipliers,multiplier_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_DIV_SET:
				set_opmasked(fx_val,dividers,divider_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_DET_SET:
				set_opmasked(fx_val,detunes,detune_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_DET_ADJ or fx_cmd==CONSTS.FX_DET_SLIDE:
				slide_detune(fx_val,fx_opm)
			elif fx_cmd==CONSTS.FX_ARP_SET:
				arpeggio=song.get_arp(fx_vals[fx_cmd])
			elif fx_cmd==CONSTS.FX_ARP_SPEED:
				arpeggio_speed=fx_val[fx_cmd]
			elif fx_cmd==CONSTS.FX_ATK_SET:
				set_opmasked(fx_val,attacks,attack_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_DEC_SET:
				set_opmasked(fx_val,decays,decay_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_SUL_SET:
				set_opmasked(fx_val,sustain_levels,suslev_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_SUR_SET:
				set_opmasked(fx_val,sustains,susrate_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_REL_SET:
				set_opmasked(fx_val,releases,release_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_KS_SET:
				set_opmasked(fx_val,key_scalers,ksr_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_RPM_SET:
				set_opmasked(fx_val,repeats,repeat_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_AMI_SET:
				set_opmasked(fx_val,am_intensity,ami_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_AMI_ADJ or fx_cmd==CONSTS.FX_AMI_SLIDE:
				slide_ami(fx_val,fx_opm)
			elif fx_cmd==CONSTS.FX_AMI_LFO:
				set_opmasked(fx_val,am_lfo,aml_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_DLY_OFF or fx_cmd==CONSTS.FX_DLY_CUT\
					or fx_cmd==CONSTS.FX_DLY_ON or fx_cmd==CONSTS.FX_DLY_RETRIG:
				set_delayed_triggers(fx_cmd,fx_opmasks[i])
			elif fx_cmd==CONSTS.FX_DLY_PHI0:
				set_delayed_phi_zero(fx_opmasks[i])
			elif fx_cmd==CONSTS.FX_RPT_ON or fx_cmd==CONSTS.FX_RPT_RETRIG:
				set_repeated_triggers(fx_cmd,fx_opmasks[i])
			elif fx_cmd==CONSTS.FX_RPT_PHI0:
				set_repeated_phi_zero(fx_opmasks[i])
			elif fx_cmd>=CONSTS.FX_MOD_SET_MIN and fx_cmd<=CONSTS.FX_MOD_SET_MAX:
				set_fm_level(fx_val,fx_cmd&3,fx_opm)
			elif fx_cmd==CONSTS.FX_OUT_SET:
				set_output(fx_val,fx_opm)
			elif fx_cmd==CONSTS.FX_WAVE_SET:
				set_opmasked(fx_val,waveforms,wave_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_DUC_SET:
				set_opmasked(fx_val,duty_cycles,duty_cycle_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_PHI_SET:
				set_opmasked(fx_val,phases,phase_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_LFO_WAVE_SET:
				set_opmasked(fx_val,lfo_waves,lfo_wave_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_LFO_DUC_SET:
				set_opmasked(fx_val,lfo_duty_cycles,lfo_duty_cycle_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_LFO_PHI_SET:
				set_opmasked(fx_val,lfo_phases,lfo_phase_dirty,fx_opm)
			elif fx_cmd==CONSTS.FX_LFO_FREQ_SET:
				set_lfo_freq(fx_val,fx_opm,0,4)
			elif fx_cmd==CONSTS.FX_LFO_FREQ_SET_HI:
				set_lfo_freq(fx_val,fx_opm,0xFF,8)
			elif fx_cmd==CONSTS.FX_LFO_FREQ_SET_LO:
				set_lfo_freq(fx_val,fx_opm,0xFF00,0)
			elif fx_cmd==CONSTS.FX_CLIP_SET:
				clip_dirty=set_clip(fx_val)
			elif fx_cmd==CONSTS.FX_GOTO_ORDER:
				emit_signal("goto_order",fx_val)
			elif fx_cmd==CONSTS.FX_GOTO_NEXT:
				emit_signal("goto_next",fx_val)
			elif fx_cmd==CONSTS.FX_TICKSROW_SET:
				emit_signal("ticks_row",fx_val+1)
			elif fx_cmd==CONSTS.FX_TICKSSEC_SET:
				emit_signal("ticks_sec",fx_val+1)
			elif fx_cmd==CONSTS.FX_DEBUG:
				apply_debug=true
		j+=3
	apply_macros()


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
		elif fx_cmd==CONSTS.FX_FMI_SLIDE:
			slide_fmi(fx_vals[CONSTS.FX_FMI_SLIDE],fx_opmasks[i])
		elif fx_cmd==CONSTS.FX_AMI_SLIDE:
			slide_ami(fx_vals[CONSTS.FX_AMI_SLIDE],fx_opmasks[i])
		elif fx_cmd==CONSTS.FX_DET_SLIDE:
			slide_detune(fx_vals[CONSTS.FX_DET_SLIDE],fx_opmasks[i])
		elif fx_cmd==CONSTS.FX_DLY_OFF or fx_cmd==CONSTS.FX_DLY_CUT\
				or fx_cmd==CONSTS.FX_DLY_ON or fx_cmd==CONSTS.FX_DLY_RETRIG:
			set_delayed_triggers(fx_cmd,fx_opmasks[i])
		elif fx_cmd==CONSTS.FX_DLY_PHI0:
			set_delayed_phi_zero(fx_opmasks[i])
		elif fx_cmd==CONSTS.FX_RPT_ON or fx_cmd==CONSTS.FX_RPT_RETRIG:
			set_repeated_triggers(fx_cmd,fx_opmasks[i])
		elif fx_cmd==CONSTS.FX_RPT_PHI0:
			set_repeated_phi_zero(fx_opmasks[i])
	apply_macros()


func apply_macros()->void:
	var old
	var old2
	var val:int
	# Global volume
	old=velocity_sent
	velocity_sent=volume_macro.get_value(macro_tick,release_tick,velocity)
	velocity_dirty=velocity_dirty or old!=velocity_sent
	# Global Op Enable
	old2=enable_mask
	old=enable_bits
	val=op_enable_macro.get_value(macro_tick,release_tick,op_mask|0xF0000)
	enable_mask=val>>ParamMacro.MASK_PASSTHROUGH_SHIFT
	enable_bits=val&ParamMacro.MASK_VALUE_MASK
	enable_dirty=enable_dirty or ((old!=enable_bits or old2!=enable_mask) and enable_mask!=0)
	# Global Panpot
	old=panning_sent
	old2=channel_invert_sent
	panning_sent=pan_macro.get_value(macro_tick,release_tick,panning)
	channel_invert_sent=chanl_invert_macro.get_value(macro_tick,release_tick,channel_invert)
	panning_dirty=panning_dirty or old!=panning_sent or old2!=channel_invert_sent
	# Global Clip
	old=clip_sent
	val=clip_macro.get_value(macro_tick,release_tick,int(clip))
	clip_sent=bool(val&ParamMacro.MASK_VALUE_MASK)
	clip_dirty=clip_dirty or (old!=clip_sent and (val>>ParamMacro.MASK_PASSTHROUGH_SHIFT)!=0)
	# Ops
	for i in 4:
		# Global+Op tone
		old=freqs_sent[i]
		base_freqs[i]=next_freqs[i]
		val=freq_macro.get_value(macro_tick,release_tick,base_freqs[i])
		freqs_sent[i]=op_freq_macro[i].get_value(macro_tick,release_tick,val)
		if arpeggio!=null:
			freqs_sent[i]=arpeggio.get_value(macro_tick,release_tick,freqs_sent[i],arpeggio_speed)
		freqs_dirty[i]=freqs_dirty[i] or old!=freqs_sent[i]
		# Global+op key
		old=key_dirty_sent[i]
		val=key_macro.get_value(macro_tick,release_tick,key_dirty[i])
		key_dirty_sent[i]=op_key_macro[i].get_value(macro_tick,release_tick,val)
		# Op Phase
		val=phase_macros[i].get_value(macro_tick,release_tick,ParamMacro.PASSTHROUGH)
		if val!=ParamMacro.PASSTHROUGH:
			phase_dirty[i]=true
			phases[i]=val
			phases_rel[i]=phase_macros[i].relative
		# Op routings
		apply_op_macro(op_macros[i],routings[i],pml_values[i],pm_level_dirty[i])
	# Op Duty Cycle
	apply_op_macro(duty_macros,duty_cycles,duty_values,duty_cycle_dirty)
	# Op Wave
	apply_op_macro(wave_macros,waveforms,wave_values,wave_dirty)
	# Op Attack
	apply_op_macro(attack_macros,attacks,attack_values,attack_dirty)
	# Op Decay
	apply_op_macro(decay_macros,decays,decay_values,decay_dirty)
	# Op SusLevel
	apply_op_macro(sus_level_macros,sustain_levels,suslev_values,suslev_dirty)
	# Op SusRate
	apply_op_macro(sus_rate_macros,sustains,susrate_values,susrate_dirty)
	# Op Release
	apply_op_macro(release_macros,releases,release_values,release_dirty)
	# Op Repeat
	apply_op_macro(repeat_macros,repeats,repeat_values,repeat_dirty)
	# Op AMI
	apply_op_macro(ami_macros,am_intensity,ami_values,ami_dirty)
	# Op KSR
	apply_op_macro(ksr_macros,key_scalers,ksr_values,ksr_dirty)
	# Op Multiplier
	apply_op_macro(multiplier_macros,multipliers,multiplier_values,multiplier_dirty)
	# Op Divider
	apply_op_macro(divider_macros,dividers,divider_values,divider_dirty)
	# Op Detune
	apply_op_macro(detune_macros,detunes,detune_values,detune_dirty)
	# Op Detune
	apply_op_macro(detune_mode_macros,detune_modes,detune_mode_values,detune_mode_dirty)
	# Op FMI
	apply_op_macro(fmi_macros,fm_intensity,fmi_values,fmi_dirty)
	# Op AM LFO
	apply_op_macro(am_lfo_macros,am_lfo,aml_values,aml_dirty)
	# Op FM LFO
	apply_op_macro(fm_lfo_macros,fm_lfo,fml_values,fml_dirty)
	# Op output
	apply_op_macro(out_macros,[
		routings[0][4],routings[1][4],routings[2][4],routings[3][4]
	],out_values,output_dirty)


func apply_op_macro(macros:Array,values:Array,out:Array,dirty:Array)->void:
	var old:int
	var old2:int
	for op in 4:
		old=values[op]
		old2=out[op]
		out[op]=macros[op].get_value(macro_tick,release_tick,values[op])
		dirty[op]=dirty[op] or old!=out[op] or old2!=out[op]


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
			or cmd==CONSTS.FX_FMI_ADJ or cmd==CONSTS.FX_FMI_SLIDE\
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
		fx_vals[cmd][FAST_ARP_IX]=v&15
		fx_vals[cmd][FAST_ARP_SPEED]=((v>>4)&15)+1
	elif cmd==CONSTS.FX_ARP_SPEED:
		fx_vals[cmd]=v+1
	elif cmd==CONSTS.FX_FMI_SET:
		fx_vals[cmd]=clamp(v*50,0,12000)
	elif cmd==CONSTS.FX_FMI_LFO or cmd==CONSTS.FX_AMI_LFO:
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
	if fx_vals[CONSTS.FX_DELAY]>0:
		return ptr
	if not (KON_PASS in key_dirty_sent):
		ptr=commit_retrigger(channel,cmds,ptr)
	if enable_dirty:
		ptr=commit_enable(channel,cmds,ptr,enable_mask,enable_bits)
	if clip_dirty:
		ptr=commit_clip(channel,cmds,ptr)
	if true in freqs_dirty:
		ptr=commit_opmasked_long(channel,cmds,ptr,CONSTS.CMD_FREQ,freqs_dirty,freqs_sent)
	if velocity_dirty:
		ptr=commit_velocity(channel,cmds,ptr)
	if panning_dirty:
		ptr=commit_panning(channel,cmds,ptr)
	if true in fmi_dirty:
		ptr=commit_opmasked_long(channel,cmds,ptr,CONSTS.CMD_FMS,fmi_dirty,fmi_values)
	if true in fml_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_FML,fml_dirty,fml_values)
	if true in multiplier_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_MULT,multiplier_dirty,
				multiplier_values)
	if true in divider_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_DIV,divider_dirty,divider_values)
	if true in detune_mode_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_DETMODE,detune_mode_dirty,detune_mode_values)
	if true in detune_dirty:
		ptr=commit_opmasked_long(channel,cmds,ptr,CONSTS.CMD_DET,detune_dirty,detune_values)
	if true in attack_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_AR,attack_dirty,attack_values)
	if true in decay_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_DR,decay_dirty,decay_values)
	if true in suslev_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_SL,suslev_dirty,suslev_values)
	if true in susrate_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_SR,susrate_dirty,susrate_values)
	if true in release_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_RR,release_dirty,release_values)
	if true in ksr_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_KSR,ksr_dirty,ksr_values)
	if true in repeat_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_RM,repeat_dirty,repeat_values)
	if true in ami_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_AMS,ami_dirty,ami_values)
	if true in aml_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_AML,aml_dirty,aml_values)
	for i in 4:
		if true in pm_level_dirty[i]:
			ptr=commit_pm_level(channel,cmds,ptr,i,pm_level_dirty[i],pml_values[i])
	if true in output_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_OUT,output_dirty,out_values)
	if true in wave_dirty:
		ptr=commit_opmasked_short(channel,cmds,ptr,CONSTS.CMD_WAV,wave_dirty,wave_values)
	if true in duty_cycle_dirty:
		ptr=commit_opmasked_long(channel,cmds,ptr,CONSTS.CMD_DUC,duty_cycle_dirty,
				duty_values,16)
	if true in phase_dirty:
		ptr=commit_opmasked_long(channel,cmds,ptr,CONSTS.CMD_PHI,phase_dirty,phases,16)
	if true in lfo_wave_dirty:
		ptr=commit_lfo_short(cmds,ptr,CONSTS.CMD_LFO_WAVE,lfo_wave_dirty,lfo_waves)
	if true in lfo_freq_dirty:
		ptr=commit_lfo_long(cmds,ptr,CONSTS.CMD_LFO_FREQ,lfo_freq_dirty,lfo_freqs)
	if true in lfo_duty_cycle_dirty:
		ptr=commit_lfo_long(cmds,ptr,CONSTS.CMD_LFO_DUC,lfo_duty_cycle_dirty,
				lfo_duty_cycles,16)
	if true in lfo_phase_dirty:
		ptr=commit_lfo_long(cmds,ptr,CONSTS.CMD_LFO_PHI,lfo_phase_dirty,lfo_phases,16)
	if apply_debug:
		cmds[ptr]=CONSTS.CMD_DEBUG
		ptr+=1
	return ptr


func commit_phase(channel:int,cmds:Array,ptr:int,dirties:Array,values:Array,
	relatives:Array)->int:
	var cmd:int
	for i in 4:
		if dirties[i]:
			dirties[i]=false
			cmd=CONSTS.CMD_DPHI if relatives[i] else CONSTS.CMD_PHI
			cmds[ptr]=cmd|(channel<<8)|(0x10000<<i)
			cmds[ptr+1]=values[i]<<16
			ptr+=2
	return ptr


func commit_lfo_long(cmds:Array,ptr:int,cmd:int,dirties:Array,values:Array,
		shift:int=0)->int:
	for i in 4:
		if dirties[i]:
			dirties[i]=false
			cmds[ptr]=cmd|(i<<8)
			cmds[ptr+1]=values[i]<<shift
			ptr+=2
	return ptr


func commit_lfo_short(cmds:Array,ptr:int,cmd:int,dirties:Array,values:Array)->int:
	for i in 4:
		if dirties[i]:
			dirties[i]=false
			cmds[ptr]=cmd|(i<<8)|(values[i]<<16)
			ptr+=1
	return ptr


func commit_pm_level(channel:int,cmds:Array,ptr:int,from:int,dirties:Array,
		values:Array)->int:
	for i in 4:
		if dirties[i]:
			dirties[i]=false
			cmds[ptr]=CONSTS.CMD_PM|(channel<<8)|(i<<16)|(from<<24)
			cmds[ptr+1]=values[i]
			ptr+=2
	return ptr


func commit_opmasked_short(channel:int,cmds:Array,ptr:int,cmd:int,dirties:Array,
		values:Array)->int:
	var opm:int
	var val:int
	for i in 4:
		opm=0
		val=values[i]
		for j in range(i,4):
			if dirties[j] and values[j]==val:
				dirties[j]=false
				opm|=0x10000<<j
		if opm!=0:
			cmds[ptr]=cmd|(channel<<8)|opm|(val<<24)
			ptr+=1
	return ptr


func commit_opmasked_long(channel:int,cmds:Array,ptr:int,cmd:int,dirties:Array,
		values:Array,shift:int=0)->int:
	var opm:int
	var val:int
	for i in 4:
		opm=0
		val=values[i]
		for j in range(i,4):
			if dirties[j] and values[j]==val:
				dirties[j]=false
				opm|=0x10000<<j
		if opm!=0:
			cmds[ptr]=cmd|(channel<<8)|opm
			cmds[ptr+1]=val<<shift
			ptr+=2
	return ptr


func commit_panning(channel:int,cmds:Array,ptr:int)->int:
	cmds[ptr]=CONSTS.CMD_PAN|(channel<<8)|(panning_sent<<16)|(channel_invert_sent<<24)
	panning_dirty=false
	return ptr+1


func commit_clip(channel:int,cmds:Array,ptr:int)->int:
	cmds[ptr]=CONSTS.CMD_CLIP|(channel<<8)|(int(clip_sent)<<24)
	clip_dirty=false
	return ptr+1


func commit_velocity(channel:int,cmds:Array,ptr:int)->int:
	cmds[ptr]=CONSTS.CMD_VEL|(channel<<8)|(velocity_sent<<16)
	velocity_dirty=false
	return ptr+1


func commit_enable(channel:int,cmds:Array,ptr:int,mask:int,enable:int)->int:
	enable_mask=mask
	enable_bits=enable
	enable_dirty=false
	if mask==0:
		return ptr
	cmds[ptr]=CONSTS.CMD_ENABLE|(channel<<8)|(mask<<16)|(enable<<24)
	return ptr+1


func commit_retrigger(channel:int,cmds:Array,ptr:int)->int:
	var optr:int=ptr
	var opm:int
	var val:int
	for i in 4:
		if key_dirty_sent[i]==KON_PASS:
			continue
		val=key_dirty_sent[i]
		opm=0
		for j in range(i,4):
			if key_dirty_sent[j]==val:
				key_dirty_sent[j]=KON_PASS
				opm|=0x10000<<j
		if opm!=0:
			if val==KON_STD:
				cmds[ptr]=CONSTS.CMD_KEYON|(channel<<8)|opm|(velocity<<24)
			elif val==KON_LEGATO:
				cmds[ptr]=CONSTS.CMD_KEYON_LEGATO|(channel<<8)|opm|(velocity<<24)
			elif val==KON_STACCATO:
				cmds[ptr]=CONSTS.CMD_KEYON_STACCATO|(channel<<8)|opm|(velocity<<24)
			elif val==KON_OFF:
				cmds[ptr]=CONSTS.CMD_KEYOFF|(channel<<8)|opm
			elif val==KON_STOP:
				cmds[ptr]=CONSTS.CMD_STOP|(channel<<8)|opm
			ptr+=1
	if optr!=ptr:
		ptr=commit_panning(channel,cmds,ptr)
	for i in 4:
		key_dirty[i]=KON_PASS
	velocity_dirty=false
	return ptr

#

func set_instrument(inst:FmInstrument)->void:
	if inst==null:
		return
	copy(inst)
	clip_dirty=true
	enable_dirty=true
	enable_mask=0xF
	enable_bits=op_mask
	for i in 4:
		key_dirty[i]=KON_PASS
		fmi_dirty[i]=true
		fml_dirty[i]=true
		multiplier_dirty[i]=true
		divider_dirty[i]=true
		detune_dirty[i]=true
		detune_mode_dirty[i]=true
		attack_dirty[i]=true
		decay_dirty[i]=true
		suslev_dirty[i]=true
		susrate_dirty[i]=true
		release_dirty[i]=true
		ksr_dirty[i]=true
		repeat_dirty[i]=true
		ami_dirty[i]=true
		aml_dirty[i]=true
		output_dirty[i]=true
		wave_dirty[i]=true
		duty_cycle_dirty[i]=true
		for j in 4:
			pm_level_dirty[i][j]=true


func set_clip(value:int)->bool:
	clip_sent=bool(value)
	return true


func set_lfo_freq(value:int,lfo_mask:int,val_mask:int,val_shift:int)->bool:
	if (lfo_mask&15)==0:
		return false
	for i in 4:
		if lfo_mask&1:
			lfo_freq_dirty[i]=true
			lfo_freqs[i]=(lfo_freqs[i]&val_mask)|(value<<val_shift)
		lfo_mask>>=1
	return true


func set_opmasked(value:int,params:Array,dirties:Array,op:int)->bool:
	if op==0:
		return false
	for i in 4:
		if op&1:
			dirties[i]=true
			params[i]=value
		op>>=1
	return true


func set_output(value:int,op:int)->void:
	if op==0:
		return
	for i in 4:
		if op&1:
			output_dirty[i]=true
			routings[i][4]=value
		op>>=1


func set_fm_level(value:int,from:int,op:int)->void:
	if op==0:
		return
	for i in 4:
		if op&1:
			pm_level_dirty[from][i]=true
			routings[from][i]=value
		op>>=1


func set_frequency(f,op:int)->void:
	if op==0:
		return
	f=clamp(f,CONSTS.MIN_FREQ,CONSTS.MAX_FREQ)
	for i in 4:
		if op&1:
			freqs_dirty[i]=true
			fx_vals[CONSTS.FX_FRQ_PORTA][1+i]=f
			next_freqs[i]=f
		op>>=1


func slide_frequency(d,op:int)->void:
	if op==0:
		return
	for i in 4:
		if op&1:
			freqs_dirty[i]=true
			next_freqs[i]=clamp(next_freqs[i]+d,CONSTS.MIN_FREQ,CONSTS.MAX_FREQ)
			fx_vals[CONSTS.FX_FRQ_PORTA][1+i]=clamp(
				fx_vals[CONSTS.FX_FRQ_PORTA][1+i]+d,CONSTS.MIN_FREQ,CONSTS.MAX_FREQ
			)
		op>>=1


func slide_frequency_to(d:Array,op:int)->void:
	if op==0:
		return
	for i in 4:
		if op&1:
			freqs_dirty[i]=true
			if freqs_sent[i]>d[i+1]:
				next_freqs[i]=clamp(base_freqs[i]-d[0],d[i+1],CONSTS.MAX_FREQ)
			else:
				next_freqs[i]=clamp(base_freqs[i]+d[0],CONSTS.MIN_FREQ,d[i+1])
		op>>=1


func slide_fmi(d:int,op:int)->void:
	if op==0:
		return
	for i in 4:
		if op&1:
			fmi_dirty[i]=true
			fm_intensity[i]=clamp(fm_intensity[i]+d,0,12000)
		op>>=1


func slide_ami(d:int,op:int)->void:
	if op==0:
		return
	for i in 4:
		if op&1:
			ami_dirty[i]=true
			am_intensity[i]=clamp(am_intensity[i]+d,0,255)
		op>>=1


func slide_detune(d:int,op:int)->void:
	if op==0:
		return
	for i in 4:
		if op&1:
			detune_dirty[i]=true
			detunes[i]=clamp(detunes[i]+d,-12000,12000)
		op>>=1

#

func set_velocity(vel)->void:
	if vel!=null:
		velocity_dirty=true
		velocity=vel

#

func set_panning(pan,invert_l,invert_r)->void:
	if pan!=null:
		panning=pan
		panning_dirty=true
	if invert_l!=null:
		channel_invert=(channel_invert&~1)|int(bool(invert_l))
		panning_dirty=true
	if invert_r!=null:
		channel_invert=(channel_invert&~2)|(int(bool(invert_r))<<1)
		panning_dirty=true

#

func set_repeated_triggers(fx_cmd:int,opm:int)->void:
	fx_vals[fx_cmd][0]-=1
	if fx_vals[fx_cmd][0]<=0:
		fx_vals[fx_cmd][0]=fx_vals[fx_cmd][1]
	if opm==0:
		return
	macro_tick=0
	release_tick=-1
	var legato:int=KON_STD if fx_cmd==CONSTS.FX_RPT_ON else KON_STACCATO
	for i in 4:
		key_dirty[i]=legato if opm&1 else KON_PASS
		opm>>=1


func set_delayed_triggers(fx_cmd:int,opm:int)->void:
	fx_vals[fx_cmd]-=1
	if fx_vals[fx_cmd]<=0 and opm>0:
		var cmd:int
		if fx_cmd==CONSTS.FX_DLY_ON or fx_cmd==CONSTS.FX_DLY_RETRIG:
			macro_tick=0
			release_tick=-1
		elif fx_cmd==CONSTS.FX_DLY_OFF:
			release_tick=macro_tick
			cmd=KON_OFF
		if fx_cmd==CONSTS.FX_DLY_CUT:
			cmd=KON_STOP
		elif fx_cmd==CONSTS.FX_DLY_ON:
			cmd=KON_STD
		elif fx_cmd==CONSTS.FX_DLY_RETRIG:
			cmd=KON_STACCATO
		for i in 4:
			key_dirty[i]=cmd if opm&1 else KON_PASS
			opm>>=1


func set_repeated_phi_zero(op:int)->void:
	fx_vals[CONSTS.FX_RPT_PHI0][0]-=1
	if fx_vals[CONSTS.FX_RPT_PHI0][0]<=0:
		fx_vals[CONSTS.FX_RPT_PHI0][0]=fx_vals[CONSTS.FX_RPT_PHI0][1]
	if op==0:
		return
	for i in 4:
		if op&1:
			phase_dirty[i]=true
			phases[i]=0
			phases_rel[i]=false
		op>>=1


func set_delayed_phi_zero(op:int)->void:
	fx_vals[CONSTS.FX_DLY_PHI0]-=1
	if op==0:
		return
	for i in 4:
		if op&1:
			phase_dirty[i]=true
			phases[i]=0
			phases_rel[i]=false
		op>>=1
