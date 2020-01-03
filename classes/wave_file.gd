extends File
class_name WaveFile

signal error(message)

var float_samples:bool
var block_bytes:int
var data_size:int

func start_file(path:String,fp_samples:bool,sample_rate:int)->void:
	var err:int=open(path,WRITE)
	if err!=OK:
		emit_signal("error","TODO")
		return
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

func write_chunk(data:Array)->void:
	if !is_open():
		emit_signal("error","File is not open.")
		return
	for block in data:
		if float_samples:
			store_float(block.x)
			store_float(block.y)
			data_size+=8
		else:
			store_16(clamp(block.x,-1.0,1.0)*32767)
			store_16(clamp(block.y,-1.0,1.0)*32767)
			data_size+=4

func end_file()->void:
	if !is_open():
		emit_signal("error","File is not open.")
		return
	seek(4)
	store_32(36+data_size)
	seek(40)
	store_32(data_size)
