extends Node

const BS_NORMAL:String="normal"
const BS_DISABLED:String="disabled"
const BS_HOVER:String="hover"
const BS_PRESSED:String="pressed"
const TB_NORMAL:String="normal"
const TB_SELECTED:String="selected"
const CO_DEFAULT_FG:String="default-fg"
const CO_DEFAULT_BG:String="default-bg"
const CO_FADED_FG:String="faded-fg"
const CO_FADED_BG:String="faded-bg"
const CO_HOVER_FG:String="hover-fg"
const CO_HOVER_BG:String="hover-bg"
const CO_ACCENT_FG:String="accent-fg"
const CO_ACCENT_BG:String="accent-bg"
const DEFAULT_COLORS:Dictionary={
	CO_DEFAULT_FG:Color.black,
	CO_DEFAULT_BG:Color.white,
	CO_FADED_FG:Color(0.0,0.0,0.0,0.5),
	CO_FADED_BG:Color(1.0,1.0,1.0,0.5),
	CO_HOVER_FG:Color.white,
	CO_HOVER_BG:Color.black,
	CO_ACCENT_FG:Color.red,
	CO_ACCENT_BG:Color.darkred
}
var EMPTY_STYLEBOX:StyleBoxEmpty=StyleBoxEmpty.new()
var EMPTY_TEXTURE:Texture=StreamTexture.new()


var theme:Theme
var panel_st:Dictionary
var button_colorsets:Dictionary
var box_colorsets:Dictionary
var bar_colorsets:Dictionary
var std_spacing:Dictionary
var std_colors:Dictionary
var std_font:DynamicFont
var std_text_style:Dictionary
var std_image:Texture


func _init()->void:
	theme=parse_theme(CONFIG.get_value(CONFIG.THEME_FILE))


func get_color(color:String,type:String)->Color:
	return theme.get_color(color,type) if theme.has_color(color,type) else DEFAULT_COLORS[CO_DEFAULT_FG]


func get_constant(constant:String,type:String)->int:
	return theme.get_constant(constant,type) if theme.has_constant(constant,type) else 0


func get_font(font:String,type:String)->Font:
	return theme.get_font(font,type) if theme.has_font(font,type) else null


func get_icon(icon:String,type:String)->Texture:
	return theme.get_icon(icon,type) if theme.has_icon(icon,type) else null


func get_stylebox(stylebox:String,type:String)->StyleBox:
	return theme.get_stylebox(stylebox,type) if theme.has_stylebox(stylebox,type) else null


func parse_theme(file:String)->Theme:
	var f:File=File.new()
	var theme_data:Dictionary={}
	var base_dir:String
	if f.open(file,File.READ)==OK:
		var d:Directory=Directory.new()
		var json:JSONParseResult=JSON.parse(f.get_as_text())
		if json.error!=OK:
			print(json.error_string," -> L",json.error_line)
		else:
			theme_data=json.result
			d.open(file.get_base_dir())
			base_dir=d.get_current_dir()
	#
	var new_theme=Theme.new()
	# Colors
	std_colors=set_default_colors(new_theme,theme_data)
	ThemeParser.set_std_colors({
		"background":std_colors[CO_DEFAULT_BG],
		"foreground":std_colors[CO_DEFAULT_FG],
		"backgroundfaded":std_colors[CO_FADED_BG],
		"foregroundfaded":std_colors[CO_FADED_FG],
		"backgroundhover":std_colors[CO_HOVER_BG],
		"foregroundhover":std_colors[CO_HOVER_FG],
		"backgroundaccent":std_colors[CO_ACCENT_BG],
		"foregroundaccent":std_colors[CO_ACCENT_FG],
	})
	button_colorsets={
		BS_NORMAL:{"fg":std_colors[CO_DEFAULT_FG],"bg":std_colors[CO_DEFAULT_BG]},
		BS_DISABLED:{"fg":std_colors[CO_FADED_FG],"bg":std_colors[CO_FADED_BG]},
		BS_HOVER:{"fg":std_colors[CO_HOVER_FG],"bg":std_colors[CO_HOVER_BG]},
		BS_PRESSED:{"fg":std_colors[CO_DEFAULT_BG],"bg":std_colors[CO_DEFAULT_FG]}
	}
	bar_colorsets={
		BS_NORMAL:{
			"bg":{"fg":std_colors[CO_DEFAULT_FG],"bg":std_colors[CO_DEFAULT_BG]},
			"fg":{"fg":std_colors[CO_DEFAULT_BG],"bg":std_colors[CO_DEFAULT_FG]},
			"text":std_colors[CO_DEFAULT_FG]
		},
		BS_DISABLED:{
			"bg":{"fg":std_colors[CO_FADED_FG],"bg":std_colors[CO_FADED_BG]},
			"fg":{"fg":std_colors[CO_FADED_BG],"bg":std_colors[CO_FADED_FG]},
			"text":std_colors[CO_FADED_FG]
		},
		BS_HOVER:{
			"bg":{"fg":std_colors[CO_HOVER_FG],"bg":std_colors[CO_HOVER_BG]},
			"fg":{"fg":std_colors[CO_HOVER_BG],"bg":std_colors[CO_HOVER_FG]},
			"text":std_colors[CO_HOVER_FG]
		}
	}
	box_colorsets={
		BS_NORMAL:{"fg":std_colors[CO_DEFAULT_FG],"bg":std_colors[CO_DEFAULT_BG]},
		BS_HOVER:{"fg":std_colors[CO_DEFAULT_FG],"bg":std_colors[CO_HOVER_FG]},
		BS_PRESSED:{"fg":std_colors[CO_DEFAULT_FG],"bg":std_colors[CO_HOVER_FG]}
	}
	# Spacing
	std_spacing=ThemeParser.parse_spacing(theme_data,"spacing",[4,4])
	new_theme.set_constant("separation","HBoxContainer",std_spacing[ThemeParser.SP_HORIZONTAL])
	new_theme.set_constant("separation","VBoxContainer",std_spacing[ThemeParser.SP_VERTICAL])
	# Default image
	std_image=ThemeParser.resource_load(ThemeParser.typesafe_get(theme_data,"default-image",""),base_dir,ThemeParser.FT_IMAGE,EMPTY_TEXTURE)
	# Glyphs
	set_default_glyphs(new_theme,theme_data,base_dir)
	# Fonts
	std_font=ThemeParser.parse_font(theme_data,"font",base_dir,null)
	new_theme.set_font("default_font","",std_font)
	# Panels
	panel_st[BS_NORMAL]=ThemeParser.create_stylebox(theme_data,"panel",base_dir,button_colorsets[BS_NORMAL],null,std_image)
	panel_st[BS_DISABLED]=ThemeParser.create_stylebox(theme_data,"panel",base_dir,button_colorsets[BS_DISABLED],null,std_image)
	panel_st[BS_HOVER]=ThemeParser.create_stylebox(theme_data,"panel",base_dir,button_colorsets[BS_HOVER],null,std_image)
	panel_st[BS_PRESSED]=ThemeParser.create_stylebox(theme_data,"panel",base_dir,button_colorsets[BS_PRESSED],null,std_image)
	new_theme.set_stylebox("panel","PanelContainer",panel_st[BS_NORMAL])
	new_theme.set_stylebox("panel","Panel",panel_st[BS_NORMAL])
	new_theme.set_stylebox("empty_panel","",EMPTY_STYLEBOX)
	# Popups
	set_popup_styles(new_theme,theme_data,base_dir)
	# Tabs
	set_tab_styles(new_theme,theme_data,base_dir)
	# Standard buttons
	set_button_styles(new_theme,theme_data,"button","Button",base_dir)
	ThemeHelper.copy_styles(new_theme,"Button","OptionButton")
	# Accent(check) buttons
	ThemeHelper.copy_styles(new_theme,"Button","AccentButton")
	set_button_styles(new_theme,theme_data,"accent-button","AccentButton",base_dir)
	# Menu buttons
	ThemeHelper.copy_styles(new_theme,"Button","MenuButton")
	set_button_styles(new_theme,theme_data,"menu","MenuButton",base_dir)
	# Order buttons
	set_button_styles(new_theme,theme_data,"button","RowButton",base_dir)
	set_button_styles(new_theme,theme_data,"button","OrderButton",base_dir)
	set_order_matrix_styles(new_theme,theme_data,"order-matrix",base_dir)
	# Scrollbars
	set_scrollbar_styles(new_theme,theme_data,"scrollbar",base_dir)
	# Item list
	set_itemlist_styles(new_theme,theme_data,"listbox",base_dir)
	# Input
	set_input_styles(new_theme,theme_data,"input",base_dir)
	# SpinBars
	set_bar_styles(new_theme,theme_data,"spinbar","SpinBar",base_dir)
	set_bar_styles(new_theme,theme_data,"progress","ProgressBar",base_dir)
	# Labels
	std_text_style=set_label_styles(new_theme,theme_data,"text","Label",{
		"font":std_font,
		"color":new_theme.get_color(CO_DEFAULT_FG,"Colors")
	},base_dir)
	set_label_styles(new_theme,theme_data,"title","LabelTitle",std_text_style,base_dir)
	set_label_styles(new_theme,theme_data,"label","LabelControl",std_text_style,base_dir)
	# Splitters
	set_splitter_styles(new_theme,ThemeParser.typesafe_get(theme_data,"splitter",{}),"horizontal","VSplitContainer",base_dir)
	set_splitter_styles(new_theme,ThemeParser.typesafe_get(theme_data,"splitter",{}),"vertical","HSplitContainer",base_dir)
	# Dialogs
	set_dialog_styles(new_theme,theme_data,"dialog",base_dir)
	# File selector
	set_filedialog_styles(new_theme,theme_data,"file-dialog",base_dir)
	# Tooltips
	set_tooltip_style(new_theme,theme_data,"tooltip",base_dir)
	# Tracker
	set_tracker_styles(new_theme,theme_data,"tracker",base_dir)
	# Bar editor
	set_bar_editor_styles(new_theme,theme_data,"bar-editor",base_dir)
	return new_theme


func set_bar_editor_margins(sb:StyleBox,frag:Dictionary)->void:
	if not frag.has("margin"):
		if sb is StyleBoxFlat:
			sb.content_margin_left=sb.border_width_left
			sb.content_margin_right=sb.border_width_right
			sb.content_margin_top=sb.border_width_top
			sb.content_margin_bottom=sb.border_width_bottom
		else:
			sb.content_margin_left=sb.margin_left
			sb.content_margin_right=sb.margin_right
			sb.content_margin_top=sb.margin_top
			sb.content_margin_bottom=sb.margin_bottom

func set_bar_editor_styles(new_theme:Theme,data:Dictionary,key:String,base_dir:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	var sb:StyleBox=new_theme.get_stylebox("panel","PanelContainer")
	var sb2:StyleBox=ThemeParser.create_stylebox(frag,"values",base_dir,box_colorsets[BS_NORMAL],sb,std_image).duplicate()
	set_bar_editor_margins(sb2,ThemeParser.typesafe_get(frag,"values",{}))
	new_theme.set_stylebox("values","BarEditor",sb2)
	sb2=ThemeParser.create_stylebox(frag,"loop",base_dir,box_colorsets[BS_NORMAL],new_theme.get_stylebox("values","BarEditor"),std_image).duplicate()
	set_bar_editor_margins(sb2,ThemeParser.typesafe_get(frag,"loop",{}))
	new_theme.set_stylebox("loop","BarEditor",sb2)
	new_theme.set_color("values_color","BarEditor",ThemeParser.parse_color(frag,"color",std_colors[CO_HOVER_FG]))
	new_theme.set_color("relative_color","BarEditor",ThemeParser.parse_color(frag,"relative-color",new_theme.get_color("values_color","BarEditor")))
	new_theme.set_color("mask_color","BarEditor",ThemeParser.parse_color(frag,"mask-color",new_theme.get_color("values_color","BarEditor")))
	new_theme.set_color("center_color","BarEditor",ThemeParser.parse_color(frag,"center-color",new_theme.get_color("values_color","BarEditor")))
	new_theme.set_color("loop_color","BarEditor",ThemeParser.parse_color(frag,"loop-color",new_theme.get_color("values_color","BarEditor")))
	new_theme.set_color("release_color","BarEditor",ThemeParser.parse_color(frag,"release-color",new_theme.get_color("loop_color","BarEditor")))
	var sz:Array=ThemeParser.typesafe_get(frag,"bar-size",[16,8])
	new_theme.set_constant("bar_size_x","BarEditor",sz[0])
	new_theme.set_constant("bar_size_y","BarEditor",sz[1])
	new_theme.set_constant("loop_height","BarEditor",ThemeParser.typesafe_get(frag,"loop-height",16.0))
	new_theme.set_constant("separation","BarEditor",ThemeParser.typesafe_get(frag,"separation",new_theme.get_constant("separation","HBoxContainer")))
	new_theme.set_font("label_font","BarEditor",ThemeParser.parse_font(frag,"labels",base_dir,new_theme.get_font("font","TooltipLabel")))
	set_label_styles(new_theme,frag,"labels","BarEditorLabel",{
		"font":std_font,
		"color":std_colors[CO_DEFAULT_FG],
		"outline":std_colors[CO_DEFAULT_FG]
	},base_dir)


func set_order_matrix_styles(new_theme:Theme,data:Dictionary,key:String,base_dir:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	var font:Font=ThemeParser.parse_font(frag,"font",base_dir,new_theme.get_font("font","Button"))
	var margin:Array=ThemeParser.parse_number_list(frag,"margin",2,0.0)
	new_theme.set_constant("margin_x","OrderMatrix",margin[0])
	new_theme.set_constant("margin_y","OrderMatrix",margin[1])
	new_theme.set_font("font","OrderButton",font)
	new_theme.set_font("font","RowButton",font)
	var sb:StyleBox=new_theme.get_stylebox("normal","Button")
	new_theme.set_stylebox("normal","OrderButton",ThemeParser.create_stylebox(frag,"item",base_dir,button_colorsets[BS_NORMAL],sb,std_image))
	new_theme.set_color("font_color","OrderButton",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"item",{}),"color",std_colors[CO_DEFAULT_FG]))
	sb=new_theme.get_stylebox("normal","OrderButton")
	new_theme.set_stylebox("normal","RowButton",ThemeParser.create_stylebox(frag,"rownum",base_dir,button_colorsets[BS_NORMAL],sb,std_image))
	new_theme.set_color("font_color","RowButton",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"rownum",{}),"color",std_colors[CO_DEFAULT_FG]))
	sb=new_theme.get_stylebox("normal","RowButton")
	new_theme.set_stylebox("normal_on","RowButton",ThemeParser.create_stylebox(frag,"rownum-sel",base_dir,button_colorsets[BS_NORMAL],sb,std_image))
	new_theme.set_color("font_color_on","RowButton",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"rownum-sel",{}),"color",std_colors[CO_DEFAULT_FG]))
	#
	sb=new_theme.get_stylebox("hover","Button")
	new_theme.set_stylebox("hover","OrderButton",ThemeParser.create_stylebox(frag,"item-hover",base_dir,button_colorsets[BS_HOVER],sb,std_image))
	new_theme.set_color("font_color_hover","OrderButton",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"item-hover",{}),"color",std_colors[CO_HOVER_FG]))
	sb=new_theme.get_stylebox("hover","OrderButton")
	new_theme.set_stylebox("hover","RowButton",ThemeParser.create_stylebox(frag,"rownum-hover",base_dir,button_colorsets[BS_HOVER],sb,std_image))
	new_theme.set_color("font_color_hover","RowButton",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"rownum-hover",{}),"color",std_colors[CO_HOVER_FG]))
	sb=new_theme.get_stylebox("hover","RowButton")
	new_theme.set_stylebox("hover_on","RowButton",ThemeParser.create_stylebox(frag,"rownum-sel-hover",base_dir,button_colorsets[BS_HOVER],sb,std_image))
	new_theme.set_color("font_color_hover_on","RowButton",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"rownum-sel-hover",{}),"color",std_colors[CO_HOVER_FG]))


func set_tracker_styles(new_theme:Theme,data:Dictionary,key:String,base_dir:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	var at:AtlasTexture=ThemeParser.parse_image(frag,base_dir,std_image)
	var cs:Array=ThemeParser.parse_number_list(frag,"cell-size",2,-1)
	if cs.max()<1.0:
		cs=[8,16]
	var ts:TileSet=TileSet.new()
	var tid:int=0
	if at!=null:
		for y in range(0,at.region.size.y,cs[1]):
			for x in range(0,at.region.size.x,cs[0]):
				ts.create_tile(tid)
				ts.tile_set_texture(tid,at)
				ts.tile_set_region(tid,Rect2(x,y,cs[0],cs[1]))
				tid+=1
	new_theme.set_meta("tileset",ts)
	new_theme.set_constant("cell_w","Tracker",cs[0])
	new_theme.set_constant("cell_h","Tracker",cs[1])
	new_theme.set_color("background","Tracker",ThemeParser.parse_color(frag,"background",std_colors[CO_DEFAULT_BG]))
	new_theme.set_color("minor","Tracker",ThemeParser.parse_color(frag,"minor-highlighht",std_colors[CO_DEFAULT_BG].linear_interpolate(std_colors[CO_DEFAULT_FG],0.25)))
	new_theme.set_color("major","Tracker",ThemeParser.parse_color(frag,"major-highlighht",std_colors[CO_DEFAULT_BG].linear_interpolate(std_colors[CO_DEFAULT_FG],0.5)))
	new_theme.set_color("active","Tracker",ThemeParser.parse_color(frag,"active-row",std_colors[CO_HOVER_FG]))
	new_theme.set_color("color","Tracker",ThemeParser.parse_color(frag,"color",std_colors[CO_DEFAULT_FG]))
	new_theme.set_color("muted","Tracker",ThemeParser.parse_color(frag,"muted",Color("#ff9999")))
	new_theme.set_color("solo","Tracker",ThemeParser.parse_color(frag,"solo",Color("#99ccff")))


func set_tooltip_style(new_theme:Theme,data:Dictionary,key:String,base_dir:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	new_theme.set_stylebox("panel","TooltipPanel",ThemeParser.create_stylebox(data,key,base_dir,box_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
	new_theme.set_color("font_color","TooltipLabel",ThemeParser.parse_color(frag,"color",std_colors[CO_DEFAULT_FG]))
	new_theme.set_color("font_color_shadow","TooltipLabel",Color.transparent)
	new_theme.set_font("font","TooltipLabel",ThemeParser.parse_font(frag,"font",base_dir,std_font))


func set_filedialog_styles(new_theme:Theme,data:Dictionary,key:String,base_dir:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	new_theme.set_stylebox("bg","Tree",ThemeParser.create_stylebox(frag,"file-list",base_dir,box_colorsets[BS_NORMAL],new_theme.get_stylebox("normal","LineEdit"),std_image))
	new_theme.set_font("font","Tree",new_theme.get_font("default_font",""))
	new_theme.set_color("font_color","Tree",ThemeParser.parse_color(frag,"color",std_colors[CO_DEFAULT_FG]))
	new_theme.set_stylebox("selected","Tree",ThemeParser.create_stylebox(frag,"file-list-selected",base_dir,{},new_theme.get_stylebox("hover","PopupMenu"),std_image))
	new_theme.set_stylebox("selected_focus","Tree",new_theme.get_stylebox("selected","Tree"))
	new_theme.set_color("font_color_selected","Tree",ThemeParser.parse_color(frag,"color-selected",new_theme.get_color("font_color_hover","PopupMenu")))
	new_theme.set_constant("draw_guides","Tree",0)
	new_theme.set_icon("file","FileDialog",ThemeParser.parse_image(ThemeParser.typesafe_get(frag,"file",{}),base_dir,std_image))
	new_theme.set_icon("folder","FileDialog",ThemeParser.parse_image(ThemeParser.typesafe_get(frag,"folder",{}),base_dir,std_image))
	new_theme.set_icon("parent_folder","FileDialog",ThemeParser.parse_image(ThemeParser.typesafe_get(frag,"parent",{}),base_dir,std_image))
	new_theme.set_icon("reload","FileDialog",ThemeParser.parse_image(ThemeParser.typesafe_get(frag,"reload",{}),base_dir,std_image))
	new_theme.set_icon("toggle_hidden","FileDialog",ThemeParser.parse_image(ThemeParser.typesafe_get(frag,"hide",{}),base_dir,std_image))
	new_theme.set_color("file_icon_modulate","FileDialog",ThemeParser.parse_color(frag,"file-color",Color.white))
	new_theme.set_color("files_disabled","FileDialog",ThemeParser.parse_color(frag,"color-disabled",std_colors[CO_FADED_FG]))
	new_theme.set_color("folder_icon_modulate","FileDialog",ThemeParser.parse_color(frag,"folder-color",Color.white))


func set_dialog_styles(new_theme:Theme,data:Dictionary,key:String,base_dir:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	var st:StyleBox=ThemeParser.create_stylebox(data,key,base_dir,box_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image)
	if st==panel_st[BS_NORMAL]:
		st=panel_st[BS_NORMAL].duplicate()
	var tf:Font=ThemeParser.parse_font(frag,"title-font",base_dir,new_theme.get_font("font","LabelTitle"))
	if tf==null:
		tf=Label.new().get_font("")
	new_theme.set_font("title_font","WindowDialog",tf)
	var th:float=tf.get_height()+ThemeParser.typesafe_get(frag,"title-margin",0.0)
	st.expand_margin_top=th
	new_theme.set_constant("title_height","WindowDialog",th)
	new_theme.set_color("title_color","WindowDialog",ThemeParser.parse_color(frag,"title-color",std_colors[CO_DEFAULT_FG]))
	new_theme.set_stylebox("panel","WindowDialog",st)
	var icn:AtlasTexture=ThemeParser.parse_image(ThemeParser.typesafe_get(frag,"closer",{}),base_dir,std_image)
	if icn==null:
		icn=new_theme.get_icon("close","Glyphs") if new_theme.has_icon("close","Glyphs") else null
	new_theme.set_icon("close","WindowDialog",icn)
	new_theme.set_icon("close_highlight","WindowDialog",icn)
	if icn!=null:
		var ofs:Array=ThemeParser.parse_number_list(frag,"closer-margin",2,0.0)
		new_theme.set_constant("close_h_ofs","WindowDialog",icn.region.size.x+ofs[0])
		new_theme.set_constant("close_v_ofs","WindowDialog",th-ofs[1])



func set_splitter_styles(new_theme:Theme,data:Dictionary,key:String,splitter_type:String,base_dir:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	var at:AtlasTexture=ThemeParser.parse_image(frag,base_dir,std_image)
	var margin:float=ThemeParser.typesafe_get(frag,"margin",0.0)*2.0
	if at!=null:
		margin+=at.region.size.x if key=="vertical" else at.region.size.y
	new_theme.set_constant("separation",splitter_type,margin)
	new_theme.set_icon("grabber",splitter_type,at)
	new_theme.set_constant("autohide",splitter_type,int(ThemeParser.parse_boolean(frag,"autohide",false)))


func set_label_styles(new_theme:Theme,data:Dictionary,key:String,label_type:String,default:Dictionary,base_dir:String)->Dictionary:
	var ret:Dictionary=ThemeParser.parse_text_styles(data,key,base_dir,default)
	new_theme.set_constant("line_spacing",label_type,0)
	new_theme.set_font("font",label_type,ret["font"])
	new_theme.set_color("font_color",label_type,ret["color"])
	new_theme.set_color("font_outline_modulate",label_type,ret["outline"])
	if ret["shadow-type"]==ThemeParser.SHADOW_TYPES[ThemeParser.ST_NONE]:
		new_theme.set_color("font_color_shadow",label_type,Color.transparent)
	else:
		new_theme.set_color("font_color_shadow",label_type,ret["shadow-color"])
	new_theme.set_constant("shadow_offset_x",label_type,ret["shadow-offset"][0])
	new_theme.set_constant("shadow_offset_y",label_type,ret["shadow-offset"][1])
	new_theme.set_constant("shadow_as_outline",label_type,int(ret["shadow-type"]==ThemeParser.SHADOW_TYPES[ThemeParser.ST_OUTLINE]))
	return ret


func set_bar_styles(new_theme:Theme,data:Dictionary,key:String,bar_type:String,base_dir:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	for mode in [BS_NORMAL,BS_DISABLED,BS_HOVER]:
		var frag2:Dictionary=ThemeParser.typesafe_get(frag,mode,{})
		new_theme.set_stylebox("bg_"+mode,bar_type,ThemeParser.create_stylebox(frag2,"background",base_dir,bar_colorsets[mode]["bg"],panel_st[mode],std_image))
		new_theme.set_stylebox("fg_"+mode,bar_type,ThemeParser.create_stylebox(frag2,"foreground",base_dir,bar_colorsets[mode]["fg"],panel_st[mode],std_image))
		new_theme.set_color("font_color_"+mode,bar_type,ThemeParser.parse_color(frag2,"color",bar_colorsets[mode]["text"]))
		new_theme.set_font("font_"+mode,bar_type,ThemeParser.parse_font(frag2,"font",base_dir,std_font))


func set_default_glyphs(new_theme:Theme,data:Dictionary,base_dir:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,"glyphs",{})
	for glyph in frag:
		new_theme.set_icon(glyph.replace("-","_"),"Glyphs",ThemeParser.parse_glyph(frag[glyph],base_dir,std_image))


func set_input_styles(new_theme:Theme,data:Dictionary,key:String,base_dir:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	new_theme.set_font("font","LineEdit",ThemeParser.parse_font(frag,"font",base_dir,std_font))
	new_theme.set_color("font_color","LineEdit",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"normal",{}),"color",std_colors[CO_DEFAULT_FG]))
	new_theme.set_color("font_color_selected","LineEdit",std_colors[CO_DEFAULT_BG])
	new_theme.set_color("selection_color","LineEdit",std_colors[CO_DEFAULT_FG])
	new_theme.set_color("cursor_color","LineEdit",std_colors[CO_DEFAULT_FG])
	new_theme.set_stylebox("normal","LineEdit",ThemeParser.create_stylebox(frag,"normal",base_dir,button_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
	var sb:StyleBox=new_theme.get_stylebox("normal","LineEdit")
	if data.has("focus"):
		new_theme.set_stylebox("focus","LineEdit",ThemeParser.create_stylebox(frag,"focus",base_dir,button_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
		new_theme.set_color("font_color_focus","LineEdit",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"focus",{}),"color",std_colors[CO_DEFAULT_FG]))
	else:
		new_theme.set_stylebox("focus","LineEdit",ThemeParser.create_stylebox(frag,"focus",base_dir,button_colorsets[BS_NORMAL],sb,std_image))
		new_theme.set_color("font_color_focus","LineEdit",std_colors[CO_DEFAULT_FG])
	if data.has("disabled"):
		new_theme.set_stylebox("read_only","LineEdit",ThemeParser.create_stylebox(frag,"disabled",base_dir,button_colorsets[BS_DISABLED],panel_st[BS_DISABLED],std_image))
		new_theme.set_color("font_color_uneditable","LineEdit",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"disabled",{}),"color",std_colors[CO_FADED_FG]))
	else:
		new_theme.set_stylebox("read_only","LineEdit",ThemeParser.create_stylebox(frag,"disabled",base_dir,button_colorsets[BS_DISABLED],sb,std_image))
		new_theme.set_color("font_color_uneditable","LineEdit",std_colors[CO_FADED_FG])


func set_itemlist_styles(new_theme:Theme,data:Dictionary,key:String,base_dir:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	new_theme.set_font("font","ItemList",ThemeParser.parse_font(frag,"font",base_dir,std_font))
	if frag.has("background"):
		new_theme.set_stylebox("bg","ItemList",ThemeParser.create_stylebox(frag,"background",base_dir,button_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
		new_theme.set_color("font_color","ItemList",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"background",{}),"color",std_colors[CO_DEFAULT_FG]))
	else:
		new_theme.set_stylebox("bg","ItemList",panel_st[BS_NORMAL])
		new_theme.set_color("font_color","ItemList",std_colors[CO_DEFAULT_FG])
	new_theme.set_stylebox("bg_focus","ItemList",new_theme.get_stylebox("bg","ItemList"))
	if frag.has("selected"):
		var t:StyleBox=ThemeParser.create_stylebox(frag,"selected",base_dir,button_colorsets[BS_PRESSED],panel_st[BS_PRESSED],std_image)
		new_theme.set_stylebox("selected","ItemList",t)
		new_theme.set_color("font_color_selected","ItemList",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"selected",{}),"color",std_colors[CO_DEFAULT_BG]))
	else:
		new_theme.set_stylebox("selected","ItemList",panel_st[BS_PRESSED])
		new_theme.set_color("font_color_selected","ItemList",std_colors[CO_DEFAULT_BG])
	new_theme.set_stylebox("selected_focus","ItemList",new_theme.get_stylebox("selected","ItemList"))
	new_theme.set_color("guide_color","ItemList",Color.transparent)
	new_theme.set_constant("vseparation","ItemList",ThemeParser.typesafe_get(frag,"separation",4))
	new_theme.set_constant("line_separation","ItemList",ThemeParser.typesafe_get(frag,"separation",4))


func set_scrollbar_styles(new_theme:Theme,data:Dictionary,key:String,base_dir:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	new_theme.set_stylebox("grabber","HScrollBar",ThemeParser.create_stylebox(frag,"normal",base_dir,box_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
	new_theme.set_stylebox("grabber","VScrollBar",ThemeParser.rotate_content_margin(new_theme.get_stylebox("grabber","HScrollBar")))
	new_theme.set_stylebox("grabber_highlight","HScrollBar",ThemeParser.create_stylebox(frag,"hover",base_dir,box_colorsets[BS_HOVER],panel_st[BS_HOVER],std_image))
	new_theme.set_stylebox("grabber_highlight","VScrollBar",ThemeParser.rotate_content_margin(new_theme.get_stylebox("grabber_highlight","HScrollBar")))
	new_theme.set_stylebox("grabber_pressed","HScrollBar",ThemeParser.create_stylebox(frag,"pressed",base_dir,box_colorsets[BS_PRESSED],panel_st[BS_PRESSED],std_image))
	new_theme.set_stylebox("grabber_pressed","VScrollBar",ThemeParser.rotate_content_margin(new_theme.get_stylebox("grabber_pressed","HScrollBar")))
	new_theme.set_stylebox("scroll","HScrollBar",ThemeParser.create_stylebox(frag,"background",base_dir,box_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
	new_theme.set_stylebox("scroll","VScrollBar",ThemeParser.rotate_content_margin(new_theme.get_stylebox("scroll","HScrollBar")))


func set_default_colors(new_theme:Theme,data:Dictionary)->Dictionary:
	var frag:Dictionary=ThemeParser.typesafe_get(data,"colors",{})
	var ret:Dictionary={}
	for ci in DEFAULT_COLORS:
		ret[ci]=ThemeParser.parse_color(frag,ci,DEFAULT_COLORS[ci])
		new_theme.set_color(ci.replace("-","_"),"Colors",ret[ci])
	return ret


func set_popup_styles(new_theme:Theme,data:Dictionary,base_dir:String)->void:
	new_theme.set_color("font_color","PopupMenu",std_colors[CO_DEFAULT_FG])
	new_theme.set_color("font_color_hover","PopupMenu",std_colors[CO_DEFAULT_BG])
	new_theme.set_constant("hseparation","PopupMenu",0)
	new_theme.set_constant("vseparation","PopupMenu",0)
	var frag:Dictionary=ThemeParser.typesafe_get(data,"popup",{})
	new_theme.set_font("font","PopupMenu",ThemeParser.parse_font(frag,"font",base_dir,std_font))
	new_theme.set_stylebox("panel","PopupMenu",ThemeParser.create_stylebox(frag,"normal",base_dir,button_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
	new_theme.set_stylebox("hover","PopupMenu",ThemeParser.create_stylebox(frag,"hover",base_dir,button_colorsets[BS_HOVER],panel_st[BS_HOVER],std_image))
	var sep_st:StyleBoxLine=StyleBoxLine.new()
	var frag2:Dictionary=ThemeParser.typesafe_get(frag,"separator",{})
	sep_st.color=ThemeParser.parse_color(frag2,"color",std_colors[CO_DEFAULT_FG])
	sep_st.thickness=ThemeParser.typesafe_get(frag2,"line-width",2)
	sep_st.grow_begin=-max(0,ThemeParser.typesafe_get(frag2,"margin",2))
	sep_st.grow_end=sep_st.grow_begin
	new_theme.set_stylebox("separator","PopupMenu",sep_st)
	new_theme.set_icon("radio_checked","PopupMenu",ThemeParser.parse_glyph(ThemeParser.typesafe_get(frag,"checked",{}),base_dir,std_image))
	new_theme.set_icon("radio_unchecked","PopupMenu",ThemeParser.parse_glyph(ThemeParser.typesafe_get(frag,"unchecked",{}),base_dir,std_image))
	var t:Texture=ThemeParser.parse_glyph(ThemeParser.typesafe_get(frag,"dropper",{}),base_dir,null)
	new_theme.set_icon("arrow","OptionButton",new_theme.get_icon("arrow_down","Glyphs") if t==null else t)
	# Another undocumented style
	new_theme.set_constant("modulate_arrow","OptionButton",1)


func set_tab_styles(new_theme:Theme,data:Dictionary,base_dir:String)->void:
	new_theme.set_stylebox("panel","TabContainer",panel_st[BS_NORMAL])
	if data.has("tab"):
		var frag:Dictionary=ThemeParser.typesafe_get(data,"tab",{})
		var tab_st:StyleBox=panel_st[BS_NORMAL]
		var tab_cl:Color=ThemeParser.parse_color(ThemeParser.typesafe_get(frag,TB_NORMAL,{}),"color",std_colors[CO_DEFAULT_FG])
		new_theme.set_font("font","TabContainer",ThemeParser.parse_font(frag,"font",base_dir,std_font))
		if frag.has("normal"):
			tab_st=ThemeParser.create_stylebox(frag,TB_NORMAL,base_dir,button_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image)
		else:
			tab_st=panel_st[BS_NORMAL]
		if frag.has("overlap"):
			tab_st=tab_st.duplicate()
			tab_st.expand_margin_bottom=ThemeParser.typesafe_get(frag,"overlap",0)
		new_theme.set_stylebox("tab_bg","TabContainer",tab_st)
		new_theme.set_color("font_color_bg","TabContainer",tab_cl)
		if frag.has("selected"):
			tab_st=ThemeParser.create_stylebox(frag,TB_SELECTED,base_dir,button_colorsets[BS_NORMAL],tab_st,std_image)
			if frag.has("overlap"):
				tab_st=tab_st.duplicate()
				tab_st.expand_margin_bottom=ThemeParser.typesafe_get(frag,"overlap",0)
			new_theme.set_stylebox("tab_fg","TabContainer",tab_st)
			new_theme.set_color("font_color_fg","TabContainer",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,TB_SELECTED,{}),"color",tab_cl))
		else:
			new_theme.set_stylebox("tab_fg","TabContainer",tab_st)
			new_theme.set_color("font_color_fg","TabContainer",tab_cl)
	else:
		new_theme.set_stylebox("tab_bg","TabContainer",panel_st[BS_NORMAL])
		new_theme.set_color("font_color_bg","TabContainer",std_colors[CO_DEFAULT_FG])
		new_theme.set_stylebox("tab_fg","TabContainer",panel_st[BS_NORMAL])
		new_theme.set_color("font_color_fg","TabContainer",std_colors[CO_DEFAULT_FG])
		new_theme.set_font("font","TabContainer",std_font)


func set_button_styles(new_theme:Theme,data:Dictionary,key:String,node_type:String,base_dir:String)->void:
	new_theme.set_stylebox("focus",node_type,EMPTY_STYLEBOX)
	var but_st:Dictionary={
		BS_NORMAL:ThemeParser.create_sb_flat({},button_colorsets[BS_NORMAL],panel_st[BS_NORMAL])
	}
	var but_cl:Dictionary={
		BS_NORMAL:std_colors[CO_DEFAULT_FG],
		BS_DISABLED:std_colors[CO_FADED_FG],
		BS_HOVER:std_colors[CO_DEFAULT_BG],
		BS_PRESSED:std_colors[CO_DEFAULT_BG]
	}
	new_theme.set_constant("hseparation",node_type,0)
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	if not frag.empty():
		new_theme.set_font("font",node_type,ThemeParser.parse_font(frag,"font",base_dir,std_font))
		for st in [BS_NORMAL,BS_DISABLED,BS_HOVER,BS_PRESSED]:
			but_st[st]=ThemeParser.create_stylebox(frag,st,base_dir,button_colorsets[st],but_st[BS_NORMAL],std_image)
			but_cl[st]=ThemeParser.parse_color(ThemeParser.typesafe_get(frag,st,{}),"color",button_colorsets[st]["fg"])
	for st in but_st:
		new_theme.set_stylebox(st,node_type,but_st[st])
		new_theme.set_color("font_color" if st==BS_NORMAL else "font_color_"+st,node_type,but_cl[st])
		# Undocumented (but handy) new_theme color
		new_theme.set_color("icon_color_"+st,node_type,but_cl[st])

