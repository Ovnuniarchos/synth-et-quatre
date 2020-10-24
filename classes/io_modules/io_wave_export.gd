extends Reference
class_name IOWavExport


const BUFFER_SIZE=2048


func obj_save(path:String)->void:
		var synth:Synth=Synth.new()
		synth.set_mix_rate(CONFIG.get_value(CONFIG.RECORD_SAMPLERATE))
		if CONFIG.get_value(CONFIG.RECORD_SAVEMUTED):
			synth.mute_voices(GLOBALS.muted_mask)
		GLOBALS.song.sync_waves(synth,0)
		GLOBALS.song.sync_lfos(synth)
		var thr:Thread=Thread.new()
		thr.start(self,"export_thread",{
			"synth":synth,
			"path":path,
			"thread":thr
		})
		"""export_thread({
			"synth":synth,
			"path":path,
			"thread":null
		})"""

func export_thread(data:Dictionary)->void:
	var synth:Synth=data["synth"]
	var tracker:Tracker=Tracker.new(synth)
	var file:WaveFile=WaveFile.new()
	var sample_rate:int=CONFIG.get_value(CONFIG.RECORD_SAMPLERATE)
	var cmds:Array=[]
	cmds.resize(65536)
	tracker.set_block_signals(true)
	PROGRESS.start()
	var err:int=file.start_file(data["path"],CONFIG.get_value(CONFIG.RECORD_FPSAMPLES),sample_rate)
	var buffer_pos:int=0
	var order_pos:Array=[]
	var orders:Array=[]
	if err==OK:
		tracker.record(0)
		while tracker.gen_commands(GLOBALS.song,sample_rate,BUFFER_SIZE,cmds,order_pos):
			if order_pos.empty():
				buffer_pos+=BUFFER_SIZE
			else:
				for op in order_pos:
					orders.append(op+buffer_pos)
				buffer_pos+=order_pos[-1]
				order_pos.clear()
			err=file.write_chunk(synth.generate(BUFFER_SIZE,cmds,1.0))
			if err!=OK:
				file.close()
				ALERT.alert(file.get_error_message(err))
				call_deferred("thread_kill",data["thread"])
				return
			PROGRESS.set_value((tracker.curr_order*100)/GLOBALS.song.orders.size())
		file.write_cue_points(orders)
		file.end_file()
		var cue:File=File.new()
		cue.open(data["path"].get_basename()+".cue",File.WRITE)
		cue.store_line("FILE %s WAVE"%data["path"])
		for i in range(orders.size()):
			var o:int=orders[i]
			cue.store_line("	TRACK %d AUDIO"%(i+1))
			cue.store_line("		TITLE Order %d"%(i+1))
			cue.store_line("		INDEX 01 %d:%02d:%02d"%[o/(sample_rate*60),(o/sample_rate)%60,((o*75)/sample_rate)%75])
			cue.store_line("		REM %d samples"%o)
			cue.store_line("		REM %f seconds"%(float(o)/sample_rate))
		cue.close()
	else:
		ALERT.alert(file.get_error_message(err))
	PROGRESS.end()
	call_deferred("thread_kill",data["thread"])


func thread_kill(thr:Thread)->void:
	if thr!=null:
		thr.wait_to_finish()
