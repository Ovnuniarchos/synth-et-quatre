extends Node
class_name ThemeHelper


static func apply_styles_group(theme:Theme,from:String,to:String)->void:
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


