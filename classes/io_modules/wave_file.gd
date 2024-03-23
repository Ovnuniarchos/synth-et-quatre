extends File
class_name WaveFile

var float_samples:bool
var block_bytes:int
var data_size:int

func start_file(path:String,fp_samples:bool,sample_rate:int)->int:
	var err:int=open(path,WRITE)
	if err!=OK:
		return err
	float_samples=fp_samples
	block_bytes=2*(4 if float_samples else 2)
	store_string("RIFF")
	store_32(0)
	store_string("WAVE")
	store_string("fmt ")
	store_32(16)
	store_16(3 if float_samples else 1)
	store_16(2)
	store_32(sample_rate)
	store_32(sample_rate*block_bytes)
	store_16(block_bytes)
	store_16(32 if float_samples else 16)
	store_string("data")
	store_32(0)
	data_size=0
	err=get_error()
	if err!=OK:
		close()
		return err
	return OK

func write_chunk(data:Array)->int:
	for block in data:
		if float_samples:
			store_float(block.x)
			store_float(block.y)
			data_size+=8
		else:
			store_16(clamp(block.x,-1.0,1.0)*32767)
			store_16(clamp(block.y,-1.0,1.0)*32767)
			data_size+=4
	var err:int=get_error()
	if err!=OK:
		close()
		return err
	return OK

func write_cue_points(offsets:Array)->int:
	if offsets.empty():
		return OK
	store_string("cue ")
	store_32(4+offsets.size()*24)
	store_32(offsets.size())
	for i in range(offsets.size()):
		store_32(i)
		store_32(offsets[i])
		store_string("data")
		store_32(0)
		store_32(offsets[i]*block_bytes)
		store_32(0)
	return OK

func end_file()->int:
	seek(4)
	var err:int=get_error()
	if err!=OK:
		close()
		return err
	store_32(36+data_size)
	err=get_error()
	if err!=OK:
		close()
		return err
	seek(40)
	err=get_error()
	if err!=OK:
		close()
		return err
	store_32(data_size)
	err=get_error()
	if err!=OK:
		close()
		return err
	close()
	return OK

#

func obj_load(path:String)->Dictionary:
	var err:int=open(path,READ)
	if err!=OK:
		return {"error":err}
	var wave:Dictionary=do_load()
	close()
	return wave
	

func do_load()->Dictionary:
	if get_buffer(4).get_string_from_ascii()!="RIFF":
		return {"error":ERR_FILE_UNRECOGNIZED}
	get_32()
	if get_buffer(4).get_string_from_ascii()!="WAVE":
		return {"error":ERR_FILE_UNRECOGNIZED}
	var chunk_id:String
	var size:int
	var pos:int
	var mode:int
	var channels:int
	var frequency:int
	var bits_sample:int
	var format:bool=false
	var data:Array=[]
	while !eof_reached():
		chunk_id=get_buffer(4).get_string_from_ascii()
		size=get_32()
		pos=get_position()
		if chunk_id=="fmt ":
			mode=get_16()
			channels=get_16()
			frequency=get_32()
			get_32()
			get_16()
			bits_sample=get_16()
			if (mode!=1 and mode !=3) or (channels<1 and channels>2)\
					or !bits_sample in [8,16,24,32]:
				return {"error":0}
			format=true
		elif chunk_id=="data":
			if !format:
				return {"error":0}
			size/=channels*(bits_sample>>3)
			while size>0:
				size-=1
				if eof_reached():
					break
				if channels==1:
					data.append(get_sample(bits_sample))
				else:
					data.append((get_sample(bits_sample)+get_sample(bits_sample))/2)
		else:
			seek(pos+size)
	return {"error":OK,"bits":bits_sample,"freq":frequency,"data":data}

func get_sample(bits_sample:int):
	var t:int
	if bits_sample==8:
		return get_8()-0x80
	elif bits_sample==16:
		t=get_16()
		return t if t<0x8000 else t-0x10000
	elif bits_sample==32:
		return get_float()
	t=(get_8()<<16)|get_16()
	return t if t<0x800000 else t-0x1000000
