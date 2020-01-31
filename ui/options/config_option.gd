tool extends OptionButton

export (String) var config_key:String="" setget set_config_key

func _ready():
	set_config_key(config_key)
	connect("item_selected",self,"_on_item_selected")

func set_config_key(ck:String)->void:
	config_key=ck
	update_configuration_warning()
	if (ck in CONFIG) and typeof(CONFIG[ck])==TYPE_ARRAY and !Engine.editor_hint:
		selected=CONFIG.get_value(CONFIG[ck])

func _get_configuration_warning()->String:
	if (config_key in CONFIG) and typeof(CONFIG[config_key])==TYPE_ARRAY:
		return ""
	return "Config key not found"

func _on_item_selected(id:int)->void:
	CONFIG.set_value(CONFIG[config_key],id)
