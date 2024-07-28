extends Button
class_name IconButton


export (String) var icon_name:String="" setget set_icon_name
export (String) var default_text:String=""


func set_icon_name(n:String)->void:
	if not is_node_ready():
		yield(self,"ready")
	icon_name=n
	icon=ThemeHelper.get_icon(icon_name,"Glyphs")
	text=default_text if icon==null else ""
