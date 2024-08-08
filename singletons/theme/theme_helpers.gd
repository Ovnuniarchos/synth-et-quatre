extends Node
class_name ThemeHelper


static func apply_styles_to_group(theme:Theme,from:String,to:String)->void:
	if theme==null:
		return
	for n in Engine.get_main_loop().get_nodes_in_group(to):
		apply_styles(theme,from,n)


static func copy_styles(theme:Theme,from:String,to:String)->void:
	if theme==null:
		return
	for co in theme.get_color_list(from):
		theme.set_color(co,to,theme.get_color(co,from))
	for co in theme.get_constant_list(from):
		theme.set_constant(co,to,theme.get_constant(co,from))
	for fo in theme.get_font_list(from):
		theme.set_font(fo,to,theme.get_font(fo,from))
	for ic in theme.get_icon_list(from):
		theme.set_icon(ic,to,theme.get_icon(ic,from))
	for sb in theme.get_stylebox_list(from):
		theme.set_stylebox(sb,to,theme.get_stylebox(sb,from))


static func apply_styles(theme:Theme,from:String,to:Control)->void:
	if theme==null or to==null:
		return
	for co in theme.get_color_list(from):
		to.add_color_override(co,theme.get_color(co,from))
	for co in theme.get_constant_list(from):
		to.add_constant_override(co,theme.get_constant(co,from))
	for fo in theme.get_font_list(from):
		to.add_font_override(fo,theme.get_font(fo,from))
	for ic in theme.get_icon_list(from):
		to.add_icon_override(ic,theme.get_icon(ic,from))
	for sb in theme.get_stylebox_list(from):
		to.add_stylebox_override(sb,theme.get_stylebox(sb,from))


static func get_theme()->Theme:
	return null if Engine.editor_hint else THEME.theme


static func get_color(color:String,type:String)->Color:
	return Color.red if Engine.editor_hint else THEME.get_color(color,type)


static func get_constant(constant:String,type:String)->int:
	return 0 if Engine.editor_hint else THEME.get_constant(constant,type)


static func get_font(font:String,type:String)->Font:
	return null if Engine.editor_hint else THEME.get_font(font,type)


static func get_icon(icon:String,type:String)->Texture:
	return null if Engine.editor_hint else THEME.get_icon(icon,type)


static func get_stylebox(stylebox:String,type:String)->StyleBox:
	return null if Engine.editor_hint else THEME.get_stylebox(stylebox,type)


static func get_theme_meta(key:String):
	return null if Engine.editor_hint else THEME.theme.get_meta(key,null)
