extends Reference
class_name WaveFileWriter


signal export_ended


const BUFFER_SIZE:int=2048


var result:FileResult


func write(path:String)->void:
	var synth:Synth=Synth.new()
	synth.set_mix_rate(CONFIG.get_value(CONFIG.RECORD_SAMPLERATE))
	var volume:float=0.0
	if CONFIG.get_value(CONFIG.RECORD_FPSAMPLES):
		volume=1.0
		if not CONFIG.get_value(CONFIG.RECORD_SAVEMUTED):
			synth.mute_voices(GLOBALS.muted_mask)
	else:
		if CONFIG.get_value(CONFIG.RECORD_SAVEMUTED):
			volume=1.0/GLOBALS.song.num_channels
		else:
			volume=1.0/synth.mute_voices(GLOBALS.muted_mask)
	GLOBALS.song.sync_waves(synth,0)
	GLOBALS.song.sync_lfos(synth)
	var thr:Thread=Thread.new()
	thr.start(self,"export_thread",{
		"synth":synth,
		"path":path,
		"thread":thr,
		"volume":volume
	})
	yield(self,"export_ended")


func export_thread(data:Dictionary)->void:
	var synth:Synth=data["synth"]
	var err_dict:Dictionary={"s_file":data["path"]}
	var tracker:Tracker=Tracker.new(synth)
	var file:WaveFile=WaveFile.new()
	var cue:File=File.new()
	var sample_rate:int=CONFIG.get_value(CONFIG.RECORD_SAMPLERATE)
	var cmds:Array=[]
	cmds.resize(65536)
	tracker.set_block_signals(true)
	PROGRESS.start()
	var buffer_pos:int=0
	var order_pos:Array=[]
	var orders:Array=[]
	var err:int=file.start_file(data["path"],CONFIG.get_value(CONFIG.RECORD_FPSAMPLES),sample_rate)
	if err!=OK:
		thread_kill(file,cue,FileResult.new(err,err_dict))
		return
	tracker.record(0)
	var play_info:Dictionary=tracker.gen_commands(GLOBALS.song,sample_rate,BUFFER_SIZE,cmds,order_pos)
	while play_info["play"]:
		if order_pos.empty():
			buffer_pos+=BUFFER_SIZE
		else:
			for op in order_pos:
				orders.append(op+buffer_pos)
			buffer_pos+=order_pos[-1]
			order_pos.clear()
		err=file.write_chunk(synth.generate(BUFFER_SIZE,cmds,data["volume"]))
		if err!=OK:
			thread_kill(file,cue,FileResult.new(err,err_dict))
			return
		PROGRESS.set_value((tracker.curr_order*100)/GLOBALS.song.orders.size())
		play_info=tracker.gen_commands(GLOBALS.song,sample_rate,BUFFER_SIZE,cmds,order_pos)
	err=file.write_cue_points(orders)
	if err!=OK:
		thread_kill(file,cue,FileResult.new(err,err_dict))
		return
	err=file.end_file()
	if err!=OK:
		thread_kill(file,cue,FileResult.new(err,err_dict))
		return
	#
	err_dict["s_file"]=data["path"].get_basename()+".cue"
	err=cue.open(err_dict["s_file"],File.WRITE)
	if err!=OK:
		thread_kill(file,cue,FileResult.new(err,err_dict))
		return
	err=store_line(cue,"FILE %s WAVE"%data["path"])
	if err!=OK:
		thread_kill(file,cue,FileResult.new(err,err_dict))
		return
	var loop:int=play_info["loop"]
	if loop!=-1 and loop<orders.size():
		if loop==0:
			err=store_line(cue,"REM Loop point: 0.000000")
		else:
			err=store_line(cue,"REM Loop point: %f"%(float(orders[loop-1])/sample_rate))
	if err!=OK:
		thread_kill(file,cue,FileResult.new(err,err_dict))
		return
	for i in range(orders.size()):
		var o:int=orders[i]
		store_line(cue,"	TRACK %d AUDIO"%(i+1))
		store_line(cue,"		TITLE Order %d"%(i+1))
		store_line(cue,"		INDEX 01 %d:%02d:%02d"%[o/(sample_rate*60),(o/sample_rate)%60,((o*75)/sample_rate)%75])
		store_line(cue,"		REM %d samples"%o)
		err=store_line(cue,"		REM %f seconds"%(float(o)/sample_rate))
		if err!=OK:
			thread_kill(file,cue,FileResult.new(err,err_dict))
			return
	cue.close()
	thread_kill(file,cue,FileResult.new())


func store_line(f:File,lin:String)->int:
	f.store_line(lin)
	return f.get_error()


func thread_kill(file:File,cue:File,res:FileResult)->void:
	result=res
	if file!=null and file.is_open():
		file.close()
	if cue!=null and cue.is_open():
		cue.close()
	PROGRESS.end()
	emit_signal("export_ended")
