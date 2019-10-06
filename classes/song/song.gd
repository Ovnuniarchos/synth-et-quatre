extends Reference
class_name Song

signal wave_list_changed
signal instrument_list_changed
signal channels_changed
signal order_changed(order_ix,channel_ix)

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
const CHUNK_PATTERNS:String="PATL"


var title:String="Untitled"
var author:String=""
var patterns:Array # [channel,order]
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
	patterns=[]
	patterns.resize(num_channels)
	orders=[[]]
	orders[0].resize(num_channels)
	num_fxs.resize(num_channels)
	for i in range(0,num_channels):
		patterns[i]=[Pattern.new(MAX_PAT_LENGTH)]
		orders[0][i]=0
		num_fxs[i]=nfx
	instrument_list.append(FmInstrument.new())
	instrument_list[0].name+=" 00"
	wave_list=[]
	emit_signal("wave_list_changed")
	emit_signal("instrument_list_changed")
	emit_signal("channels_changed")

#

func add_wave(wave:Waveform)->void:
	if can_add_wave() and wave_list.find(wave)==-1:
		wave_list.append(wave)
		emit_signal("wave_list_changed")

func delete_wave(wave:Waveform)->void:
	if can_delete_wave(wave):
		wave_list.erase(wave)
		emit_signal("wave_list_changed")

func can_add_wave()->bool:
	return wave_list.size()<MAX_WAVES

func can_delete_wave(wave:Waveform)->bool:
	var wave_ix:int=wave_list.find(wave)
	if wave_ix==-1:
		return false
	for w in lfo_waves:
		if (w-MIN_CUSTOM_WAVE)==wave_ix:
			return false
	for ins in instrument_list:
		if !(ins is FmInstrument):
			continue
		for w in ins.waveforms:
			if (w-MIN_CUSTOM_WAVE)==wave_ix:
				return false
	# TODO: Scan patterns
	return true

func get_wave(index:int)->Waveform:
	if index<0 or index>wave_list.size():
		return null
	return wave_list[index]

func find_wave(wave:Waveform)->int:
	return wave_list.find(wave)

func find_wave_ref(wave:WeakRef)->int:
	if wave==null:
		return -1
	return wave_list.find(wave.get_ref() as Waveform)

func send_wave(wave:Waveform)->void:
	var wave_ix:int=wave_list.find(wave)
	SYNTH.synth.set_wave(wave_ix+MIN_CUSTOM_WAVE,wave.data)

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
	return instrument_list.size()<MAX_INSTRUMENTS

func can_delete_instrument(instr:Instrument)->bool:
	if instrument_list.size()==1 or instrument_list.find(instr)==-1:
		return false
	return true

func get_instrument(index:int)->Instrument:
	if index<0 or index>instrument_list.size():
		return null
	return instrument_list[index]

func find_instrument(inst:Instrument)->int:
	return instrument_list.find(inst)

#

func set_note(order:int,channel:int,row:int,attr:int,value)->void:
	patterns[channel][orders[order][channel]].notes[row][attr]=value

func get_note(order:int,channel:int,row:int,attr:int)->int:
	return patterns[channel][orders[order][channel]].notes[row][attr]

#

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
	return patterns[channel][orders[order][channel]]
	
func get_pattern(index:int,channel:int)->Pattern:
	return patterns[channel][index]

func set_pattern(order:int,channel:int,pattern:int)->void:
	if pattern>-1 and pattern<patterns[channel].size():
		orders[order][channel]=pattern
		emit_signal("order_changed",order,channel)

func add_pattern(channel:int,copy_from:int=-1)->int:
	if patterns[channel].size()>254:
		return 255
	if copy_from==-1:
		patterns[channel].append(Pattern.new(MAX_PAT_LENGTH))
	else:
		patterns[channel].append(patterns[channel][copy_from].duplicate())
	return patterns[channel].size()-1

#

func add_order(copy_from:int=-1)->void:
	if orders.size()>=255:
		return
	var no:Array=[]
	no.resize(num_channels)
	if copy_from<0:
		for i in range(0,num_channels):
			no[i]=0
	else:
		for i in range(0,num_channels):
			no[i]=orders[copy_from][i]
	orders.append(no)
	emit_signal("order_changed",orders.size()-1,-1)

func delete_order(order:int)->void:
	if orders.size()<2:
		return
	orders.remove(order)
	emit_signal("order_changed",order,-1)

func delete_row(order:int,channel:int,row:int)->void:
	patterns[channel][orders[row][channel]].remove_row(row)
	emit_signal("order_changed",order,channel)

func insert_row(order:int,channel:int,row:int)->void:
	patterns[channel][orders[row][channel]].insert_row(row)
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
		for chn in ordr:
			out.store_8(chn)
	out.end_chunk()
	# Patterns
	out.start_chunk(CHUNK_PATTERNS)
	for i in range(num_channels):
		var chn:Pattern=patterns[i]
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
			CHUNK_PATTERNS:
				process_pattern_list(inf,song)
			_:
				print("Unrecognized chunk [%s]"%[hdr[ChunkedFile.CHUNK_ID]])
				inf.seek(hdr[ChunkedFile.CHUNK_NEXT])
	if !mandatory_CHAL:
		return null
	return song

func process_pattern_list(inf:ChunkedFile,song:Song)->void:
	var pat_l:Array=[]
	pat_l.resize(song.num_channels)
	for i in range(0,song.num_channels):
		pat_l[i]=[]
		pat_l[i].resize(inf.get_16())
		for j in range(0,pat_l[i].size()):
			var n:Pattern=Pattern.new(MAX_PAT_LENGTH)
			n.deserialize(inf,n,song.pattern_length)
			pat_l[i][j]=n
	song.patterns=pat_l

func process_order_list(inf:ChunkedFile,song:Song)->void:
	var ord_l:Array=[]
	ord_l.resize(inf.get_16())
	for i in range(0,ord_l.size()):
		ord_l[i]=[]
		ord_l[i].resize(song.num_channels)
		for j in range(0,song.num_channels):
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
	for i in range(0,inst_l.size()):
		hdr=inf.get_chunk_header()
		match hdr[ChunkedFile.CHUNK_ID]:
			FmInstrument.CHUNK_ID:
				var n:FmInstrument=FmInstrument.new()
				n.deserialize(inf,n)
				inst_l[i]=n
			_:
				print("Unrecognized chunk [%s]"%[hdr[ChunkedFile.CHUNK_ID]])
				inf.seek(hdr[ChunkedFile.CHUNK_NEXT])
	hdr=inf.get_chunk_header()
	if hdr[ChunkedFile.CHUNK_ID]!=CHUNK_WAVES:
		return
	var wav_l:Array=[]
	wav_l.resize(inf.get_16())
	for i in range(0,wav_l.size()):
		hdr=inf.get_chunk_header()
		match hdr[ChunkedFile.CHUNK_ID]:
			SynthWave.CHUNK_ID:
				var n:SynthWave=SynthWave.new()
				n.deserialize(inf,n)
				wav_l[i]=n
			_:
				print("Unrecognized chunk [%s]"%[hdr[ChunkedFile.CHUNK_ID]])
				inf.seek(hdr[ChunkedFile.CHUNK_NEXT])
	song.instrument_list=inst_l
	song.wave_list=wav_l

func process_channel_list(inf:ChunkedFile,song:Song)->void:
	var nc:int=inf.get_16()
	song.num_channels=nc
	song.patterns.resize(nc)
	song.orders[0].resize(nc)
	song.num_fxs.resize(nc)
	for i in range(0,nc):
		inf.get_ascii(4) # Unused
		var nfx:int=inf.get_8()
		patterns[i]=[]
		orders[0][i]=0
		num_fxs[i]=nfx
