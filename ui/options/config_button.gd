tool extends Button
class_name ConfigButton

signal configured(value)

export (String) var config_key:String="" setget set_config_key

func _init()->void:
	toggle_mode=true

func _ready()->void:
	set_config_key(config_key)

func set_config_key(ck:String)->void:
	config_key=ck
	update_configuration_warning()
	if (ck in CONFIG) and typeof(CONFIG[ck])==TYPE_ARRAY and !Engine.editor_hint:
		pressed=CONFIG.get_value(CONFIG[ck])
		emit_signal("configured",pressed)

func _get_configuration_warning()->String:
	if (config_key in CONFIG) and typeof(CONFIG[config_key])==TYPE_ARRAY:
		return ""
	return "Config key not found"

func _toggled(p:bool)->void:
	pressed=p
	if !Engine.editor_hint:
		CONFIG.set_value(CONFIG[config_key],p)
	emit_signal("toggled",p)
