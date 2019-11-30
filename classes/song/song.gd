extends Reference
class_name Song

signal wave_changed(wave,wave_ix)
signal wave_list_changed
signal instrument_list_changed
signal channels_changed
signal order_changed(order_ix,channel_ix)
signal error(message)


const FMVC=preload("res://classes/tracker/fm_voice_constants.gd")
const WAVE=FmInstrument.WAVE
const MIN_CHANNELS:int=1
const MAX_CHANNELS:int=32
const MIN_PAT_LENGTH:int=16
const MAX_PAT_LENGTH:int=128
const DFL_PAT_LENGTH:int=64
const MIN_FX_LENGTH:int=0
const MAX_FX_LENGTH:int=4
const DFL_FX_LENGTH:int=1
const MIN_CUSTOM_WAVE:int=4
const MAX_WAVES:int=256-MIN_CUSTOM_WAVE
const MAX_INSTRUMENTS:int=256
const FILE_SIGNATURE:String="SFMM\u000d\u000a\u001a\u000a"
const CHUNK_HEADER:String="MHDR"
const CHUNK_CHANNELS:String="CHAL"
const CHANNEL_FM4:String="CFM4"
const CHUNK_INSTRUMENTS:String="INSL"
const CHUNK_WAVES:String="WAVL"
const CHUNK_ORDERS:String="ORDL"
const CHUNK_pattern_list:String="PATL"


var title:String="Untitled"
var author:String=""
var pattern_list:Array # [channel,order]
var orders:Array # [row,channel]
var wave_list:Array
var instrument_list:Array
var num_channels:int
var num_fxs:Array
var pattern_length:int
var ticks_second:int
var ticks_row:int
var lfo_frequencies:Array=[4.0,2.0,1.0,0.5]
var lfo_waves:Array=[WAVE.TRIANGLE,WAVE.SAW,WAVE.RECTANGLE,WAVE.NOISE]
var lfo_duty_cycles:Array=[0,0,128,0]


func _init(max_channels:int=MAX_CHANNELS,pat_length:int=DFL_PAT_LENGTH,fx_length:int=1,tks_sec:int=50,tks_row:int=6)->void:
	num_channels=clamp(max_channels,MIN_CHANNELS,MAX_CHANNELS)
	pattern_length=clamp(pat_length,MIN_PAT_LENGTH,MAX_PAT_LENGTH)
	ticks_second=max(tks_sec,1.0)
	ticks_row=max(tks_row,1.0)
	var nfx:int=clamp(fx_length,MIN_FX_LENGTH,MAX_FX_LENGTH)
	pattern_list=[]
	pattern_list.resize(num_channels)
	orders=[[]]
	orders[0].resize(num_channels)
	num_fxs.resize(num_channels)
	for i in range(num_channels):
		pattern_list[i]=[Pattern.new(MAX_PAT_LENGTH)]
		orders[0][i]=0
		num_fxs[i]=nfx
	instrument_list.append(FmInstrument.new())
	instrument_list[0].name+=" 00"
	wave_list=[]
	emit_signal("wave_list_changed")
	emit_signal("instrument_list_changed")
	emit_signal("channels_changed")

#

# warning-ignore:unused_argument
func _on_wave_name_changed(wave:Waveform,name:String)->void:
	var ix:int=wave_list.find(wave)
	if ix!=-1:
		emit_signal("wave_changed",wave,ix)

func add_wave(wave:Waveform)->void:
	if can_add_wave() and wave_list.find(wave)==-1:
		wave_list.append(wave)
		wave.connect("name_changed",self,"_on_wave_name_changed")
		emit_signal("wave_list_changed")

func delete_wave(wave:Waveform)->void:
	if can_delete_wave(wave):
		var ix:int=wave_list.find(wave)
		for inst in instrument_list:
			inst.delete_waveform(ix)
		wave_list.erase(wave)
		emit_signal("wave_list_changed")
		emit_signal("instrument_list_changed")

func can_add_wave()->bool:
	if wave_list.size()<MAX_WAVES:
		return true
	emit_signal("error","Limit of %d waveforms reached."%[MAX_WAVES])
	return false

func can_delete_wave(wave:Waveform)->bool:
	var wave_ix:int=wave_list.find(wave)
	if wave_ix==-1:
		emit_signal("error","Wave not found.")
		return false
	for lw in range(lfo_waves.size()):
		if (lfo_waves[lw]-MIN_CUSTOM_WAVE)==wave_ix:
			emit_signal("error","Wave is in use by LFO %d."%[lw])
			return false
	for ins in range(instrument_list.size()):
		if !(instrument_list[ins] is FmInstrument):
			continue
		for w in range(instrument_list[ins].waveforms.size()):
			if (instrument_list[ins].waveforms[w]-MIN_CUSTOM_WAVE)==wave_ix:
				emit_signal("error","Wave is in use by instrument %d operator %d."%[ins,w])
				return false
	wave_ix+=MIN_CUSTOM_WAVE
	for chan in range(pattern_list.size()):
		for pat in range(pattern_list[chan].size()):
			for note in range(pattern_list[chan][pat].notes.size()):
				for col in range(Pattern.MIN_FX_COL,Pattern.MAX_ATTR,3):
					var cmd=pattern_list[chan][pat].notes[note][col]
					if cmd!=FMVC.FX_WAVE_SET and cmd!=FMVC.FX_LFO_WAVE_SET:
						continue
					if pattern_list[chan][pat].notes[note][col+2]==wave_ix:
						emit_signal("error","Wave is in use on pattern %d of channel %d, row %d."%[pat,chan,note])
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
	if wave_ix!=-1:
		synth.synth.set_wave(wave_ix+MIN_CUSTOM_WAVE,wave.data)

func sync_waves(synth:Synth,from:int=MIN_CUSTOM_WAVE)->void:
	if synth==null:
		return
	var wave_ix:int=from
	for wave in wave_list:
		synth.synth.set_wave(wave_ix,wave.data)
		wave_ix+=1
	var null_wave:PoolRealArray=PoolRealArray()
	while wave_ix<256:
		synth.synth.set_wave(wave_ix,null_wave)
		wave_ix+=1

#

func add_instrument(instr:Instrument)->void:
	if can_add_instrument() and instrument_list.find(instr)==-1:
		instrument_list.append(instr)
		emit_signal("instrument_list_changed")

func delete_instrument(instr:Instrument)->void:
	if can_delete_instrument(instr):
		instrument_list.erase(instr)
		emit_signal("instrument_list_changed")

func can_add_instrument()->bool:
	if instrument_list.size()<MAX_INSTRUMENTS:
		return true
	emit_signal("error","Limit of %d instruments reached."%[MAX_INSTRUMENTS])
	return false

func can_delete_instrument(instr:Instrument)->bool:
	if instrument_list.size()==1:
		emit_signal("error","Need at least one instrument.")
		return false
	var iix:int=instrument_list.find(instr)
	if iix==-1:
		emit_signal("error","Instrument not found.")
		return false
	for chan in range(pattern_list.size()):
		for pat in range(pattern_list[chan].size()):
			for note in range(pattern_list[chan][pat].notes.size()):
				if pattern_list[chan][pat].notes[note][Pattern.ATTRS.INSTR]==iix:
					emit_signal("error","Instrument is in use on pattern %d of channel %d, row %d."%[pat,chan,note])
					return false
	return true

func get_instrument(index:int)->Instrument:
	if index<0 or index>=instrument_list.size():
		return null
	return instrument_list[index]

func find_instrument(inst:Instrument)->int:
	return instrument_list.find(inst)

#

func set_note(order:int,channel:int,row:int,attr:int,value)->void:
	pattern_list[channel][orders[order][channel]].notes[row][attr]=value

func get_note(order:int,channel:int,row:int,attr:int)->int:
	return pattern_list[channel][orders[order][channel]].notes[row][attr]

#

func set_title(t:String)->void:
	title=t

func set_author(t:String)->void:
	author=t

func set_num_channels(n:int)->void:
	num_channels=clamp(n,MIN_CHANNELS,MAX_CHANNELS)
	emit_signal("channels_changed")

func set_pattern_length(l:int)->void:
	var ol:int=pattern_length
	pattern_length=clamp(l,MIN_PAT_LENGTH,MAX_PAT_LENGTH)
	if ol!=pattern_length:
		emit_signal("channels_changed")

func set_ticks_second(ts:int)->void:
	ticks_second=ts

func set_ticks_row(tr:int)->void:
	ticks_row=tr

#

func mod_fx_channel(chan:int,add:int)->void:
	var o:int=num_fxs[chan]
	num_fxs[chan]=clamp(num_fxs[chan]+add,MIN_FX_LENGTH,MAX_FX_LENGTH)
	if num_fxs[chan]!=o:
		emit_signal("channels_changed")

#

func get_order_pattern(order:int,channel:int)->Pattern:
	return pattern_list[channel][orders[order][channel]]
	
func get_pattern(index:int,channel:int)->Pattern:
	return pattern_list[channel][index]

func set_pattern(order:int,channel:int,pattern:int)->void:
	if pattern>-1 and pattern<pattern_list[channel].size():
		orders[order][channel]=pattern
		emit_signal("order_changed",order,channel)

func add_pattern(channel:int,copy_from:int=-1)->int:
	if pattern_list[channel].size()>=255:
		return 255
	if copy_from==-1:
		pattern_list[channel].append(Pattern.new(MAX_PAT_LENGTH))
	else:
		pattern_list[channel].append(pattern_list[channel][copy_from].duplicate())
	return pattern_list[channel].size()-1

#

func add_order(copy_from:int=-1)->void:
	if orders.size()>=255:
		return
	var no:Array=[]
	no.resize(num_channels)
	if copy_from<0:
		for i in range(num_channels):
			no[i]=0
	else:
		for i in range(num_channels):
			no[i]=orders[copy_from][i]
	orders.append(no)
	emit_signal("order_changed",orders.size()-1,-1)

func delete_order(order:int)->void:
	if orders.size()<2:
		return
	orders.remove(order)
	emit_signal("order_changed",order,-1)

func delete_row(order:int,channel:int,row:int)->void:
	pattern_list[channel][orders[order][channel]].remove_row(row)
	emit_signal("order_changed",order,channel)

func insert_row(order:int,channel:int,row:int)->void:
	pattern_list[channel][orders[order][channel]].insert_row(row)
	emit_signal("order_changed",order,channel)

#

func serialize(out:ChunkedFile)->void:
	# Signature: SFMM\0xc\0xa\0x1a\0xa
	out.store_string(FILE_SIGNATURE)
	# Header
	out.start_chunk(CHUNK_HEADER)
	out.store_16(pattern_length)
	out.store_16(ticks_second)
	out.store_16(ticks_row)
	out.store_pascal_string(title)
	out.store_pascal_string(author)
	out.end_chunk()
	# Channels
	out.start_chunk(CHUNK_CHANNELS)
	out.store_16(num_channels)
	for i in range(num_channels):
		out.store_string(CHANNEL_FM4)
		out.store_8(num_fxs[i])
	out.end_chunk()
	# Instruments
	out.start_chunk(CHUNK_INSTRUMENTS)
	for i in range(4):
		out.store_16(lfo_frequencies[i]*256.0)
		out.store_8(lfo_waves[i])
		out.store_8(lfo_duty_cycles[i])
	out.store_16(instrument_list.size())
	for inst in instrument_list:
		inst.serialize(out)
	# Waveforms
	out.start_chunk(CHUNK_WAVES)
	out.store_16(wave_list.size())
	for wave in wave_list:
		wave.serialize(out)
	out.end_chunk()
	out.end_chunk()
	# Orders
	out.start_chunk(CHUNK_ORDERS)
	out.store_16(orders.size())
	for ordr in orders:
		for chn in range(num_channels):
			out.store_8(ordr[chn])
	out.end_chunk()
	# pattern_list
	out.start_chunk(CHUNK_pattern_list)
	for i in range(num_channels):
		var chn:Pattern=pattern_list[i]
		out.store_16(chn.size())
		for pat in chn:
			pat.serialize(out,pattern_length,num_fxs[i])

#

func deserialize(inf:ChunkedFile)->Song:
	var song:Song=get_script().new()
	# Signature
	var sig:String=inf.get_ascii(8)
	if sig!=FILE_SIGNATURE:
		return null
	# Header
	var hdr:Dictionary=inf.get_chunk_header()
	if hdr[ChunkedFile.CHUNK_ID]!=CHUNK_HEADER:
		return null
	song.pattern_length=inf.get_16()
	song.ticks_second=inf.get_16()
	song.ticks_row=inf.get_16()
	song.title=inf.get_pascal_string()
	song.author=inf.get_pascal_string()
	inf.skip_chunk(hdr)
	# Chunks
	var mandatory_CHAL:bool=false
	while true:
		hdr=inf.get_chunk_header()
		if inf.eof_reached():
			break
		match hdr[ChunkedFile.CHUNK_ID]:
			CHUNK_CHANNELS:
				process_channel_list(inf,song)
				mandatory_CHAL=true
			CHUNK_INSTRUMENTS:
				process_instrument_list(inf,song)
			CHUNK_ORDERS:
				process_order_list(inf,song)
			CHUNK_pattern_list:
				process_pattern_list(inf,song)
			_:
				print("Unrecognized chunk [%s]"%[hdr[ChunkedFile.CHUNK_ID]])
		inf.skip_chunk(hdr)
	if !mandatory_CHAL:
		return null
	return song

func process_pattern_list(inf:ChunkedFile,song:Song)->void:
	var pat_l:Array=[]
	pat_l.resize(song.num_channels)
	for i in range(song.num_channels):
		pat_l[i]=[]
		pat_l[i].resize(inf.get_16())
		for j in range(pat_l[i].size()):
			var n:Pattern=Pattern.new(MAX_PAT_LENGTH)
			n.deserialize(inf,n,song.pattern_length)
			pat_l[i][j]=n
	song.pattern_list=pat_l

func process_order_list(inf:ChunkedFile,song:Song)->void:
	var ord_l:Array=[]
	ord_l.resize(inf.get_16())
	for i in range(ord_l.size()):
		ord_l[i]=[]
		ord_l[i].resize(song.num_channels)
		for j in range(song.num_channels):
			ord_l[i][j]=inf.get_8()
	song.orders=ord_l

func process_instrument_list(inf:ChunkedFile,song:Song)->void:
	var hdr:Dictionary
	var inst_l:Array=[]
	for i in range(4):
		song.lfo_frequencies[i]=inf.get_16()/256.0
		song.lfo_waves[i]=inf.get_8()
		song.lfo_duty_cycles[i]=inf.get_8()
	inst_l.resize(inf.get_16())
	for i in range(inst_l.size()):
		hdr=inf.get_chunk_header()
		match hdr[ChunkedFile.CHUNK_ID]:
			FmInstrument.CHUNK_ID:
				var n:FmInstrument=FmInstrument.new()
				n.deserialize(inf,n)
				inst_l[i]=n
			_:
				print("Unrecognized chunk [%s]"%[hdr[ChunkedFile.CHUNK_ID]])
		inf.skip_chunk(hdr)
	hdr=inf.get_chunk_header()
	if hdr[ChunkedFile.CHUNK_ID]!=CHUNK_WAVES:
		return
	var wav_l:Array=[]
	wav_l.resize(inf.get_16())
	for i in range(wav_l.size()):
		hdr=inf.get_chunk_header()
		match hdr[ChunkedFile.CHUNK_ID]:
			SynthWave.CHUNK_ID:
				var n:SynthWave=SynthWave.new()
				n.deserialize(inf,n)
				wav_l[i]=n
			_:
				print("Unrecognized chunk [%s]"%[hdr[ChunkedFile.CHUNK_ID]])
		inf.skip_chunk(hdr)
	song.instrument_list=inst_l
	song.wave_list=wav_l

func process_channel_list(inf:ChunkedFile,song:Song)->void:
	var nc:int=inf.get_16()
	song.num_channels=nc
	song.pattern_list.resize(nc)
	song.orders[0].resize(nc)
	song.num_fxs.resize(nc)
	for i in range(nc):
		inf.get_ascii(4) # Unused
		var nfx:int=inf.get_8()
		pattern_list[i]=[]
		orders[0][i]=0
		num_fxs[i]=nfx

#

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
	# Scan the pattern list and translate old->new or remove unused
	for chan in range(num_channels):
		var newp
		for oldp in range(pats_xform[chan].size()):
			newp=pats_xform[chan][oldp]
			if newp!=null and oldp!=newp:
				for order in orders:
					if order[chan]==oldp:
						order[chan]=newp
		for oldp in range(pats_xform[chan].size()-1,-1,-1):
			newp=pats_xform[chan][oldp]
			if newp==null:
				pattern_list[chan].remove(oldp)
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
	# Scan the patterns to change old->new
	for chan in pattern_list:
		for pat in chan:
			for note in range(pat.notes.size()):
				var n=pat.notes[note][Pattern.ATTRS.INSTR]
				if n==null:
					continue
				pat.notes[note][Pattern.ATTRS.INSTR]=inst_xform[n]
	# Remove unused instruments (this changes instrument order)
	for inst in range(inst_xform.size()-1,-1,-1):
		if inst_xform[inst]==null:
			instrument_list.remove(inst)
	emit_signal("instrument_list_changed")
	emit_signal("order_changed",-1,-1)

func clean_waveforms()->void:
	var wave_xform:Array=[0,1,2,3]
	wave_xform.resize(wave_list.size()+MIN_CUSTOM_WAVE)
	var nwave:int=MIN_CUSTOM_WAVE
	# Set the array of transformations old->new
	## Capture waves used in instruments
	for inst in instrument_list:
		if inst is FmInstrument:
			for wi in inst.waveforms:
				if wi<MIN_CUSTOM_WAVE:
					continue
				if wave_xform[wi]==null:
					wave_xform[wi]=nwave
					nwave+=1
	## Capture waves used in pattern commands
	for chan in pattern_list:
		for pat in chan:
			for note in range(pat.notes.size()):
				for fxi in range(Pattern.ATTRS.FX0,Pattern.MAX_ATTR,3):
					var cmd=pat.notes[note][fxi]
					var val=pat.notes[note][fxi+2]
					if (cmd!=FMVC.FX_WAVE_SET and cmd!=FMVC.FX_LFO_WAVE_SET)\
							|| val==null || val<MIN_CUSTOM_WAVE:
						continue
					if wave_xform[val]==null:
						wave_xform[val]=nwave
						nwave+=1
	if nwave==MIN_CUSTOM_WAVE:
		wave_list.clear()
		emit_signal("wave_list_changed")
		return
	# Scan the patterns to change old->new
	for chan in pattern_list:
		for pat in chan:
			for note in range(pat.notes.size()):
				for fxi in range(Pattern.ATTRS.FX0,Pattern.MAX_ATTR,3):
					var cmd=pat.notes[note][fxi]
					var val=pat.notes[note][fxi+2]
					if (cmd!=FMVC.FX_WAVE_SET and cmd!=FMVC.FX_LFO_WAVE_SET)\
							|| val==null || val<MIN_CUSTOM_WAVE:
						continue
					pat.notes[note][fxi+2]=wave_xform[val]
	# Scan the instruments to change old->new
	print(wave_xform)
	for inst in instrument_list:
		if inst is FmInstrument:
			for wi in range(4):
				inst.waveforms[wi]=wave_xform[inst.waveforms[wi]]
	# Delete unused
	for i in range(wave_xform.size()-1,MIN_CUSTOM_WAVE-1,-1):
		if wave_xform[i]==null:
			wave_list.remove(i-MIN_CUSTOM_WAVE)
	emit_signal("wave_list_changed")
	emit_signal("instrument_list_changed")
	emit_signal("order_changed",-1,-1)
