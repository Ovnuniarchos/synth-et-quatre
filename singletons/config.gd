extends Node

const CFG_PATH="user://se4.ini"
const CURR_DIR=["","current_dir",""]
const AUDIO_SAMPLERATE=["Audio","sample_rate",48000]
const AUDIO_BUFFERLENGTH=["Audio","buffer_length",0.1]
const RECORD_SAMPLERATE=["Record","sample_rate",48000]
const RECORD_FPSAMPLES=["Record","fp_samples",false]
const RECORD_SAVEMUTED=["Record","save_muted",false]
var config:ConfigFile

func _init()->void:
	var ocfg:ConfigFile=ConfigFile.new()
	ocfg.load(CFG_PATH)
	config=ConfigFile.new()
	copy_value(ocfg,CURR_DIR)
	copy_value(ocfg,AUDIO_SAMPLERATE)
	copy_value(ocfg,AUDIO_BUFFERLENGTH)
	copy_value(ocfg,RECORD_SAMPLERATE)
	copy_value(ocfg,RECORD_FPSAMPLES)
	copy_value(ocfg,RECORD_SAVEMUTED)

func _notification(what:int)->void:
	if what==NOTIFICATION_PREDELETE:
		config.save(CFG_PATH)

#

func copy_value(old_cfg:ConfigFile,sect_key:Array)->void:
	config.set_value(sect_key[0],sect_key[1],old_cfg.get_value(sect_key[0],sect_key[1],sect_key[2]))

func get_value(sect_key:Array):
	return config.get_value(sect_key[0],sect_key[1],sect_key[2])

func set_value(sect_key:Array,value)->void:
	config.set_value(sect_key[0],sect_key[1],value)
