extends Reference
class_name Song

signal wave_changed(wave,wave_ix)
signal wave_list_changed
signal instrument_list_changed
signal arp_list_changed
signal channels_changed
signal order_changed(order_ix,channel_ix)
signal speed_changed
signal highlights_changed
signal error(message)


const FMVC=preload("res://classes/tracker/fm_voice_constants.gd")
const SONGL=preload("res://classes/song/song_limits.gd")
const WAVE=FmInstrument.WAVE


var title:String=tr("DEFN_SONG")
var author:String=""
var pattern_list:Array # [channel,order]
var orders:Array # [row,channel]
var wave_list:Array
var instrument_list:Array
var arp_list:Array
var num_channels:int
var num_fxs:Array
var pattern_length:int
var ticks_second:int
var ticks_row:int
var minor_highlight:int
var major_highlight:int
var lfo_frequencies:Array=[4.0,2.0,1.0,0.5]
var lfo_waves:Array=[WAVE.TRIANGLE,WAVE.SAW,WAVE.RECTANGLE,WAVE.NOISE]
var lfo_duty_cycles:Array=[0,0,128,0]
# Transient
var file_name:String=""


func _init(max_channels:int=SONGL.MAX_CHANNELS,pat_length:int=SONGL.DFL_PAT_LENGTH,fx_length:int=1,tks_sec:int=50,tks_row:int=6)->void:
	num_channels=clamp(max_channels,SONGL.MIN_CHANNELS,SONGL.MAX_CHANNELS)
	pattern_length=clamp(pat_length,SONGL.MIN_PAT_LENGTH,SONGL.MAX_PAT_LENGTH)
	ticks_second=max(tks_sec,1.0)
	ticks_row=max(tks_row,1.0)
	minor_highlight=4
	major_highlight=16
	var nfx:int=clamp(fx_length,SONGL.MIN_FX_LENGTH,SONGL.MAX_FX_LENGTH)
	pattern_list=[]
	pattern_list.resize(SONGL.MAX_CHANNELS)
	orders=[[]]
	orders[0].resize(SONGL.MAX_CHANNELS)
	num_fxs.resize(SONGL.MAX_CHANNELS)
	for i in SONGL.MAX_CHANNELS:
		pattern_list[i]=[Pattern.new()]
		orders[0][i]=0
		num_fxs[i]=nfx
	instrument_list.append(FmInstrument.new())
	instrument_list[0].name+=" 00"
	arp_list=[]
	wave_list=[]
	emit_signal("wave_list_changed")
	emit_signal("instrument_list_changed")
	emit_signal("arp_list_changed")
	emit_signal("channels_changed")
	emit_signal("speed_changed")
	emit_signal("highlights_changed")

#

func set_minor_highlight(m:int)->void:
	minor_highlight=m if m<=pattern_length else pattern_length
	emit_signal("highlights_changed")

func set_major_highlight(m:int)->void:
	major_highlight=m if m<=pattern_length else pattern_length
	emit_signal("highlights_changed")

#

func _on_wave_name_changed(wave:Waveform,_name:String)->void:
	var ix:int=wave_list.find(wave)
	if ix!=-1:
		emit_signal("wave_changed",wave,ix)

func add_wave(wave:Waveform)->void:
	if can_add_wave() and wave_list.find(wave)==-1:
		wave_list.append(wave)
		wave.connect("name_changed",self,"_on_wave_name_changed")
		emit_signal("wave_list_changed")

func delete_wave(wave:Waveform)->void:
	if not can_delete_wave(wave):
		return
	var ix:int=wave_list.find(wave)+SONGL.MIN_CUSTOM_WAVE
	for inst in instrument_list:
		inst.delete_waveform(ix)
	for lfi in 4:
		if lfo_waves[lfi]>ix:
			lfo_waves[lfi]=correct_wave(lfo_waves[lfi])
	for chan in pattern_list:
		for pat in chan:
			for note in pat.notes:
				for fxi in range(Pattern.ATTRS.FX0,Pattern.MAX_ATTR,3):
					var cmd=note[fxi]
					var val=note[fxi+2]
					if (cmd!=FMVC.FX_WAVE_SET and cmd!=FMVC.FX_LFO_WAVE_SET)\
								or val==null or val<SONGL.MIN_CUSTOM_WAVE:
							continue
					note[fxi+2]=correct_wave(note[fxi+2])
	wave_list.erase(wave)
	emit_signal("order_changed",-1,-1)
	emit_signal("wave_list_changed")
	emit_signal("instrument_list_changed")

func correct_wave(w:int)->int:
	w-=1
	if w==WAVE.NOISE:
		return WAVE.TRIANGLE
	return w

func can_add_wave(count:int=1)->bool:
	if wave_list.size()+count<SONGL.MAX_WAVES:
		return true
	emit_signal("error",tr("ERR_SONG_MAX_WAVES").format({"i_max_waves":SONGL.MAX_WAVES}))
	return false

func can_delete_wave(wave:Waveform)->bool:
	var wave_ix:int=wave_list.find(wave)
	if wave_ix==-1:
		emit_signal("error",tr("ERR_SONG_WAVE_NOT_FOUND"))
		return false
	wave_ix+=SONGL.MIN_CUSTOM_WAVE
	for lw in range(lfo_waves.size()):
		if lfo_waves[lw]==wave_ix:
			emit_signal("error",tr("ERR_SONG_WAVE_IN_LFO").format({"i_lfo":lw}))
			return false
	for ins in range(instrument_list.size()):
		if !(instrument_list[ins] is FmInstrument):
			continue
		for w in range(instrument_list[ins].waveforms.size()):
			if instrument_list[ins].waveforms[w]==wave_ix:
				emit_signal("error",tr("ERR_SONG_WAVE_IN_INSTRUMENT").format({"i_instr":ins,"i:op":w}))
				return false
	for chan in range(pattern_list.size()):
		for pat in range(pattern_list[chan].size()):
			for note in range(pattern_list[chan][pat].notes.size()):
				for col in range(Pattern.MIN_FX_COL,Pattern.MAX_ATTR,3):
					var cmd=pattern_list[chan][pat].notes[note][col]
					if cmd!=FMVC.FX_WAVE_SET and cmd!=FMVC.FX_LFO_WAVE_SET:
						continue
					if pattern_list[chan][pat].notes[note][col+2]==wave_ix:
						emit_signal("error",
							tr("ERR_SONG_WAVE_IN_SONG").format({"i_pattern":pat,"i_channel":chan,"i_row":note})
						)
						return false
	return true

func get_wave(index:int)->Waveform:
	if index<0 or index>=wave_list.size():
		return null
	return wave_list[index]

func find_wave(wave:Waveform)->int:
	return wave_list.find(wave)

func find_wave_ref(wave:WeakRef)->int:
	if wave==null:
		return -1
	return wave_list.find(wave.get_ref() as Waveform)

func send_wave(wave:Waveform,synth:Synth,wave_ix:int=-1)->void:
	wave_ix=wave_list.find(wave) if wave_ix==-1 else wave_ix
	if wave_ix==-1:
		return
	if wave is SynthWave:
		synth.synth.define_wave(wave_ix+SONGL.MIN_CUSTOM_WAVE,wave.data.duplicate())
	elif wave is SampleWave:
		synth.synth.define_sample(wave_ix+SONGL.MIN_CUSTOM_WAVE,wave.loop_start,wave.loop_end,
				wave.record_freq,wave.sample_freq,wave.data.duplicate())

func sync_waves(synth:Synth,_from:int)->void:
	if synth==null:
		return
	var wave_ix:int=0
	for wave in wave_list:
		if wave is SynthWave:
			synth.synth.define_wave(wave_ix+SONGL.MIN_CUSTOM_WAVE,wave.data.duplicate())
		elif wave is SampleWave:
			synth.synth.define_sample(wave_ix+SONGL.MIN_CUSTOM_WAVE,wave.loop_start,wave.loop_end,
					wave.record_freq,wave.sample_freq,wave.data.duplicate())
		wave_ix+=1
	var null_wave:Array=[]
	while wave_ix<SONGL.MAX_WAVES:
		synth.synth.define_wave(wave_ix+SONGL.MIN_CUSTOM_WAVE,null_wave)
		wave_ix+=1

#

func sync_lfos(synth:Synth)->void:
	for i in range(lfo_frequencies.size()):
		synth.set_lfo_frequency(i,lfo_frequencies[i])
		synth.set_lfo_wave(i,lfo_waves[i])
		synth.set_lfo_duty_cycle(i,lfo_duty_cycles[i])

#

func add_instrument(instr:Instrument)->void:
	if can_add_instrument() and instrument_list.find(instr)==-1:
		instrument_list.append(instr)
		emit_signal("instrument_list_changed")

func delete_instrument(instr:Instrument)->void:
	if not can_delete_instrument(instr):
		return
	var iix:int=instrument_list.find(instr)
	instrument_list.erase(instr)
	for chan in pattern_list:
		for pat in chan:
			for note in pat.notes:
				if note[Pattern.ATTRS.INSTR]!=null and note[Pattern.ATTRS.INSTR]>iix:
					note[Pattern.ATTRS.INSTR]-=1
	emit_signal("instrument_list_changed")
	emit_signal("order_changed",-1,-1)

func can_add_instrument()->bool:
	if instrument_list.size()<SONGL.MAX_INSTRUMENTS:
		return true
	emit_signal("error",tr("ERR_SONG_MAX_INSTRUMENTS").format({"i_max_instrs":SONGL.MAX_INSTRUMENTS}))
	return false

func can_delete_instrument(instr:Instrument)->bool:
	if instrument_list.size()==1:
		emit_signal("error",tr("ERR_SONG_MIN_INSTRUMENTS"))
		return false
	var iix:int=instrument_list.find(instr)
	if iix==-1:
		emit_signal("error",tr("ERR_SONG_INSTRUMENT_NOT_FOUND"))
		return false
	for chan in range(pattern_list.size()):
		for pat in range(pattern_list[chan].size()):
			for note in range(pattern_list[chan][pat].notes.size()):
				if pattern_list[chan][pat].notes[note][Pattern.ATTRS.INSTR]==iix:
					emit_signal("error",
						tr("ERR_SONG_INSTRUMENT_IN_SONG").format({"i_pattern":pat,"i_channel":chan,"i_row":note})
					)
					return false
	return true

func get_instrument(index:int)->Instrument:
	if index<0 or index>=instrument_list.size():
		return null
	return instrument_list[index]

func find_instrument(inst:Instrument)->int:
	return instrument_list.find(inst)

#

func add_arp(arp:Arpeggio)->void:
	if can_add_arp():
		if arp_list.find(arp)==-1:
			arp_list.append(arp)
			emit_signal("arp_list_changed")
	else:
		emit_signal("error",tr("ERR_SONG_MAX_ARPS").format({"i_max_arps":SONGL.MAX_ARPEGGIOS}))


func delete_arp(arp:Arpeggio)->void:
	if not can_delete_arp(arp):
		return
	var iix:int=arp_list.find(arp)
	arp_list.erase(arp)
	for chan in pattern_list:
		for pat in chan:
			for note in pat.notes:
				for fx in range(Pattern.ATTRS.FX0,Pattern.ATTRS.MAX,3):
					var fc=note[fx]
					var fv=note[fx+2]
					if (fc==FMVC.FX_ARP_SET and fv>iix):
						note[fx+2]=fv-1
					elif (fc==FMVC.FX_ARPEGGIO and (fv&0xF)>iix):
						note[fx+2]=(fv&0xF0)|((fv&0xF)-1)
	emit_signal("arp_list_changed")
	emit_signal("order_changed",-1,-1)

func can_add_arp()->bool:
	if arp_list.size()<SONGL.MAX_ARPEGGIOS:
		return true
	return false

func can_delete_arp(arp:Arpeggio)->bool:
	if arp_list.empty():
		return false
	var iix:int=arp_list.find(arp)
	if iix==-1:
		emit_signal("error",tr("ERR_SONG_ARP_NOT_FOUND"))
		return false
	for chan in pattern_list.size():
		for pat in pattern_list[chan].size():
			for note in pattern_list[chan][pat].notes.size():
				for fx in range(Pattern.ATTRS.FX0,Pattern.ATTRS.MAX,3):
					var fc=pattern_list[chan][pat].notes[note][fx]
					var fv=pattern_list[chan][pat].notes[note][fx+2]
					if (fc==FMVC.FX_ARP_SET and fv==iix) or (fc==FMVC.FX_ARPEGGIO and (fv&0xF)==iix):
						emit_signal("error",
							tr("ERR_SONG_ARP_IN_SONG").format({"i_pattern":pat,"i_channel":chan,"i_row":note})
						)
						return false
	return true

func get_arp(index:int)->Arpeggio:
	if index<0 or index>=arp_list.size():
		return null
	return arp_list[index]

func find_arp(arp:Arpeggio)->int:
	return arp_list.find(arp)

#

func set_note(order:int,channel:int,row:int,attr:int,value)->void:
	pattern_list[channel][orders[order][channel]].notes[row][attr]=value

func get_note(order:int,channel:int,row:int,attr:int)->int:
	return pattern_list[channel][orders[order][channel]].notes[row][attr]

func swap_notes(order:int,channel:int,row:int,dir:int)->void:
	var next:int=row+dir
	if next<0 or next>=pattern_length:
		return
	var rows:Array=pattern_list[channel][orders[order][channel]].notes
	var t:Array=rows[row]
	rows[row]=rows[next]
	rows[next]=t

#

func set_title(t:String)->void:
	title=t

func set_author(t:String)->void:
	author=t

func set_num_channels(n:int)->void:
	num_channels=clamp(n,SONGL.MIN_CHANNELS,SONGL.MAX_CHANNELS)
	emit_signal("channels_changed")

func set_pattern_length(l:int)->void:
	var ol:int=pattern_length
	pattern_length=clamp(l,SONGL.MIN_PAT_LENGTH,SONGL.MAX_PAT_LENGTH)
	if ol!=pattern_length:
		emit_signal("channels_changed")

func set_ticks_second(ts:int)->void:
	ticks_second=ts
	emit_signal("speed_changed")

func set_ticks_row(tr:int)->void:
	ticks_row=tr
	emit_signal("speed_changed")

#

func mod_fx_channel(chan:int,add:int)->void:
	var o:int=num_fxs[chan]
	num_fxs[chan]=clamp(num_fxs[chan]+add,SONGL.MIN_FX_LENGTH,SONGL.MAX_FX_LENGTH)
	if num_fxs[chan]!=o:
		emit_signal("channels_changed")

#

func get_order_pattern(order:int,channel:int)->Pattern:
	return pattern_list[channel][orders[order][channel]]
	
func get_pattern(index:int,channel:int)->Pattern:
	return pattern_list[channel][index]

func set_pattern(order:int,channel:int,pattern:int)->void:
	if pattern>-1 and pattern<pattern_list[channel].size():
		if pattern!=orders[order][channel]:
			orders[order][channel]=pattern
			emit_signal("order_changed",order,channel)

func add_pattern(channel:int,copy_from:int=-1)->int:
	if pattern_list[channel].size()>=255:
		return 255
	if copy_from==-1:
		pattern_list[channel].append(Pattern.new())
	else:
		pattern_list[channel].append(pattern_list[channel][copy_from].duplicate())
	return pattern_list[channel].size()-1

func swap_pattern(order_from:int,order_to:int,channel_from:int,channel_to:int)->void:
	if order_from<0 or order_to<0 or channel_from<0 or channel_to<0\
			or order_from>=orders.size() or order_to>=orders.size()\
			or channel_from>=num_channels or channel_to>=num_channels:
		return
	var of:int=orders[order_from][channel_from]
	var ot:int=orders[order_to][channel_to]
	var pats:Array=[pattern_list[channel_from][of],pattern_list[channel_to][ot]]
	pattern_list[channel_from][of]=pats[1]
	pattern_list[channel_to][ot]=pats[0]
	emit_signal("order_changed",order_from,channel_from)
	emit_signal("order_changed",order_to,channel_to)

#

func add_order(copy_from:int=-1)->void:
	if orders.size()>=255:
		return
	var no:Array=[]
	no.resize(SONGL.MAX_CHANNELS)
	if copy_from<0:
		for i in SONGL.MAX_CHANNELS:
			no[i]=0
	else:
		for i in SONGL.MAX_CHANNELS:
			no[i]=orders[copy_from][i]
	orders.append(no)
	emit_signal("order_changed",orders.size()-1,-1)

func delete_order(order:int)->void:
	if orders.size()<2:
		return
	orders.remove(order)
	emit_signal("order_changed",order,-1)

func swap_orders(o0:int,o1:int)->void:
	var t:Array=orders[o0]
	orders[o0]=orders[o1]
	orders[o1]=t
	emit_signal("order_changed",o0,-1)

func delete_row(order:int,channel:int,row:int)->void:
	pattern_list[channel][orders[order][channel]].remove_row(row)
	emit_signal("order_changed",order,channel)

func insert_row(order:int,channel:int,row:int)->void:
	pattern_list[channel][orders[order][channel]].insert_row(row)
	emit_signal("order_changed",order,channel)

func clean_patterns()->void:
	# Capture used patterns and set an array of translations old->new
	var pats_xform:Array=[]
	for chan in range(num_channels):
		var pats_chan:Array=[]
		var npat:int=0
		for pat in range(pattern_list[chan].size()):
			var found:bool=false
			for ordr in orders:
				if ordr[chan]==pat:
					found=true
					break
			if found:
				pats_chan.append(npat)
				npat+=1
			else:
				pats_chan.append(null)
		pats_xform.append(pats_chan)
	# Scan the pattern list and translate old->new
	for chan in range(num_channels):
		var newp
		for oldp in range(pats_xform[chan].size()):
			newp=pats_xform[chan][oldp]
			if newp!=null and oldp!=newp:
				for order in orders:
					if order[chan]==oldp:
						order[chan]=newp
		# Create a new list from used
		var npl:Array=[]
		for oldp in range(pats_xform[chan].size()):
			if pats_xform[chan][oldp]!=null:
				npl.append(pattern_list[chan][oldp])
		pattern_list[chan]=npl
	# Cleanup unused channels BREAKS
	for i in range(num_channels,SONGL.MAX_CHANNELS):
		pattern_list[i]=[Pattern.new()]
		num_fxs[i]=1
		for order in orders:
			order[i]=0
	emit_signal("order_changed",-1,-1)

func clean_instruments()->void:
	var inst_xform:Array=[]
	inst_xform.resize(instrument_list.size())
	# Capture used instruments and set an array of translations old->new
	var ninst:int=0
	for chan in pattern_list:
		for pat in chan:
			for note in pat.notes:
				var n=note[Pattern.ATTRS.INSTR]
				if n==null:
					continue
				if inst_xform[n]==null:
					inst_xform[n]=ninst
					ninst+=1
	if ninst==0:
		instrument_list.resize(1)
		emit_signal("instrument_list_changed")
		return
	inst_xform.sort()
	# Scan the patterns to change old->new
	for chan in pattern_list:
		for pat in chan:
			for note in range(pat.notes.size()):
				var n=pat.notes[note][Pattern.ATTRS.INSTR]
				if n==null:
					continue
				pat.notes[note][Pattern.ATTRS.INSTR]=inst_xform[n]
	# Make new list from used
	var ins_list:Array=[]
	for inst in range(inst_xform.size()):
		if inst_xform[inst]!=null:
			ins_list.append(instrument_list[inst])
	instrument_list=ins_list
	emit_signal("instrument_list_changed")
	emit_signal("order_changed",-1,-1)

func clean_waveforms()->void:
	var wave_xform:Array=[0,1,2,3]
	wave_xform.resize(wave_list.size()+SONGL.MIN_CUSTOM_WAVE)
	var nwave:int=SONGL.MIN_CUSTOM_WAVE
	# Set the array of transformations old->new
	## Capture waves used in LFOs
	for lfw in lfo_waves:
		if lfw<SONGL.MIN_CUSTOM_WAVE:
			continue
		if wave_xform[lfw]==null:
			wave_xform[lfw]=nwave
			nwave+=1
	## Capture waves used in instruments
	for inst in instrument_list:
		if inst is FmInstrument:
			for wi in inst.waveforms:
				if wi<SONGL.MIN_CUSTOM_WAVE:
					continue
				if wave_xform[wi]==null:
					wave_xform[wi]=nwave
					nwave+=1
			for macro in inst.wave_macros:
				for wi in macro.values:
					if wi<ParamMacro.PASSTHROUGH:
						if wave_xform[wi]==null:
							wave_xform[wi]=nwave
							nwave+=1
	## Capture waves used in pattern commands
	var cmd
	var val
	var last_cmd:Array=[]
	last_cmd.resize(Pattern.ATTRS.MAX)
	for chan in pattern_list:
		for pat in chan:
			last_cmd.fill(null)
			for note in range(pat.notes.size()):
				for fxi in range(Pattern.ATTRS.FX0,Pattern.MAX_ATTR,3):
					if pat.notes[note][fxi]==null and pat.notes[note][fxi+2]==null:
						continue
					last_cmd[fxi]=pat.notes[note][fxi] if pat.notes[note][fxi]!=null else last_cmd[fxi]
					cmd=last_cmd[fxi]
					val=pat.notes[note][fxi+2]
					if (cmd!=FMVC.FX_WAVE_SET and cmd!=FMVC.FX_LFO_WAVE_SET)\
							or val==null or val<SONGL.MIN_CUSTOM_WAVE:
						continue
					if wave_xform[val]==null:
						wave_xform[val]=nwave
						nwave+=1
	if nwave==SONGL.MIN_CUSTOM_WAVE:
		wave_list.clear()
		emit_signal("wave_list_changed")
		return
	# Scan the patterns to change old->new
	for chan in pattern_list:
		for pat in chan:
			last_cmd.fill(null)
			for note in range(pat.notes.size()):
				for fxi in range(Pattern.ATTRS.FX0,Pattern.MAX_ATTR,3):
					if pat.notes[note][fxi]==null and pat.notes[note][fxi+2]==null:
						continue
					last_cmd[fxi]=pat.notes[note][fxi] if pat.notes[note][fxi]!=null else last_cmd[fxi]
					cmd=last_cmd[fxi]
					val=pat.notes[note][fxi+2]
					if (cmd!=FMVC.FX_WAVE_SET and cmd!=FMVC.FX_LFO_WAVE_SET)\
							or val==null or val<SONGL.MIN_CUSTOM_WAVE:
						continue
					pat.notes[note][fxi+2]=wave_xform[val]
	# Scan the instruments to change old->new
	for inst in instrument_list:
		if inst is FmInstrument:
			for wi in 4:
				inst.waveforms[wi]=wave_xform[inst.waveforms[wi]]
	# Make new list from used
	var w_list:Array=[]
	for wi in range(SONGL.MIN_CUSTOM_WAVE,wave_xform.size()):
		if wave_xform[wi]!=null:
			w_list.append(wave_list[wi-SONGL.MIN_CUSTOM_WAVE])
	wave_list=w_list
	emit_signal("wave_list_changed")
	emit_signal("instrument_list_changed")
	emit_signal("order_changed",-1,-1)

func clean_arps()->void:
	var arp_xform:Array=[]
	var narp:int=0
	arp_xform.resize(arp_list.size())
	## Capture arpeggios used in pattern commands
	var cmd
	var val
	var last_cmd:Array=[]
	last_cmd.resize(Pattern.ATTRS.MAX)
	for chan in pattern_list:
		for pat in chan:
			last_cmd.fill(null)
			for note in range(pat.notes.size()):
				for fxi in range(Pattern.ATTRS.FX0,Pattern.MAX_ATTR,3):
					if pat.notes[note][fxi]==null and pat.notes[note][fxi+2]==null:
						continue
					last_cmd[fxi]=pat.notes[note][fxi] if pat.notes[note][fxi]!=null else last_cmd[fxi]
					cmd=last_cmd[fxi]
					val=pat.notes[note][fxi+2]
					if cmd==FMVC.FX_ARPEGGIO:
						val=val&0xF if val!=null else null
					elif cmd==FMVC.FX_ARP_SET:
						val=pat.notes[note][fxi+2]
					else:
						continue
					if val!=null and arp_xform[val]==null:
						arp_xform[val]=narp
						narp+=1
	if not arp_xform.empty():
		# Keep arps 0-15 in the range 0-15, to not break fast arps
		for i in min(16,arp_xform.size()):
			if arp_xform[i]!=null and arp_xform[i]>15:
				for j in range(i+1,narp):
					if arp_xform[j]!=null and arp_xform[j]<16:
						var t:int=arp_xform[i]
						arp_xform[i]=arp_xform[j]
						arp_xform[j]=t
						break
		# Scan the patterns to change old->new
		for chan in pattern_list:
			for pat in chan:
				last_cmd.fill(null)
				for note in range(pat.notes.size()):
					for fxi in range(Pattern.ATTRS.FX0,Pattern.MAX_ATTR,3):
						if pat.notes[note][fxi]==null and pat.notes[note][fxi+2]==null:
							continue
						last_cmd[fxi]=pat.notes[note][fxi] if pat.notes[note][fxi]!=null else last_cmd[fxi]
						cmd=last_cmd[fxi]
						val=pat.notes[note][fxi+2]
						if cmd==FMVC.FX_ARPEGGIO:
							pat.notes[note][fxi+2]=(val&0xF0)|arp_xform[val&0xF]
						elif cmd==FMVC.FX_ARP_SET:
							pat.notes[note][fxi+2]=arp_xform[val]
	# Make new list from used
	var narp_list:Array=[]
	narp_list.resize(narp)
	for i in arp_xform.size():
		if arp_xform[i]!=null:
			narp_list[arp_xform[i]]=arp_list[i]
	arp_list=narp_list
	emit_signal("arp_list_changed")
	emit_signal("order_changed",-1,-1)
