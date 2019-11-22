extends FmInstrument
class_name FmVoice

enum{
	CMD_FREQ=0x01, CMD_KEYON, CMD_KEYON_LEGATO, CMD_KEYOFF, CMD_STOP, CMD_ENABLE,
	CMD_MULT=0x07, CMD_DIV, CMD_DET, CMD_DUC,
	CMD_WAV=0x0B,
	CMD_VEL=0x0C, CMD_AR, CMD_DR, CMD_SL, CMD_SR, CMD_RR, CMD_RM, CMD_KSR,
	CMD_PM=0x14, CMD_OUT,
	CMD_PAN=0x16,
	CMD_PHI=0x17,
	CMD_AMS=0x18, CMD_AML, CMD_FMS, CMD_FML,
	CMD_LFO_FREQ=0x1C, CMD_LFO_WAVE, CMD_LFO_DUC
}
enum{
	FX_FRQ_SET=0x00,FX_FRQ_ADJ,FX_FRQ_SLIDE,FX_FRQ_PORTA,FX_ARPEGGIO,
	FX_FMS_SET,FX_FMS_ADJ,FX_FMS_SLIDE,FX_FMS_LFO,
	FX_MUL_SET,FX_DIV_SET,
	FX_DET_SET,FX_DET_ADJ,FX_DET_SLIDE,
	FX_ATK_SET=0x10,FX_DEC_SET,FX_SUL_SET,FX_SUR_SET,FX_REL_SET,
	FX_KS_SET,FX_RPM_SET,FX_AMS_SET,FX_AMS_LFO,
	FX_DELAY=0x20,FX_DLY_OFF,FX_DLY_CUT,FX_DLY_ON,FX_DLY_RETRIG,
	FX_RPT_ON,FX_RPT_RETRIG,
	FX_DEBUG=0x3F
}
enum{
	TRG_KEEP, TRG_ON, TRG_OFF, TRG_STOP
}
const ATTRS=Pattern.ATTRS
const LG_MODE=Pattern.LEGATO_MODE

var trigger:int=TRG_KEEP
# Index by track
var fx_cmds:Array=[0,0,0,0]
var fx_opmasks:Array=[0,0,0,0]
var fx_apply:Array=[false,false,false,false]
# Index by command
var fx_vals:Array

var arpeggio_tick:int=0
var internal_tick:int=0
var legato:int=0
var freqs:Array=[0,0,0,0]
var base_freqs:Array=[0,0,0,0]
var pre_freqs:Array=[0,0,0,0]
var arp_freqs:Array=[0,0,0,0]
var velocity:int=255
var panning:int=0x1F

var instrument_dirty:bool=false
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


func _init()->void:
	for i in range(256):
		if i==FX_FRQ_PORTA:
			fx_vals.append([0,0,0,0,0])
		elif i==FX_ARPEGGIO:
			fx_vals.append([0,0,0])
		elif i==FX_RPT_ON or i==FX_RPT_RETRIG:
			fx_vals.append([0,0])
		else:
			fx_vals.append(0)

func process_tick(song:Song,channel:int,curr_order:int,curr_row:int,curr_tick:int)->void:
	var pat:Pattern=song.get_order_pattern(curr_order,channel)
	var note:Array=pat.notes[curr_row]
	var fx_cmd:int
	if curr_tick==0:
		# Reset delay counters
		for i in range(FX_DELAY,FX_DLY_RETRIG+1):
			fx_vals[i]=0
		fx_vals[FX_RPT_ON][0]=0
		fx_vals[FX_RPT_RETRIG][0]=0
		internal_tick=0
		#
		var j:int=0
		for i in range(song.num_fxs[channel]):
			fx_cmd=get_fx_cmd(note[ATTRS.FX0+j],i)
			if fx_cmd==FX_DELAY:
				fx_vals[FX_DELAY]=get_fx_val(note[ATTRS.FV0+j],note[ATTRS.NOTE],fx_cmd,i)
			j+=3
	if fx_vals[FX_DELAY]==0:
		if internal_tick==0:
			process_tick_0(note,song,song.num_fxs[channel])
		else:
			process_tick_n(song,channel)
		internal_tick+=1
	else:
		fx_vals[FX_DELAY]-=1

func process_tick_0(note:Array,song:Song,num_fxs:int)->void:
	legato=0 if note[ATTRS.LG_MODE]==null else note[ATTRS.LG_MODE]
	if note[ATTRS.NOTE]!=null:
		if note[ATTRS.NOTE]>=0:
			trigger=TRG_ON
			set_frequency(note[ATTRS.NOTE]*100)
		elif note[ATTRS.NOTE]==-1:
			trigger=TRG_OFF
		else:
			trigger=TRG_STOP
	if note[ATTRS.INSTR]!=null:
		set_instrument(song.get_instrument(note[ATTRS.INSTR]) as FmInstrument)
	set_velocity(note[ATTRS.VOL])
	set_panning(note[ATTRS.PAN])
	var j:int=0
	var fx_cmd:int
	var fx_opm
	var fx_val
	arp_freqs[0]=0
	arp_freqs[1]=0
	arp_freqs[2]=0
	arp_freqs[3]=0
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
			if fx_cmd==FX_FRQ_SET:
				set_frequency(fx_val,fx_opm)
			elif fx_cmd==FX_FRQ_ADJ or fx_cmd==FX_FRQ_SLIDE:
				slide_frequency(fx_val,fx_opm)
			elif fx_cmd==FX_FRQ_PORTA:
				slide_frequency_to(fx_val,fx_opm)
			elif fx_cmd==FX_ARPEGGIO:
				freqs_dirty_any=set_opmasked(fx_vals[0x04][arpeggio_tick],\
						arp_freqs,freqs_dirty,fx_opm)
			elif fx_cmd==FX_FMS_SET:
				fms_dirty_any=set_opmasked(fx_val,fm_intensity,fms_dirty,fx_opm)
			elif fx_cmd==FX_FMS_ADJ or fx_cmd==FX_FMS_SLIDE:
				slide_fms(fx_val,fx_opm)
			elif fx_cmd==FX_FMS_LFO:
				fml_dirty_any=set_opmasked(fx_val,fm_lfo,fml_dirty,fx_opm)
			elif fx_cmd==FX_MUL_SET:
				multiplier_dirty_any=set_opmasked(fx_val,multipliers,multiplier_dirty,fx_opm)
			elif fx_cmd==FX_DIV_SET:
				divider_dirty_any=set_opmasked(fx_val,dividers,divider_dirty,fx_opm)
			elif fx_cmd==FX_DET_SET:
				detune_dirty_any=set_opmasked(fx_val,detunes,detune_dirty,fx_opm)
			elif fx_cmd==FX_DET_ADJ or fx_cmd==FX_DET_SLIDE:
				slide_detune(fx_val,fx_opm)
			elif fx_cmd==FX_ATK_SET:
				attack_dirty_any=set_opmasked(fx_val,attacks,attack_dirty,fx_opm)
			elif fx_cmd==FX_DEC_SET:
				decay_dirty_any=set_opmasked(fx_val,decays,decay_dirty,fx_opm)
			elif fx_cmd==FX_SUL_SET:
				suslev_dirty_any=set_opmasked(fx_val,sustain_levels,suslev_dirty,fx_opm)
			elif fx_cmd==FX_SUR_SET:
				susrate_dirty_any=set_opmasked(fx_val,sustains,susrate_dirty,fx_opm)
			elif fx_cmd==FX_REL_SET:
				release_dirty_any=set_opmasked(fx_val,releases,release_dirty,fx_opm)
			elif fx_cmd==FX_KS_SET:
				ksr_dirty_any=set_opmasked(fx_val,key_scalers,ksr_dirty,fx_opm)
			elif fx_cmd==FX_RPM_SET:
				repeat_dirty_any=set_opmasked(fx_val,repeats,repeat_dirty,fx_opm)
			elif fx_cmd==FX_AMS_SET:
				ams_dirty_any=set_opmasked(fx_val,am_intensity,ams_dirty,fx_opm)
			elif fx_cmd==FX_AMS_LFO:
				aml_dirty_any=set_opmasked(fx_val,am_lfo,aml_dirty,fx_opm)
			elif fx_cmd==FX_DEBUG:
				breakpoint
		j+=3
	for i in range(4):
		base_freqs[i]=pre_freqs[i]
		freqs[i]=base_freqs[i]+arp_freqs[i]
	arpeggio_tick=(arpeggio_tick+1)%3

func process_tick_n(song:Song,channel:int)->void:
	var fx_cmd:int
	for i in range(song.num_fxs[channel]):
		if not fx_apply[i]:
			continue
		fx_cmd=fx_cmds[i]
		if fx_cmd==FX_FRQ_SLIDE:
			slide_frequency(fx_vals[FX_FRQ_SLIDE],fx_opmasks[i])
		elif fx_cmd==FX_FRQ_PORTA:
			slide_frequency_to(fx_vals[FX_FRQ_PORTA],fx_opmasks[i])
		elif fx_cmd==FX_ARPEGGIO:
			freqs_dirty_any=set_opmasked(fx_vals[0x04][arpeggio_tick],\
					arp_freqs,freqs_dirty,fx_opmasks[i])
		elif fx_cmd==FX_FMS_SLIDE:
			slide_fms(fx_vals[FX_FMS_SLIDE],fx_opmasks[i])
		elif fx_cmd==FX_DET_SLIDE:
			slide_detune(fx_vals[FX_DET_SLIDE],fx_opmasks[i])
		elif fx_cmd==FX_DLY_OFF or fx_cmd==FX_DLY_CUT\
				or fx_cmd==FX_DLY_ON or fx_cmd==FX_DLY_RETRIG:
			set_delayed_triggers(fx_cmd)
		elif fx_cmd==FX_RPT_ON or fx_cmd==FX_RPT_RETRIG:
			set_repeated_triggers(fx_cmd)
	for i in range(4):
		base_freqs[i]=pre_freqs[i]
		freqs[i]=base_freqs[i]+arp_freqs[i]
	arpeggio_tick=(arpeggio_tick+1)%3

func get_fx_cmd(c,i:int)->int:
	if c!=null:
		fx_cmds[i]=c
		fx_apply[i]=true
	return fx_cmds[i]

func get_fx_val(v,note,cmd:int,cmd_col:int)->int:
	if v==null:
		return fx_vals[cmd]
	if cmd==FX_FRQ_SET:
		fx_vals[cmd]=clamp(v*50,-200,13000)
	elif cmd==FX_DET_SET:
		fx_vals[cmd]=clamp((v-128)*100,-12000,12000)
	elif cmd==FX_FRQ_ADJ or cmd==FX_FRQ_SLIDE\
			or cmd==FX_FMS_ADJ or cmd==FX_FMS_SLIDE\
			or cmd==FX_DET_ADJ or cmd==FX_DET_SLIDE:
		fx_vals[cmd]=v-128
	elif cmd==FX_FRQ_PORTA:
		fx_vals[cmd][0]=v
		if note!=null:
			note*=100
			fx_vals[cmd][1]=note
			fx_vals[cmd][2]=note
			fx_vals[cmd][3]=note
			fx_vals[cmd][4]=note
	elif cmd==FX_ARPEGGIO:
		fx_vals[cmd][1]=clamp((v>>4)*100,-200,13000)
		fx_vals[cmd][2]=clamp((v&15)*100,-200,13000)
	elif cmd==FX_FMS_SET:
		fx_vals[cmd]=clamp(v*50,0,12000)
	elif cmd==FX_FMS_LFO or cmd==FX_AMS_LFO:
		fx_vals[cmd]=clamp(v,0,3)
	elif cmd==FX_MUL_SET or cmd==FX_DIV_SET:
		fx_vals[cmd]=clamp(v,0,31)
	elif cmd==FX_DELAY:
		fx_apply[cmd_col]=false
		return v
	elif cmd==FX_RPT_ON or cmd==FX_RPT_RETRIG:
		fx_vals[cmd][0]=0
		fx_vals[cmd][1]=v
	elif cmd==FX_KS_SET:
		fx_vals[cmd]=clamp(v,0,7)
	elif cmd==FX_RPM_SET:
		fx_vals[cmd]=clamp(v,0,4)
	else:
		fx_vals[cmd]=v
	fx_apply[cmd_col]=true
	return fx_vals[cmd]

#

func commit(channel:int,cmds:Array,ptr:int)->int:
	if instrument_dirty:
		ptr=commit_instrument(channel,cmds,ptr)
	if trigger>TRG_KEEP:
		ptr=commit_retrigger(channel,cmds,ptr)
	if freqs_dirty_any:
		ptr=commit_opmasked_16(channel,cmds,ptr,CMD_FREQ,freqs_dirty,freqs)
		freqs_dirty_any=false
	if velocity_dirty:
		ptr=commit_velocity(channel,cmds,ptr)
	if panning_dirty:
		ptr=commit_panning(channel,cmds,ptr)
	if fms_dirty_any:
		ptr=commit_opmasked_16(channel,cmds,ptr,CMD_FMS,fms_dirty,fm_intensity)
		fms_dirty_any=false
	if fml_dirty_any:
		ptr=commit_opmasked_16(channel,cmds,ptr,CMD_FML,fml_dirty,fm_lfo)
		fml_dirty_any=false
	if multiplier_dirty_any:
		ptr=commit_opmasked_8(channel,cmds,ptr,CMD_MULT,multiplier_dirty,multipliers)
		multiplier_dirty_any=false
	if divider_dirty_any:
		ptr=commit_opmasked_8(channel,cmds,ptr,CMD_DIV,divider_dirty,dividers)
		divider_dirty_any=false
	if detune_dirty_any:
		ptr=commit_opmasked_16(channel,cmds,ptr,CMD_DET,detune_dirty,detunes)
		detune_dirty_any=false
	if attack_dirty_any:
		ptr=commit_opmasked_8(channel,cmds,ptr,CMD_AR,attack_dirty,attacks)
		attack_dirty_any=false
	if decay_dirty_any:
		ptr=commit_opmasked_8(channel,cmds,ptr,CMD_DR,decay_dirty,decays)
		decay_dirty_any=false
	if suslev_dirty_any:
		ptr=commit_opmasked_8(channel,cmds,ptr,CMD_SL,suslev_dirty,sustain_levels)
		suslev_dirty_any=false
	if susrate_dirty_any:
		ptr=commit_opmasked_8(channel,cmds,ptr,CMD_SR,susrate_dirty,sustains)
		susrate_dirty_any=false
	if release_dirty_any:
		ptr=commit_opmasked_8(channel,cmds,ptr,CMD_RR,release_dirty,releases)
		release_dirty_any=false
	if ksr_dirty_any:
		ptr=commit_opmasked_8(channel,cmds,ptr,CMD_KSR,ksr_dirty,key_scalers)
		ksr_dirty_any=false
	if repeat_dirty_any:
		ptr=commit_opmasked_8(channel,cmds,ptr,CMD_RM,repeat_dirty,repeats)
		repeat_dirty_any=false
	if ams_dirty_any:
		ptr=commit_opmasked_8(channel,cmds,ptr,CMD_AMS,ams_dirty,am_intensity)
		ams_dirty_any=false
	if aml_dirty_any:
		ptr=commit_opmasked_8(channel,cmds,ptr,CMD_AML,aml_dirty,am_lfo)
		aml_dirty_any=false
	return ptr

func commit_opmasked_8(channel:int,cmds:Array,ptr:int,cmd:int,dirties:Array,values:Array)->int:
	for i in range(4):
		if dirties[i]:
			dirties[i]=false
			cmds[ptr]=cmd
			cmds[ptr+1]=channel
			cmds[ptr+2]=1<<i
			cmds[ptr+3]=values[i]
			ptr+=4
	return ptr

func commit_opmasked_16(channel:int,cmds:Array,ptr:int,cmd:int,dirties:Array,values:Array)->int:
	for i in range(4):
		if dirties[i]:
			dirties[i]=false
			cmds[ptr]=cmd
			cmds[ptr+1]=channel
			cmds[ptr+2]=1<<i
			cmds[ptr+3]=values[i]>>8
			cmds[ptr+4]=values[i]&255
			ptr+=5
	return ptr

func commit_panning(channel:int,cmds:Array,ptr:int)->int:
	cmds[ptr]=CMD_PAN
	cmds[ptr+1]=channel
	cmds[ptr+2]=panning
	panning_dirty=false
	return ptr+3

func commit_velocity(channel:int,cmds:Array,ptr:int)->int:
	cmds[ptr]=CMD_VEL
	cmds[ptr+1]=channel
	cmds[ptr+2]=velocity
	velocity_dirty=false
	return ptr+3

func commit_retrigger(channel:int,cmds:Array,ptr:int)->int:
	if trigger==TRG_OFF:
		cmds[ptr]=CMD_KEYOFF
		cmds[ptr+1]=channel
		cmds[ptr+2]=15
		return ptr+3
	elif trigger==TRG_STOP:
		cmds[ptr]=CMD_STOP
		cmds[ptr+1]=channel
		cmds[ptr+2]=15
		return ptr+3
	if freqs_dirty_any:
		ptr=commit_opmasked_16(channel,cmds,ptr,CMD_FREQ,freqs_dirty,freqs)
		freqs_dirty_any=false
	if legato==LG_MODE.STACCATO:
		cmds[ptr]=CMD_STOP
		cmds[ptr+1]=channel
		cmds[ptr+2]=15
		ptr+=3
	cmds[ptr]=CMD_KEYON_LEGATO if legato==LG_MODE.LEGATO else CMD_KEYON
	cmds[ptr+1]=channel
	cmds[ptr+2]=op_mask
	cmds[ptr+3]=velocity
	trigger=TRG_KEEP
	velocity_dirty=false
	return commit_panning(channel,cmds,ptr+4)

func commit_instrument(channel:int,cmds:Array,ptr:int)->int:
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
		var opm:int=1<<i
		cmds[ptr]=CMD_AR
		cmds[ptr+1]=channel
		cmds[ptr+2]=opm
		cmds[ptr+3]=attacks[i]
		cmds[ptr+4]=CMD_DR
		cmds[ptr+5]=channel
		cmds[ptr+6]=opm
		cmds[ptr+7]=decays[i]
		cmds[ptr+8]=CMD_SL
		cmds[ptr+9]=channel
		cmds[ptr+10]=opm
		cmds[ptr+11]=sustain_levels[i]
		cmds[ptr+12]=CMD_SR
		cmds[ptr+13]=channel
		cmds[ptr+14]=opm
		cmds[ptr+15]=sustains[i]
		cmds[ptr+16]=CMD_RR
		cmds[ptr+17]=channel
		cmds[ptr+18]=opm
		cmds[ptr+19]=releases[i]
		cmds[ptr+20]=CMD_RM
		cmds[ptr+21]=channel
		cmds[ptr+22]=opm
		cmds[ptr+23]=repeats[i]
		cmds[ptr+24]=CMD_WAV
		cmds[ptr+25]=channel
		cmds[ptr+26]=opm
		cmds[ptr+27]=waveforms[i]
		cmds[ptr+28]=CMD_DUC
		cmds[ptr+29]=channel
		cmds[ptr+30]=opm
		cmds[ptr+31]=duty_cycles[i]
		cmds[ptr+32]=CMD_MULT
		cmds[ptr+33]=channel
		cmds[ptr+34]=opm
		cmds[ptr+35]=multipliers[i]
		cmds[ptr+36]=CMD_DIV
		cmds[ptr+37]=channel
		cmds[ptr+38]=opm
		cmds[ptr+39]=dividers[i]
		cmds[ptr+40]=CMD_DET
		cmds[ptr+41]=channel
		cmds[ptr+42]=opm
		cmds[ptr+43]=detunes[i]>>8
		cmds[ptr+44]=detunes[i]&255
		cmds[ptr+45]=CMD_FMS
		cmds[ptr+46]=channel
		cmds[ptr+47]=1<<i
		cmds[ptr+48]=fm_intensity[i]>>8
		cmds[ptr+49]=fm_intensity[i]&255
		cmds[ptr+50]=CMD_FML
		cmds[ptr+51]=channel
		cmds[ptr+52]=1<<i
		cmds[ptr+53]=fm_lfo[i]
		cmds[ptr+54]=CMD_AMS
		cmds[ptr+55]=channel
		cmds[ptr+56]=1<<i
		cmds[ptr+57]=am_intensity[i]
		cmds[ptr+58]=CMD_AML
		cmds[ptr+59]=channel
		cmds[ptr+60]=1<<i
		cmds[ptr+61]=am_lfo[i]
		cmds[ptr+62]=CMD_KSR
		cmds[ptr+63]=channel
		cmds[ptr+64]=1<<i
		cmds[ptr+65]=key_scalers[i]
		ptr+=62
		for j in range(4):
			cmds[ptr]=CMD_PM
			cmds[ptr+1]=channel
			cmds[ptr+2]=(i<<4)|j
			cmds[ptr+3]=routings[i][j]
			ptr+=4
		cmds[ptr]=CMD_OUT
		cmds[ptr+1]=channel
		cmds[ptr+2]=opm
		cmds[ptr+3]=routings[i][4]
		ptr+=4
	cmds[ptr]=CMD_ENABLE
	cmds[ptr+1]=channel
	cmds[ptr+2]=15
	cmds[ptr+3]=op_mask
	instrument_dirty=false
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
	return ptr+4

#

func set_instrument(inst:FmInstrument)->void:
	if inst==null:
		return
	instrument_dirty=true
	op_mask=inst.op_mask
	attacks=inst.attacks.duplicate()
	decays=inst.decays.duplicate()
	sustains=inst.sustains.duplicate()
	sustain_levels=inst.sustain_levels.duplicate()
	releases=inst.releases.duplicate()
	repeats=inst.repeats.duplicate()
	multipliers=inst.multipliers.duplicate()
	dividers=inst.dividers.duplicate()
	detunes=inst.detunes.duplicate()
	duty_cycles=inst.duty_cycles.duplicate()
	waveforms=inst.waveforms.duplicate()
	am_intensity=inst.am_intensity.duplicate()
	am_lfo=inst.am_lfo.duplicate()
	fm_intensity=inst.fm_intensity.duplicate()
	fm_lfo=inst.fm_lfo.duplicate()
	routings=inst.routings.duplicate(true)

#

func set_opmasked(value:int,params:Array,dirties:Array,op_mask:int=15)->bool:
	if (op_mask&15)==0:
		return false
	for i in range(4):
		if op_mask&1:
			dirties[i]=true
			params[i]=value
		op_mask>>=1
	return true

func set_frequency(f,op_mask:int=-1)->void:
	if (op_mask&15)==0:
		return
	var set_now:bool=op_mask==-1
	f=clamp(f,-200,13000)
	for i in range(4):
		if op_mask&1:
			freqs_dirty[i]=true
			fx_vals[FX_FRQ_PORTA][1+i]=f
			if set_now:
				pre_freqs[i]=f
		op_mask>>=1
	freqs_dirty_any=true

func slide_frequency(d,op_mask:int=15)->void:
	if (op_mask&15)==0:
		return
	for i in range(4):
		if op_mask&1:
			freqs_dirty[i]=true
			pre_freqs[i]=clamp(pre_freqs[i]+d,-200,13000)
			fx_vals[FX_FRQ_PORTA][1+i]=clamp(fx_vals[FX_FRQ_PORTA][1+i]+d,-200,13000)
		op_mask>>=1
	freqs_dirty_any=true

func slide_frequency_to(d:Array,op_mask:int=15)->void:
	if (op_mask&15)==0:
		return
	for i in range(4):
		if op_mask&1:
			freqs_dirty[i]=true
			if freqs[i]>d[i+1]:
				pre_freqs[i]=clamp(base_freqs[i]-d[0],d[i+1],13000)
			else:
				pre_freqs[i]=clamp(base_freqs[i]+d[0],-200,d[i+1])
		op_mask>>=1
	freqs_dirty_any=true

func slide_fms(d:int,op_mask:int=15)->void:
	if (op_mask&15)==0:
		return
	for i in range(4):
		if op_mask&1:
			fms_dirty[i]=true
			fm_intensity[i]=clamp(fm_intensity[i]+d,0,12000)
		op_mask>>=1
	fms_dirty_any=true

func slide_detune(d:int,op_mask:int=15)->void:
	if (op_mask&15)==0:
		return
	for i in range(4):
		if op_mask&1:
			detune_dirty[i]=true
			detunes[i]=clamp(detunes[i]+d,-12000,12000)
		op_mask>>=1
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
		if fx_cmd==FX_RPT_ON:
			trigger=TRG_ON
			legato=LG_MODE.OFF
		elif fx_cmd==FX_RPT_RETRIG:
			trigger=TRG_ON
			legato=LG_MODE.STACCATO

func set_delayed_triggers(fx_cmd:int)->void:
	fx_vals[fx_cmd]-=1
	if fx_vals[fx_cmd]<=0:
		if fx_cmd==FX_DLY_OFF:
			trigger=TRG_OFF
		elif fx_cmd==FX_DLY_CUT:
			trigger=TRG_STOP
		elif fx_cmd==FX_DLY_ON:
			trigger=TRG_ON
			legato=LG_MODE.OFF
		elif fx_cmd==FX_DLY_RETRIG:
			trigger=TRG_ON
			legato=LG_MODE.STACCATO
