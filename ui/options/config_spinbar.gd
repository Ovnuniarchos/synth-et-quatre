tool extends SpinBar
class_name ConfigSpinBar


export (String) var config_key:String="" setget set_config_key


func _ready():
	set_config_key(config_key)
	._ready()


func set_config_key(ck:String)->void:
	config_key=ck
	update_configuration_warning()
	if (ck in CONFIG) and typeof(CONFIG[ck])==TYPE_ARRAY:
		min_value=CONFIG[ck][4]
		max_value=CONFIG[ck][5]
		step=CONFIG[ck][6]
		if !Engine.editor_hint:
			set_value(CONFIG.get_value(CONFIG[ck]))
		property_list_changed_notify()


func _get_configuration_warning()->String:
	if (config_key in CONFIG) and typeof(CONFIG[config_key])==TYPE_ARRAY:
		return ""
	return "Config key not found"


func _on_value_changed(v:float)->void:
	._on_value_changed(v)
	if !Engine.editor_hint:
		CONFIG.set_value(CONFIG[config_key],v)
