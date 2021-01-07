extends Node

const TYPE_ENUM=TYPE_MAX
const CFG_PATH="user://se4.ini"
const CURR_SONG_DIR=["Files","current_song_dir","",TYPE_STRING]
const CURR_INST_DIR=["Files","current_inst_dir","",TYPE_STRING]
const CURR_SAMPLE_DIR=["Files","current_sample_dir","",TYPE_STRING]
const CURR_EXPORT_DIR=["Files","current_export_dir","",TYPE_STRING]
const AUDIO_SAMPLERATE=["Audio","sample_rate",48000,TYPE_INT,8000,192000,1]
const AUDIO_BUFFERLENGTH=["Audio","buffer_length",TYPE_REAL,0.1,0.1,1,0.1,TYPE_REAL]
const RECORD_SAMPLERATE=["Record","sample_rate",TYPE_INT,48000,8000,192000,1]
const RECORD_FPSAMPLES=["Record","fp_samples",false,TYPE_BOOL]
const RECORD_SAVEMUTED=["Record","save_muted",false,TYPE_BOOL]
const MIDI_NOTEOFF=["MIDI Input","midi_note_off",false,TYPE_BOOL]
const MIDI_VELOCITYSRC=[
		"MIDI Input","midi_vel_src","SE4",TYPE_ENUM,
		["SE4","VEL","VOL","SE4VEL","SE4VOL","VELVOL","SE4VELVOL"]
	]
enum {VELMODE_SE4,VELMODE_VEL,VELMODE_VOL,VELMODE_SE4VEL,VELMODE_SE4VOL,VELMODE_VELVOL,VELMODE_SE4VELVOL}
const MIDI_VOLUME=["MIDI Input","midi_volume",false,TYPE_BOOL]
const MIDI_AFTERTOUCH=["MIDI Input","midi_aftertouch",false,TYPE_BOOL]
const EDIT_HORIZ_FX=["Editor","horizontal_fx_edit",false,TYPE_BOOL]
const EDIT_FX_CRLF=["Editor","horizontal_cr_lf",false,TYPE_BOOL]
const THEME_FILE=["Theme","file","theme/default.json",TYPE_STRING]

const COPIES=[
	CURR_SONG_DIR,CURR_INST_DIR,CURR_SAMPLE_DIR,CURR_EXPORT_DIR,
	AUDIO_SAMPLERATE,AUDIO_BUFFERLENGTH,
	RECORD_SAMPLERATE,RECORD_FPSAMPLES,RECORD_SAVEMUTED,
	MIDI_NOTEOFF,MIDI_VELOCITYSRC,MIDI_VOLUME,MIDI_AFTERTOUCH,
	EDIT_HORIZ_FX,EDIT_FX_CRLF,
	THEME_FILE
]


var config:ConfigFile


func _init()->void:
	var ocfg:ConfigFile=ConfigFile.new()
	ocfg.load(CFG_PATH)
	config=ConfigFile.new()
	for c in COPIES:
		copy_value(ocfg,c)


func _notification(what:int)->void:
	if what==NOTIFICATION_PREDELETE:
		config.save(CFG_PATH)


#


func copy_value(old_cfg:ConfigFile,sect_key:Array)->void:
	config.set_value(sect_key[0],sect_key[1],old_cfg.get_value(sect_key[0],sect_key[1],sect_key[2]))


func get_value(sect_key:Array):
	if sect_key[3]==TYPE_ENUM:
		return sect_key[4].find(config.get_value(sect_key[0],sect_key[1],sect_key[2]))
	return config.get_value(sect_key[0],sect_key[1],sect_key[2])


func set_value(sect_key:Array,value)->void:
	if sect_key[3]==TYPE_INT:
		config.set_value(sect_key[0],sect_key[1],int(value))
	elif sect_key[3]==TYPE_REAL:
		config.set_value(sect_key[0],sect_key[1],float(value))
	elif sect_key[3]==TYPE_BOOL:
		config.set_value(sect_key[0],sect_key[1],bool(value))
	elif sect_key[3]==TYPE_STRING:
		config.set_value(sect_key[0],sect_key[1],String(value))
	elif sect_key[3]==TYPE_ENUM:
		value=int(value)
		if value<0 or value>=sect_key[4].size():
			value=sect_key[2]
		config.set_value(sect_key[0],sect_key[1],sect_key[4][value])

