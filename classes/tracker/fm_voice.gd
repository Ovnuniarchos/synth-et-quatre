extends FmInstrument
class_name FmVoice

enum{
	CMD_FREQ=0x01, CMD_KEYON, CMD_KEYON_LEGATO, CMD_KEYOFF, CMD_STOP, CMD_ENABLE,
	CMD_MULT=0x07, CMD_DIV, CMD_DET, CMD_DUC,
	CMD_WAV=0x0B,
	CMD_VEL=0x0C, CMD_AR, CMD_DR, CMD_SL,	CMD_SR, CMD_RR, CMD_RM,
	CMD_PM=0x13, CMD_OUT,
	CMD_PAN=0x15,
	CMD_PHI=0x16,
	CMD_AMS=0x17, CMD_AML, CMD_FMS, CMD_FML,
	CMD_LFO_FREQ=0x1B, CMD_LFO_WAVE, CMD_LFO_DUC
}
enum{
	FX_FRQ_SET,FX_FRQ_ADJ,FX_FRQ_SLIDE,FX_FRQ_PORTA,FX_ARPEGGIO,
	FX_FMS_SET,FX_FMS_ADJ,FX_FMS_SLIDE,FX_FMS_LFO,
	FX_MUL_SET,FX_DIV_SET,
	FX_DET_SET,FX_DET_ADJ,FX_DET_SLIDE
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
var multiplier_dirty_any:bool=false
var multiplier_dirty:Array=[false,false,false,false]
var divider_dirty_any:bool=false
var divider_dirty:Array=[false,false,false,false]
var detune_dirty_any:bool=false
var detune_dirty:Array=[false,false,false,false]
var velocity_dirty:bool=false
var panning_dirty:bool=false


func _init()->void:
	for i in range(64):
		if i==FX_FRQ_PORTA:
			fx_vals.append([0,0,0,0,0])
		elif i==FX_ARPEGGIO:
			fx_vals.append([0,400,700])
		else:
			fx_vals.append(0)

func process_tick_0(song:Song,channel:int,curr_order:int,curr_row:int)->void:
	var pat:Pattern=song.get_order_pattern(curr_order,channel)
	var note:Array=pat.notes[curr_row]
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
	var j:int=-3
	var fx_cmd:int
	var fx_opm
	var fx_val
	arp_freqs[0]=0
	arp_freqs[1]=0
	arp_freqs[2]=0
	arp_freqs[3]=0
	for i in range(song.num_fxs[channel]):
		j+=3
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
			elif fx_cmd==FX_FMS_SET:
				set_fms(fx_val,fx_opm)
			elif fx_cmd==FX_FMS_ADJ:
				slide_fms(fx_val,fx_opm)
			elif fx_cmd==FX_MUL_SET:
				set_multiplier(fx_val,fx_opm)
			elif fx_cmd==FX_DIV_SET:
				set_divider(fx_val,fx_opm)
			elif fx_cmd==FX_DET_SET:
				set_detune(fx_val,fx_opm)
			elif fx_cmd==FX_DET_ADJ or fx_cmd==FX_DET_SLIDE:
				slide_detune(fx_val,fx_opm)
	for i in range(4):
		base_freqs[i]=pre_freqs[i]
		freqs[i]=base_freqs[i]

func process_tick_n(song:Song,channel:int,tick:int)->void:
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
			arpeggio(fx_vals[0x04][tick%3],fx_opmasks[i])
		elif fx_cmd==FX_FMS_SLIDE:
			slide_fms(fx_vals[FX_FMS_SLIDE],fx_opmasks[i])
		elif fx_cmd==FX_DET_SLIDE:
			slide_detune(fx_vals[FX_DET_SLIDE],fx_opmasks[i])
	for i in range(4):
		base_freqs[i]=pre_freqs[i]
		freqs[i]=base_freqs[i]+arp_freqs[i]

func get_fx_cmd(c,i:int)->int:
	if c!=null:
		fx_cmds[i]=c
		fx_apply[i]=true
	return fx_cmds[i]

func get_fx_val(v,note,cmd:int,i:int)->int:
	if v==null:
		return fx_vals[cmd]
	if cmd==FX_FRQ_SET:
		fx_vals[FX_FRQ_SET]=v*50
	elif cmd==FX_DET_SET:
		fx_vals[FX_DET_SET]=(v-128)*100
	elif cmd==FX_FRQ_ADJ or cmd==FX_FRQ_SLIDE\
			or cmd==FX_FMS_ADJ or cmd==FX_FMS_SLIDE\
			or cmd==FX_DET_ADJ or cmd==FX_DET_SLIDE:
		fx_vals[cmd]=v-128
	elif cmd==FX_FRQ_PORTA:
		fx_vals[FX_FRQ_PORTA][0]=v
		if note!=null:
			note*=100
			fx_vals[FX_FRQ_PORTA][1]=note
			fx_vals[FX_FRQ_PORTA][2]=note
			fx_vals[FX_FRQ_PORTA][3]=note
			fx_vals[FX_FRQ_PORTA][4]=note
	elif cmd==FX_ARPEGGIO:
		fx_vals[FX_ARPEGGIO][1]=(v>>4)*100
		fx_vals[FX_ARPEGGIO][2]=(v&15)*100
	elif cmd==FX_FMS_SET:
		fx_vals[FX_FMS_SET]=v*50
	elif cmd==FX_MUL_SET or cmd==FX_DIV_SET:
		fx_vals[cmd]=v
	fx_apply[i]=true
	return fx_vals[cmd]

#

func commit(channel:int,cmds:Array,ptr:int)->int:
	if instrument_dirty:
		ptr=commit_instrument(channel,cmds,ptr)
	if trigger>TRG_KEEP:
		ptr=commit_retrigger(channel,cmds,ptr)
	if freqs_dirty_any:
		ptr=commit_freqs(channel,cmds,ptr)
	if velocity_dirty:
		ptr=commit_velocity(channel,cmds,ptr)
	if panning_dirty:
		ptr=commit_panning(channel,cmds,ptr)
	if fms_dirty_any:
		ptr=commit_fms(channel,cmds,ptr)
	if multiplier_dirty_any:
		ptr=commit_multipliers(channel,cmds,ptr)
	if divider_dirty_any:
		ptr=commit_dividers(channel,cmds,ptr)
	if detune_dirty_any:
		ptr=commit_detunes(channel,cmds,ptr)
	return ptr

func commit_detunes(channel:int,cmds:Array,ptr:int)->int:
	for i in range(4):
		if detune_dirty[i]:
			cmds[ptr]=CMD_DET
			cmds[ptr+1]=channel
			cmds[ptr+2]=1<<i
			cmds[ptr+3]=detunes[i]>>8
			cmds[ptr+4]=detunes[i]&255
			ptr+=5
		detune_dirty[i]=false
	detune_dirty_any=false
	return ptr

func commit_dividers(channel:int,cmds:Array,ptr:int)->int:
	for i in range(4):
		if divider_dirty[i]:
			cmds[ptr]=CMD_DIV
			cmds[ptr+1]=channel
			cmds[ptr+2]=1<<i
			cmds[ptr+3]=dividers[i]
			ptr+=4
		divider_dirty[i]=false
	divider_dirty_any=false
	return ptr

func commit_multipliers(channel:int,cmds:Array,ptr:int)->int:
	for i in range(4):
		if multiplier_dirty[i]:
			cmds[ptr]=CMD_MULT
			cmds[ptr+1]=channel
			cmds[ptr+2]=1<<i
			cmds[ptr+3]=multipliers[i]
			ptr+=4
		multiplier_dirty[i]=false
	multiplier_dirty_any=false
	return ptr

func commit_fms(channel:int,cmds:Array,ptr:int)->int:
	for i in range(4):
		if fms_dirty[i]:
			cmds[ptr]=CMD_FMS
			cmds[ptr+1]=channel
			cmds[ptr+2]=1<<i
			cmds[ptr+3]=fm_intensity[i]>>8
			cmds[ptr+4]=fm_intensity[i]&255
			ptr+=5
		fms_dirty[i]=false
	fms_dirty_any=false
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

func commit_freqs(channel:int,cmds:Array,ptr:int)->int:
	for i in range(4):
		if freqs_dirty[i]:
			var f:int=freqs[i]
			cmds[ptr]=CMD_FREQ
			cmds[ptr+1]=channel
			cmds[ptr+2]=1<<i
			cmds[ptr+3]=f>>8
			cmds[ptr+4]=f&255
			ptr+=5
		freqs_dirty[i]=false
	freqs_dirty_any=false
	return ptr

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
	ptr=commit_freqs(channel,cmds,ptr)
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
		ptr+=50
		for j in range(4):
			cmds[ptr]=CMD_PM
			cmds[ptr+1]=channel
			cmds[ptr+2]=i
			cmds[ptr+3]=j
			cmds[ptr+4]=routings[i][j]
			ptr+=5
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
	multiplier_dirty_any=false
	divider_dirty_any=false
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
	fm_intensity=inst.fm_intensity.duplicate()
	routings=inst.routings.duplicate(true)

#

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

func arpeggio(d:int,op_mask:int=15)->void:
	if (op_mask&15)==0:
		return
	d=clamp(d,-200,13000)
	for i in range(4):
		if op_mask&1:
			freqs_dirty[i]=true
			arp_freqs[i]=d
		op_mask>>=1
	freqs_dirty_any=true

func set_fms(d:int,op_mask:int=15)->void:
	if (op_mask&15)==0:
		return
	d=clamp(d,0,12000)
	for i in range(4):
		if op_mask&1:
			fms_dirty[i]=true
			fm_intensity[i]=d
		op_mask>>=1
	fms_dirty_any=true

func slide_fms(d:int,op_mask:int=15)->void:
	if (op_mask&15)==0:
		return
	for i in range(4):
		if op_mask&1:
			fms_dirty[i]=true
			fm_intensity[i]=clamp(fm_intensity[i]+d,0,12000)
		op_mask>>=1
	fms_dirty_any=true

func set_multiplier(d:int,op_mask:int=15)->void:
	if (op_mask&15)==0:
		return
	d=clamp(d,0,31)
	for i in range(4):
		if op_mask&1:
			multipliers[i]=d
			multiplier_dirty[i]=true
		op_mask>>=1
	multiplier_dirty_any=true

func set_divider(d:int,op_mask:int=15)->void:
	if (op_mask&15)==0:
		return
	d=clamp(d,0,31)
	for i in range(4):
		if op_mask&1:
			dividers[i]=d
			divider_dirty[i]=true
		op_mask>>=1
	divider_dirty_any=true

func set_detune(d:int,op_mask:int=15)->void:
	if (op_mask&15)==0:
		return
	d=clamp(d,-12000,12000)
	for i in range(4):
		if op_mask&1:
			detunes[i]=d
			detune_dirty[i]=true
		op_mask>>=1
	detune_dirty_any=true

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
