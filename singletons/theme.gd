extends Node

enum{FC_TOPLEFT,FC_TOPRIGHT,FC_BOTTOMRIGHT,FC_BOTTOMLEFT}
enum{FS_TOP,FS_RIGHT,FS_BOTTOM,FS_LEFT}
enum{DIM_X,DIM_Y}


const TYPE_NUMBER:Array=[TYPE_REAL,TYPE_INT]
const SP_HORIZONTAL:String="horizontal"
const SP_VERTICAL:String="vertical"
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
const BT_COLORSETS:Dictionary={
	BS_NORMAL:{"fg":CO_DEFAULT_FG,"bg":CO_DEFAULT_BG},
	BS_DISABLED:{"fg":CO_FADED_FG,"bg":CO_FADED_BG},
	BS_HOVER:{"fg":CO_HOVER_FG,"bg":CO_HOVER_BG},
	BS_PRESSED:{"fg":CO_DEFAULT_BG,"bg":CO_DEFAULT_FG}
}
const SB_COLORSETS:Dictionary={
	BS_NORMAL:{"fg":CO_DEFAULT_FG,"bg":CO_DEFAULT_BG},
	BS_HOVER:{"fg":CO_DEFAULT_FG,"bg":CO_HOVER_FG},
	BS_PRESSED:{"fg":CO_DEFAULT_FG,"bg":CO_HOVER_FG}
}
const STRETCH_MODES:Dictionary={
	"stretch":StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH,
	"tile":StyleBoxTexture.AXIS_STRETCH_MODE_TILE,
	"fit":StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
}
const BOX_TYPES:Dictionary={
	"flat":0,
	"bitmap":1
}
var EMPTY_ST:StyleBoxEmpty=StyleBoxEmpty.new()


var theme:Theme
var panel_st:Dictionary={
	BS_NORMAL:null,
	BS_DISABLED:null,
	BS_HOVER:null,
	BS_PRESSED:null
}
var std_spacing:Dictionary
var font_std:DynamicFont
var std_colors:Dictionary

# STRETCH_MODE: "stretch" | "tile" | "fit"
# COLOR_TYPE: /#?([:xdigit:]{2})?[:xdigit:]{6}/i | COLOR_NAME | array4(float) | float
# BOX_TYPE: BOX_TYPE_FLAT | BOX_TYPE_BITMAP
# BOX_TYPE_FLAT: {
#  type: "flat"
#  background: COLOR_TYPE
#  border: COLOR_TYPE
#  corner-radius: array4(float) | float
#  border-width: array4(float) | float
#  margin: array4(float) | float
# }
# BOX_TYPE_BITMAP: {
#  type: "bitmap"
#  texture: string
#  modulate: COLOR_TYPE
#  margin: array4(float) | float
#  border-width: array4(float) | float
#  stretch: array2(STRETCH_MODE) | string
# }
# SCROLLBAR_TYPE: SCROLLBAR_TYPE_FLAT | SCROLLBAR_TYPE_BITMAP
# SCROLLBAR_TYPE_FLAT: {
#  type: "flat"
#  background: COLOR_TYPE
#  border: COLOR_TYPE
#  corner-radius: array4(float) | float
#  border-width: array4(float) | float
# }
# SCROLLBAR_TYPE_BITMAP: {
#  type: "bitmap"
#  texture: string
#  modulate: COLOR_TYPE
#  margin: array4(float) | float
#  border-width: array4(float) | float
#  stretch: array2(STRETCH_MODE) | string
# }
# FONT_TYPE: {
#  file: string
#  size: float
# }
# SEPARATOR_TYPE: {
#  color: COLOR_TYPE
#  line-width: float
#  margin: float
# }
# SPACING_TYPE: {
#  horizontal + vertical: float
# }
# GLYPH_TYPE: {
#  file: string,
#  rect: array4(float) | float
#  margin: array2(float) | float
# }

# Theme properties:
#  colors: {
#   default-fg + default-bg + faded-fg + faded-bg: COLOR_TYPE
#  }
#  glyphs: {
#   source-file: string
#   radio-on + radio-off: GLYPH_TYPE
#  }
#  spacing: SPACING_TYPE
#  font: FONT_TYPE
#  panel: BOX_TYPE
#  tabs: normal + selected: {
#   BOX_TYPE
#   color: COLOR_TYPE
#  }
#  button | check-button:
#   normal + disabled + hover + pressed: {
#    BOX_TYPE
#    color: COLOR_TYPE
#   }
#  menu: {
#   normal + hover: BOX_TYPE
#   separator: SEPARATOR_TYPE
#  }
#  scrollbar: {
#   normal + hover + pressed: SCROLLBAR_TYPE
#   background: BOX_TYPE
#  }
#  listbox: {
#   background + selected: BOX_TYPE
#   separation: float
#  }
#  input: {
#   normal + focus + disabled: BOX_TYPE
#  }

var default_theme:Dictionary={
	"colors":{
		"default-fg":"black",
		"default-bg":"#cccccc",
		"faded-fg":"#80000000",
		"faded-bg":"#80cccccc",
		"hover-fg":"white",
		"hover-bg":"black"
	},
	"glyphs":{
		"source-file":"editor.png",
		"radio-on":{
			"rect":[12.0,114.0,12.0],
			"margin":6.0
		},
		"radio-off":{
			"rect":[0.0,114.0,12.0],
			"margin":6.0
		},
		"check-on":{
			"rect":[12.0,97.0,12.0,14.0],
			"margin":6.0
		},
		"check-off":{
			"rect":[0.0,97.0,12.0,14.0],
			"margin":6.0
		}
	},
	"font":{
		"file":"DejaVuSansMono-Bold.ttf",
		"size":14.0
	},
	"panel":{
		"type":"flat",
		"border-width":[1.0,2.0,2.0,1.0],
		"margin":4.0
	},
	"tabs":{
		"normal":{
			"type":"flat",
			"border-width":1.0,
			"margin":4.0
		},
		"selected":{
			"type":"flat",
			"border-width":2.0,
			"margin":4.0
		},
	},
	"button":{
		"normal":{
			"type":"flat",
			"border-width":2.0,
			"margin":4.0
		},
		"disabled":{
			"type":"flat",
			"border-width":2.0,
			"margin":4.0
		},
		"hover":{
			"type":"flat",
			"border":"#666666",
			"border-width":2.0,
			"margin":4.0
		}
	},
	"check-button":{
		"normal":{
			"type":"flat",
			"border-width":2.0,
			"margin":4.0
		},
		"disabled":{
			"type":"flat",
			"border-width":2.0,
			"margin":4.0
		},
		"hover":{
			"type":"flat",
			"border-width":2.0,
			"margin":4.0
		},
		"pressed":{
			"type":"flat",
			"background":"#006600",
			"border":"#00ff00",
			"border-width":2.0,
			"margin":4.0,
			"color":"#00ff00"
		}
	},
	"menu":{
		"normal":{},
		"hover":{
			"type":"flat",
			"border-width":0.0
		},
		"separator":{
			"color":"black",
			"line-width":2.0,
			"margin":4.0
		}
	},
	"scrollbar":{
		"normal":{
			"border-width":[1.0,2.0,2.0,1.0]
		},
		"hover":{
			"border-width":[1.0,2.0,2.0,1.0]
		},
		"pressed":{
			"border-width":[2.0,1.0,1.0,2.0]
		},
		"background":{
			"border-width":[2.0,1.0,1.0,2.0],
			"margin": [6.0,0.0]
		}
	},
	"listbox":{
		"background":{
			"border-width":[2.0,1.0,1.0,2.0],
			"margin":4.0
		},
		"selected":{
		},
		"separation": 0.0
	},
	"input":{
		"normal":{
			"border-width":[2.0,1.0,1.0,2.0],
			"margin":4.0
		},
		"focus":{},
		"disabled":{}
	}
}
func _init()->void:
	theme=Theme.new()
	# Colors
	std_colors=set_default_colors(default_theme)
	# Spacing
	std_spacing=parse_spacing(typesafe_get(default_theme,"spacing",{}),[4.0,4.0])
	theme.set_constant("separation","HBoxContainer",std_spacing[SP_HORIZONTAL])
	theme.set_constant("separation","VBoxContainer",std_spacing[SP_VERTICAL])
	# Glyphs
	var data:Dictionary=typesafe_get(default_theme,"glyphs",{})
	var dflt_img:Texture=load("res://theme/"+typesafe_get(data,"source-file",""))
	for glyph in data:
		if glyph=="source-file":
			continue
		var at:AtlasTexture=null
		var img:Texture=null
		if data[glyph].get("file"):
			img=load("res://theme/"+typesafe_get(data[glyph],"file",""))
		if img==null:
			img=dflt_img
		if img==null:
			theme.set_icon(glyph,"Glyphs",null)
			continue
		at=AtlasTexture.new()
		at.atlas=img
		at.filter_clip=true
		var rect:Array=parse_rectangle(data[glyph],"rect",-1.0)
		if rect.min()<0.0:
			theme.set_icon(glyph,"Glyphs",null)
			continue
		at.region=Rect2(rect[0],rect[1],rect[2],rect[3])
		var margin:Array=parse_number_list(data[glyph],"margin",2,0.0)
		at.margin=Rect2(margin[0],margin[1],rect[2],rect[3])
		theme.set_icon(glyph,"glyphs",at)
	# Fonts
	set_default_font(default_theme)
	theme.set_font("default_font","",font_std)
	# Labels
	theme.set_font("font","Label",font_std)
	theme.set_constant("line_spacing","Label",0.0)
	theme.set_color("font_color","Label",std_colors[CO_DEFAULT_FG])
	# Panels
	panel_st[BS_NORMAL]=create_stylebox(default_theme,"panel",BT_COLORSETS[BS_NORMAL],null)
	panel_st[BS_DISABLED]=create_stylebox(default_theme,"panel",BT_COLORSETS[BS_DISABLED],null)
	panel_st[BS_HOVER]=create_stylebox(default_theme,"panel",BT_COLORSETS[BS_HOVER],null)
	panel_st[BS_PRESSED]=create_stylebox(default_theme,"panel",BT_COLORSETS[BS_PRESSED],null)
	theme.set_stylebox("panel","PanelContainer",panel_st[BS_NORMAL])
	# Popups
	set_popup_styles(default_theme)
	# Tabs
	set_tab_styles(default_theme)
	# Standard buttons
	set_button_styles("button","Button",default_theme)
	theme.set_font("font","Button",font_std)
	# Accent(check) buttons
	set_button_styles("check-button","AccentButton",default_theme)
	theme.set_font("font","AccentButton",font_std)
	# Check buttons
	theme.set_icon("checked","CheckBox",theme.get_icon("check-on","Glyphs"))
	theme.set_icon("unchecked","CheckBox",theme.get_icon("check-off","Glyphs"))
	theme.set_stylebox("normal","CheckBox",EMPTY_ST)
	theme.set_color("font_color","CheckBox",std_colors[CO_DEFAULT_FG])
	theme.set_stylebox("disabled","CheckBox",EMPTY_ST)
	theme.set_color("font_color_disabled","CheckBox",std_colors[CO_FADED_FG])
	theme.set_stylebox("hover","CheckBox",EMPTY_ST)
	theme.set_color("font_color_hover","CheckBox",std_colors[CO_HOVER_FG])
	theme.set_stylebox("pressed","CheckBox",EMPTY_ST)
	theme.set_color("font_color_pressed","CheckBox",std_colors[CO_DEFAULT_FG])
	# Scrollbars
	set_scrollbar_styles(typesafe_get(default_theme,"scrollbar",{}))
	# Item list
	set_itemlist_styles(typesafe_get(default_theme,"listbox",{}))
	# Input
	set_input_styles(typesafe_get(default_theme,"input",{}))


func set_input_styles(data:Dictionary)->void:
	theme.set_font("font","LineEdit",font_std)
	theme.set_color("font_color","LineEdit",parse_color(typesafe_get(data,"normal",{}),"color",std_colors[CO_DEFAULT_FG]))
	theme.set_color("font_color_selected","LineEdit",std_colors[CO_DEFAULT_BG])
	theme.set_color("selection_color","LineEdit",std_colors[CO_DEFAULT_FG])
	theme.set_color("cursor_color","LineEdit",std_colors[CO_DEFAULT_FG])
	theme.set_stylebox("normal","LineEdit",create_stylebox(data,"normal",BT_COLORSETS[BS_NORMAL],panel_st[BS_NORMAL]))
	if data.has("focus"):
		theme.set_color("font_color_focus","LineEdit",parse_color(typesafe_get(data,"focus",{}),"color",std_colors[CO_DEFAULT_FG]))
		theme.set_stylebox("focus","LineEdit",create_stylebox(data,"focus",BT_COLORSETS[BS_NORMAL],panel_st[BS_NORMAL]))
	else:
		theme.set_color("font_color_focus","LineEdit",theme.get_color("font_color","LineEdit"))
		theme.set_stylebox("focus","LineEdit",theme.get_stylebox("normal","LineEdit"))
	theme.set_color("font_color_uneditable","LineEdit",parse_color(typesafe_get(data,"disabled",{}),"color",std_colors[CO_FADED_FG]))
	theme.set_stylebox("read_only","LineEdit",create_stylebox(data,"disabled",BT_COLORSETS[BS_DISABLED],panel_st[BS_DISABLED]))


func parse_spacing(data:Dictionary,defaults:Array)->Dictionary:
	return {
		SP_HORIZONTAL: typesafe_get(data,SP_HORIZONTAL,defaults[0]),
		SP_VERTICAL: typesafe_get(data,SP_VERTICAL,defaults[1])
	}


func set_itemlist_styles(data:Dictionary)->void:
	theme.set_font("font","ItemList",font_std)
	if data.has("background"):
		theme.set_stylebox("bg","ItemList",create_stylebox(data,"background",BT_COLORSETS[BS_NORMAL],panel_st[BS_NORMAL]))
		theme.set_color("font_color","ItemList",parse_color(typesafe_get(data,"background",{}),"color",std_colors[CO_DEFAULT_FG]))
	else:
		theme.set_stylebox("bg","ItemList",panel_st[BS_NORMAL])
		theme.set_color("font_color","ItemList",std_colors[CO_DEFAULT_FG])
	theme.set_stylebox("bg_focus","ItemList",theme.get_stylebox("bg","ItemList"))
	if data.has("selected"):
		theme.set_stylebox("selected","ItemList",panel_st[BS_PRESSED])
		theme.set_color("font_color_selected","ItemList",std_colors[CO_DEFAULT_BG])
	else:
		theme.set_stylebox("selected","ItemList",panel_st[BS_PRESSED])
		theme.set_color("font_color_selected","ItemList",std_colors[CO_DEFAULT_BG])
	theme.set_stylebox("selected_focus","ItemList",theme.get_stylebox("selected","ItemList"))
	theme.set_color("guide_color","ItemList",Color.transparent)
	theme.set_constant("vseparation","ItemList",typesafe_get(data,"separation",4.0))
	theme.set_constant("line_separation","ItemList",typesafe_get(data,"separation",4.0))


func typesafe_get(d:Dictionary,key:String,default):
	var ret=d.get(key,default)
	if typeof(ret)==typeof(default):
		return ret
	elif typeof(ret) in TYPE_NUMBER and typeof(default) in TYPE_NUMBER:
		return ret
	return default


func set_scrollbar_styles(data:Dictionary)->void:
	theme.set_stylebox("grabber","HScrollBar",create_stylebox(data,"normal",SB_COLORSETS[BS_NORMAL],panel_st[BS_NORMAL]))
	theme.set_stylebox("grabber","VScrollBar",rotate_content_margin(theme.get_stylebox("grabber","HScrollBar")))
	theme.set_stylebox("grabber_highlight","HScrollBar",create_stylebox(data,"hover",SB_COLORSETS[BS_HOVER],panel_st[BS_HOVER]))
	theme.set_stylebox("grabber_highlight","VScrollBar",rotate_content_margin(theme.get_stylebox("grabber_highlight","HScrollBar")))
	theme.set_stylebox("grabber_pressed","HScrollBar",create_stylebox(data,"pressed",SB_COLORSETS[BS_PRESSED],panel_st[BS_PRESSED]))
	theme.set_stylebox("grabber_pressed","VScrollBar",rotate_content_margin(theme.get_stylebox("grabber_pressed","HScrollBar")))
	theme.set_stylebox("scroll","HScrollBar",create_stylebox(data,"background",SB_COLORSETS[BS_NORMAL],panel_st[BS_NORMAL]))
	theme.set_stylebox("scroll","VScrollBar",rotate_content_margin(theme.get_stylebox("scroll","HScrollBar")))


func rotate_content_margin(sb:StyleBox)->StyleBox:
	var sb2:StyleBox=sb.duplicate()
	sb2.content_margin_top=sb.content_margin_left
	sb2.content_margin_right=sb.content_margin_top
	sb2.content_margin_bottom=sb.content_margin_right
	sb2.content_margin_left=sb.content_margin_bottom
	return sb2


func set_default_colors(data:Dictionary)->Dictionary:
	var frag:Dictionary=typesafe_get(data,"colors",{})
	return {
		CO_DEFAULT_FG:parse_color(frag,CO_DEFAULT_FG,Color.black),
		CO_DEFAULT_BG:parse_color(frag,CO_DEFAULT_BG,Color.white),
		CO_FADED_FG:parse_color(frag,CO_FADED_FG,ColorN("black",0.5)),
		CO_FADED_BG:parse_color(frag,CO_FADED_BG,ColorN("white",0.5)),
		CO_HOVER_FG:parse_color(frag,CO_HOVER_FG,Color.white),
		CO_HOVER_BG:parse_color(frag,CO_HOVER_BG,Color.black)
	}


func set_default_font(data:Dictionary)->void:
	var frag:Dictionary=typesafe_get(data,"font",{})
	if data.has("font"):
		font_std=DynamicFont.new()
		var dfd:DynamicFontData=load("res://theme/"+typesafe_get(frag,"file",""))
		if dfd==null:
			dfd=load("res://theme/DejaVuSansMono-Bold.ttf")
		font_std.font_data=dfd
		font_std.size=typesafe_get(frag,"size",14.0)


func set_popup_styles(data:Dictionary)->void:
	theme.set_font("font","PopupMenu",font_std)
	theme.set_color("font_color","PopupMenu",std_colors[CO_DEFAULT_FG])
	theme.set_color("font_color_hover","PopupMenu",std_colors[CO_DEFAULT_BG])
	theme.set_constant("hseparation","PopupMenu",0.0)
	theme.set_constant("vseparation","PopupMenu",0.0)
	var frag:Dictionary=typesafe_get(data,"menu",{})
	theme.set_stylebox("panel","PopupMenu",create_stylebox(frag,"normal",BT_COLORSETS[BS_NORMAL],panel_st[BS_NORMAL]))
	theme.set_stylebox("hover","PopupMenu",create_stylebox(frag,"hover",BT_COLORSETS[BS_HOVER],panel_st[BS_HOVER]))
	var sep_st:StyleBoxLine=StyleBoxLine.new()
	frag=typesafe_get(frag,"separator",{})
	sep_st.color=parse_color(frag,"color",std_colors[CO_DEFAULT_FG])
	sep_st.thickness=typesafe_get(frag,"line-width",2.0)
	sep_st.grow_begin=-max(0.0,typesafe_get(frag,"margin",2.0))
	sep_st.grow_end=sep_st.grow_begin
	theme.set_stylebox("separator","PopupMenu",sep_st)
	theme.set_icon("radio_checked","PopupMenu",theme.get_icon("radio-on","Glyphs"))
	theme.set_icon("radio_unchecked","PopupMenu",theme.get_icon("radio-off","Glyphs"))


func set_tab_styles(data:Dictionary)->void:
	theme.set_stylebox("panel","TabContainer",panel_st[BS_NORMAL])
	theme.set_font("font","TabContainer",font_std)
	if data.has("tabs"):
		var frag:Dictionary=typesafe_get(data,"tabs",{})
		var tab_st:StyleBox=panel_st[BS_NORMAL]
		var tab_cl:Color=parse_color(typesafe_get(frag,TB_NORMAL,{}),"color",std_colors[CO_DEFAULT_FG])
		if frag.has("normal"):
			tab_st=create_stylebox(frag,TB_NORMAL,BT_COLORSETS[BS_NORMAL],panel_st[BS_NORMAL])
		else:
			tab_st=panel_st[BS_NORMAL]
		theme.set_stylebox("tab_bg","TabContainer",tab_st)
		theme.set_color("font_color_bg","TabContainer",tab_cl)
		if frag.has("selected"):
			theme.set_stylebox("tab_fg","TabContainer",create_stylebox(frag,TB_SELECTED,BT_COLORSETS[BS_NORMAL],panel_st[BS_NORMAL]))
			theme.set_color("font_color_fg","TabContainer",parse_color(typesafe_get(frag,TB_SELECTED,{}),"color",std_colors[CO_DEFAULT_FG]))
		else:
			theme.set_stylebox("tab_fg","TabContainer",tab_st)
			theme.set_color("font_color_fg","TabContainer",tab_cl)
	else:
		theme.set_stylebox("tab_bg","TabContainer",panel_st[BS_NORMAL])
		theme.set_color("font_color_bg","TabContainer",std_colors[CO_DEFAULT_FG])
		theme.set_stylebox("tab_fg","TabContainer",panel_st[BS_NORMAL])
		theme.set_color("font_color_fg","TabContainer",std_colors[CO_DEFAULT_FG])
		theme.set_font("font","TabContainer",font_std)


func set_button_styles(tag:String,style:String,data:Dictionary)->void:
	theme.set_stylebox("focus",style,EMPTY_ST)
	var but_st:Dictionary={
		BS_NORMAL:create_sb_flat({},BT_COLORSETS[BS_NORMAL]),
		BS_DISABLED:create_sb_flat({},BT_COLORSETS[BS_DISABLED]),
		BS_HOVER:create_sb_flat({},BT_COLORSETS[BS_HOVER]),
		BS_PRESSED:create_sb_flat({},BT_COLORSETS[BS_PRESSED]),
	}
	var but_cl:Dictionary={
		BS_NORMAL:std_colors[CO_DEFAULT_FG],
		BS_DISABLED:std_colors[CO_FADED_FG],
		BS_HOVER:std_colors[CO_DEFAULT_BG],
		BS_PRESSED:std_colors[CO_DEFAULT_BG]
	}
	theme.set_constant("hseparation",style,0.0)
	var frag:Dictionary=typesafe_get(data,tag,{})
	if not frag.empty():
		for st in but_st:
			if frag.has(st):
				but_st[st]=create_stylebox(frag,st,BT_COLORSETS[st],panel_st[st])
				but_cl[st]=parse_color(typesafe_get(frag,st,{}),"color",std_colors[BT_COLORSETS[st]["fg"]])
	for st in but_st:
		theme.set_stylebox(st,style,but_st[st])
		theme.set_color("font_color" if st==BS_NORMAL else "font_color_"+st,style,but_cl[st])


func parse_color(data:Dictionary,key:String,default:Color)->Color:
	var t:int=typeof(data.get(key,false))
	if t==TYPE_STRING:
		var c:String=data.get(key)
		if c.is_valid_html_color():
			return Color(c)
		return ColorN(c)
	elif t==TYPE_ARRAY:
		var c:Array=data.get(key)
		if c.size()==1:
			return Color(float(c[0]),float(c[0]),float(c[0]))
		elif c.size()==2:
			return Color(float(c[0]),float(c[0]),float(c[0]),float(c[1]))
		elif c.size()==3:
			return Color(float(c[0]),float(c[1]),float(c[2]))
		elif c.size()>=4:
			return Color(float(c[0]),float(c[1]),float(c[2]),float(c[3]))
	elif t in TYPE_NUMBER:
		var c:float=data.get(key)
		return Color(c,c,c)
	return default


func parse_sides_corners(data:Dictionary,key:String,default:float)->Array:
	var t:int=typeof(data.get(key,false))
	if t in TYPE_NUMBER:
		var c:float=data.get(key)
		return [c,c,c,c]
	elif t==TYPE_ARRAY:
		var c:Array=data.get(key)
		if c.size()==1:
			return [float(c[0]),float(c[0]),float(c[0]),float(c[0])]
		elif c.size()==2:
			return [float(c[0]),float(c[1]),float(c[0]),float(c[1])]
		elif c.size()==3:
			return [float(c[0]),float(c[1]),float(c[2]),float(c[1])]
		elif c.size()>=4:
			return [float(c[0]),float(c[1]),float(c[2]),float(c[3])]
	return [default,default,default,default]


func parse_rectangle(data:Dictionary,key:String,default:float)->Array:
	var t:int=typeof(data.get(key,false))
	if t in TYPE_NUMBER:
		var c:float=data.get(key)
		return [c,c,c,c]
	elif t==TYPE_ARRAY:
		var c:Array=data.get(key)
		if c.size()==1:
			return [float(c[0]),float(c[0]),float(c[0]),float(c[0])]
		elif c.size()==2:
			return [float(c[0]),float(c[0]),float(c[1]),float(c[1])]
		elif c.size()==3:
			return [float(c[0]),float(c[1]),float(c[2]),float(c[2])]
		elif c.size()>=4:
			return [float(c[0]),float(c[1]),float(c[2]),float(c[3])]
	return [default,default,default,default]


func parse_string_list(data:Dictionary,key:String,max_length:int,default:String)->Array:
	var t:int=typeof(data.get(key,false))
	var ret:Array=[]
	if t==TYPE_ARRAY:
		var c:Array=data.get(key)
		for i in range(max_length):
			ret.append(String(c[min(i,c.size()-1)]))
	else:
		var c:String=data.get(key) if t==TYPE_STRING else default
		for _i in range(max_length):
			ret.append(c)
	return ret


func parse_number_list(data:Dictionary,key:String,max_length:int,default:float)->Array:
	var t:int=typeof(data.get(key,false))
	var ret:Array=[]
	if t==TYPE_ARRAY:
		var c:Array=data.get(key)
		for i in range(max_length):
			ret.append(float(c[min(i,c.size()-1)]))
	else:
		var c:float=data.get(key) if t in TYPE_NUMBER else default
		for _i in range(max_length):
			ret.append(c)
	return ret


func parse_names(name:String,names:Dictionary,default:int)->int:
	return typesafe_get(names,name.to_lower(),default)


func create_stylebox(data:Dictionary,key:String,colorset:Dictionary,default:StyleBox)->StyleBox:
	var frag:Dictionary=typesafe_get(data,key,{})
	if frag.empty():
		return create_sb_flat({},colorset) if default==null else default
	var t:int=parse_names(typesafe_get(frag,"type","flat"),BOX_TYPES,BOX_TYPES["flat"])
	if t==BOX_TYPES["flat"]:
		return create_sb_flat(frag,colorset)
	else:
		return create_sb_bitmap(frag)


func create_sb_flat(data:Dictionary,colorset:Dictionary)->StyleBoxFlat:
	var def_fg:Color=std_colors[colorset["fg"]]
	var def_bg:Color=std_colors[colorset["bg"]]
	var st:StyleBoxFlat=StyleBoxFlat.new()
	st.bg_color=parse_color(data,"background",def_bg)
	var values:Array=parse_sides_corners(data,"corner-radius",0.0)
	st.corner_radius_top_left=values[FC_TOPLEFT]
	st.corner_radius_top_right=values[FC_TOPRIGHT]
	st.corner_radius_bottom_right=values[FC_BOTTOMRIGHT]
	st.corner_radius_bottom_left=values[FC_BOTTOMLEFT]
	st.corner_detail=8 if values.max()>0.0 else 0
	st.anti_aliasing=values.max()>0.0
	st.border_color=parse_color(data,"border",def_fg)
	values=parse_sides_corners(data,"border-width",2.0)
	st.border_width_top=values[FS_TOP]
	st.border_width_right=values[FS_RIGHT]
	st.border_width_bottom=values[FS_BOTTOM]
	st.border_width_left=values[FS_LEFT]
	values=parse_sides_corners(data,"margin",-1.0)
	st.content_margin_top=values[FS_TOP]
	st.content_margin_right=values[FS_RIGHT]
	st.content_margin_bottom=values[FS_BOTTOM]
	st.content_margin_left=values[FS_LEFT]
	return st


func create_sb_bitmap(data:Dictionary={})->StyleBoxTexture:
	var st:StyleBoxTexture=StyleBoxTexture.new()
	st.texture=null
	st.region_rect=Rect2()
	var values:Array=parse_sides_corners(data,"border-width",2.0)
	st.margin_top=values[FS_TOP]
	st.margin_right=values[FS_RIGHT]
	st.margin_bottom=values[FS_BOTTOM]
	st.margin_left=values[FS_LEFT]
	values=parse_sides_corners(data,"margin",4.0)
	st.content_margin_top=values[FS_TOP]
	st.content_margin_right=values[FS_RIGHT]
	st.content_margin_bottom=values[FS_BOTTOM]
	st.content_margin_left=values[FS_LEFT]
	values=parse_string_list(data,"stretch",2,"stretch")
	st.axis_stretch_horizontal=parse_names(values[0],STRETCH_MODES,STRETCH_MODES["stretch"])
	st.axis_stretch_vertical=parse_names(values[1],STRETCH_MODES,STRETCH_MODES["stretch"])
	return st
