extends Node

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
const DEFAULT_COLORS:Dictionary={
	CO_DEFAULT_FG:Color.black,
	CO_DEFAULT_BG:Color.white,
	CO_FADED_FG:Color(0.0,0.0,0.0,0.5),
	CO_FADED_BG:Color(1.0,1.0,1.0,0.5),
	CO_HOVER_FG:Color.white,
	CO_HOVER_BG:Color.black
}
var EMPTY_ST:StyleBoxEmpty=StyleBoxEmpty.new()


var theme:Theme
var panel_st:Dictionary
var button_colorsets:Dictionary
var box_colorsets:Dictionary
var std_spacing:Dictionary
var std_colors:Dictionary
var std_font:DynamicFont

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
#  spinbar | progress: {
#   background: BOX_TYPE
#   foreground: SCROLLBAR_TYPE
#   color: COLOR_TYPE
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
	},
	"spinbar":{
		"background":{
			"margin":2.0
		},
		"foreground":{
			"background":"#999999",
			"border":"black"
		}
	},
	"progress":{
		"background":{
			"margin":2.0
		},
		"foreground":{
			"background":"#999999",
			"border":"black"
		}
	}
}
func _init()->void:
	theme=Theme.new()
	# Colors
	std_colors=set_default_colors(default_theme)
	button_colorsets={
		BS_NORMAL:{"fg":std_colors[CO_DEFAULT_FG],"bg":std_colors[CO_DEFAULT_BG]},
		BS_DISABLED:{"fg":std_colors[CO_FADED_FG],"bg":std_colors[CO_FADED_BG]},
		BS_HOVER:{"fg":std_colors[CO_HOVER_FG],"bg":std_colors[CO_HOVER_BG]},
		BS_PRESSED:{"fg":std_colors[CO_DEFAULT_BG],"bg":std_colors[CO_DEFAULT_FG]}
	}
	box_colorsets={
		BS_NORMAL:{"fg":std_colors[CO_DEFAULT_FG],"bg":std_colors[CO_DEFAULT_BG]},
		BS_HOVER:{"fg":std_colors[CO_DEFAULT_FG],"bg":std_colors[CO_HOVER_FG]},
		BS_PRESSED:{"fg":std_colors[CO_DEFAULT_FG],"bg":std_colors[CO_HOVER_FG]}
	}
	# Spacing
	std_spacing=parse_spacing(ThemeParser.typesafe_get(default_theme,"spacing",{}),[4.0,4.0])
	theme.set_constant("separation","HBoxContainer",std_spacing[SP_HORIZONTAL])
	theme.set_constant("separation","VBoxContainer",std_spacing[SP_VERTICAL])
	# Glyphs
	set_default_glyphs(default_theme)
	# Fonts
	set_default_font(default_theme)
	theme.set_font("default_font","",std_font)
	# Labels
	theme.set_font("font","Label",std_font)
	theme.set_constant("line_spacing","Label",0.0)
	theme.set_color("font_color","Label",theme.get_color(CO_DEFAULT_FG,"Colors"))
	# Panels
	panel_st[BS_NORMAL]=ThemeParser.create_stylebox(default_theme,"panel",button_colorsets[BS_NORMAL],null)
	panel_st[BS_DISABLED]=ThemeParser.create_stylebox(default_theme,"panel",button_colorsets[BS_DISABLED],null)
	panel_st[BS_HOVER]=ThemeParser.create_stylebox(default_theme,"panel",button_colorsets[BS_HOVER],null)
	panel_st[BS_PRESSED]=ThemeParser.create_stylebox(default_theme,"panel",button_colorsets[BS_PRESSED],null)
	theme.set_stylebox("panel","PanelContainer",panel_st[BS_NORMAL])
	# Popups
	set_popup_styles(default_theme)
	# Tabs
	set_tab_styles(default_theme)
	# Standard buttons
	set_button_styles("button","Button",default_theme)
	theme.set_font("font","Button",std_font)
	# Accent(check) buttons
	set_button_styles("check-button","AccentButton",default_theme)
	theme.set_font("font","AccentButton",std_font)
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
	set_scrollbar_styles(default_theme,"scrollbar")
	# Item list
	set_itemlist_styles(default_theme,"listbox")
	# Input
	set_input_styles(default_theme,"input")
	# SpinBars
	set_bar_styles(default_theme,"SpinBar")
	set_bar_styles(default_theme,"ProgressBar")


func set_bar_styles(data:Dictionary,bar:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,"spinbar",{})
	if frag.has("background"):
		theme.set_stylebox("bg",bar,ThemeParser.create_stylebox(frag,"background",button_colorsets[BS_NORMAL],panel_st[BS_NORMAL]))
	else:
		theme.set_stylebox("bg",bar,theme.get_stylebox("scroll","HScrollBar"))
	if frag.has("foreground"):
		theme.set_stylebox("fg",bar,ThemeParser.create_stylebox(frag,"foreground",box_colorsets[BS_HOVER],panel_st[BS_HOVER]))
	else:
		theme.set_stylebox("fg",bar,theme.get_stylebox("grabber","HScrollBar"))
	theme.set_color("font_color",bar,ThemeParser.parse_color(frag,"color",std_colors[CO_DEFAULT_FG]))
	theme.set_font("font",bar,std_font)


func set_default_glyphs(data:Dictionary)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,"glyphs",{})
	var dflt_img:Texture=load("res://theme/"+ThemeParser.typesafe_get(frag,"source-file",""))
	for glyph in frag:
		if glyph=="source-file":
			continue
		var at:AtlasTexture=null
		var img:Texture=null
		if frag[glyph].get("file"):
			img=load("res://theme/"+ThemeParser.typesafe_get(frag[glyph],"file",""))
		if img==null:
			img=dflt_img
		if img==null:
			theme.set_icon(glyph,"Glyphs",null)
			continue
		at=AtlasTexture.new()
		at.atlas=img
		at.filter_clip=true
		var rect:Array=ThemeParser.parse_rectangle(frag[glyph],"rect",-1.0)
		if rect.min()<0.0:
			theme.set_icon(glyph,"Glyphs",null)
			continue
		at.region=Rect2(rect[0],rect[1],rect[2],rect[3])
		var margin:Array=ThemeParser.parse_number_list(frag[glyph],"margin",2,0.0)
		at.margin=Rect2(margin[0],margin[1],rect[2],rect[3])
		theme.set_icon(glyph,"Glyphs",at)


func set_input_styles(data:Dictionary,key:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	theme.set_font("font","LineEdit",std_font)
	theme.set_color("font_color","LineEdit",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"normal",{}),"color",std_colors[CO_DEFAULT_FG]))
	theme.set_color("font_color_selected","LineEdit",std_colors[CO_DEFAULT_BG])
	theme.set_color("selection_color","LineEdit",std_colors[CO_DEFAULT_FG])
	theme.set_color("cursor_color","LineEdit",std_colors[CO_DEFAULT_FG])
	theme.set_stylebox("normal","LineEdit",ThemeParser.create_stylebox(frag,"normal",button_colorsets[BS_NORMAL],panel_st[BS_NORMAL]))
	if data.has("focus"):
		theme.set_color("font_color_focus","LineEdit",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"focus",{}),"color",std_colors[CO_DEFAULT_FG]))
		theme.set_stylebox("focus","LineEdit",ThemeParser.create_stylebox(frag,"focus",button_colorsets[BS_NORMAL],panel_st[BS_NORMAL]))
	else:
		theme.set_color("font_color_focus","LineEdit",theme.get_color("font_color","LineEdit"))
		theme.set_stylebox("focus","LineEdit",theme.get_stylebox("normal","LineEdit"))
	theme.set_color("font_color_uneditable","LineEdit",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"disabled",{}),"color",std_colors[CO_FADED_FG]))
	theme.set_stylebox("read_only","LineEdit",ThemeParser.create_stylebox(frag,"disabled",button_colorsets[BS_DISABLED],panel_st[BS_DISABLED]))


func parse_spacing(data:Dictionary,defaults:Array)->Dictionary:
	return {
		SP_HORIZONTAL: ThemeParser.typesafe_get(data,SP_HORIZONTAL,defaults[0]),
		SP_VERTICAL: ThemeParser.typesafe_get(data,SP_VERTICAL,defaults[1])
	}


func set_itemlist_styles(data:Dictionary,key:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	theme.set_font("font","ItemList",std_font)
	if frag.has("background"):
		theme.set_stylebox("bg","ItemList",ThemeParser.create_stylebox(frag,"background",button_colorsets[BS_NORMAL],panel_st[BS_NORMAL]))
		theme.set_color("font_color","ItemList",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"background",{}),"color",std_colors[CO_DEFAULT_FG]))
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
	theme.set_constant("vseparation","ItemList",ThemeParser.typesafe_get(frag,"separation",4.0))
	theme.set_constant("line_separation","ItemList",ThemeParser.typesafe_get(frag,"separation",4.0))


func set_scrollbar_styles(data:Dictionary,key:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	theme.set_stylebox("grabber","HScrollBar",ThemeParser.create_stylebox(frag,"normal",box_colorsets[BS_NORMAL],panel_st[BS_NORMAL]))
	theme.set_stylebox("grabber","VScrollBar",ThemeParser.rotate_content_margin(theme.get_stylebox("grabber","HScrollBar")))
	theme.set_stylebox("grabber_highlight","HScrollBar",ThemeParser.create_stylebox(frag,"hover",box_colorsets[BS_HOVER],panel_st[BS_HOVER]))
	theme.set_stylebox("grabber_highlight","VScrollBar",ThemeParser.rotate_content_margin(theme.get_stylebox("grabber_highlight","HScrollBar")))
	theme.set_stylebox("grabber_pressed","HScrollBar",ThemeParser.create_stylebox(frag,"pressed",box_colorsets[BS_PRESSED],panel_st[BS_PRESSED]))
	theme.set_stylebox("grabber_pressed","VScrollBar",ThemeParser.rotate_content_margin(theme.get_stylebox("grabber_pressed","HScrollBar")))
	theme.set_stylebox("scroll","HScrollBar",ThemeParser.create_stylebox(frag,"background",box_colorsets[BS_NORMAL],panel_st[BS_NORMAL]))
	theme.set_stylebox("scroll","VScrollBar",ThemeParser.rotate_content_margin(theme.get_stylebox("scroll","HScrollBar")))


func set_default_colors(data:Dictionary)->Dictionary:
	var frag:Dictionary=ThemeParser.typesafe_get(data,"colors",{})
	var ret:Dictionary={}
	for ci in DEFAULT_COLORS:
		ret[ci]=ThemeParser.parse_color(frag,ci,DEFAULT_COLORS[ci])
		theme.set_color(ci,"Colors",ret[ci])
	return ret


func set_default_font(data:Dictionary)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,"font",{})
	if data.has("font"):
		std_font=DynamicFont.new()
		var dfd:DynamicFontData=load("res://theme/"+ThemeParser.typesafe_get(frag,"file",""))
		if dfd==null:
			dfd=load("res://theme/DejaVuSansMono-Bold.ttf")
		std_font.font_data=dfd
		std_font.size=ThemeParser.typesafe_get(frag,"size",14.0)


func set_popup_styles(data:Dictionary)->void:
	theme.set_font("font","PopupMenu",std_font)
	theme.set_color("font_color","PopupMenu",std_colors[CO_DEFAULT_FG])
	theme.set_color("font_color_hover","PopupMenu",std_colors[CO_DEFAULT_BG])
	theme.set_constant("hseparation","PopupMenu",0.0)
	theme.set_constant("vseparation","PopupMenu",0.0)
	var frag:Dictionary=ThemeParser.typesafe_get(data,"menu",{})
	theme.set_stylebox("panel","PopupMenu",ThemeParser.create_stylebox(frag,"normal",button_colorsets[BS_NORMAL],panel_st[BS_NORMAL]))
	theme.set_stylebox("hover","PopupMenu",ThemeParser.create_stylebox(frag,"hover",button_colorsets[BS_HOVER],panel_st[BS_HOVER]))
	var sep_st:StyleBoxLine=StyleBoxLine.new()
	frag=ThemeParser.typesafe_get(frag,"separator",{})
	sep_st.color=ThemeParser.parse_color(frag,"color",std_colors[CO_DEFAULT_FG])
	sep_st.thickness=ThemeParser.typesafe_get(frag,"line-width",2.0)
	sep_st.grow_begin=-max(0.0,ThemeParser.typesafe_get(frag,"margin",2.0))
	sep_st.grow_end=sep_st.grow_begin
	theme.set_stylebox("separator","PopupMenu",sep_st)
	theme.set_icon("radio_checked","PopupMenu",theme.get_icon("radio-on","Glyphs"))
	theme.set_icon("radio_unchecked","PopupMenu",theme.get_icon("radio-off","Glyphs"))


func set_tab_styles(data:Dictionary)->void:
	theme.set_stylebox("panel","TabContainer",panel_st[BS_NORMAL])
	theme.set_font("font","TabContainer",std_font)
	if data.has("tabs"):
		var frag:Dictionary=ThemeParser.typesafe_get(data,"tabs",{})
		var tab_st:StyleBox=panel_st[BS_NORMAL]
		var tab_cl:Color=ThemeParser.parse_color(ThemeParser.typesafe_get(frag,TB_NORMAL,{}),"color",std_colors[CO_DEFAULT_FG])
		if frag.has("normal"):
			tab_st=ThemeParser.create_stylebox(frag,TB_NORMAL,button_colorsets[BS_NORMAL],panel_st[BS_NORMAL])
		else:
			tab_st=panel_st[BS_NORMAL]
		theme.set_stylebox("tab_bg","TabContainer",tab_st)
		theme.set_color("font_color_bg","TabContainer",tab_cl)
		if frag.has("selected"):
			theme.set_stylebox("tab_fg","TabContainer",ThemeParser.create_stylebox(frag,TB_SELECTED,button_colorsets[BS_NORMAL],panel_st[BS_NORMAL]))
			theme.set_color("font_color_fg","TabContainer",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,TB_SELECTED,{}),"color",std_colors[CO_DEFAULT_FG]))
		else:
			theme.set_stylebox("tab_fg","TabContainer",tab_st)
			theme.set_color("font_color_fg","TabContainer",tab_cl)
	else:
		theme.set_stylebox("tab_bg","TabContainer",panel_st[BS_NORMAL])
		theme.set_color("font_color_bg","TabContainer",std_colors[CO_DEFAULT_FG])
		theme.set_stylebox("tab_fg","TabContainer",panel_st[BS_NORMAL])
		theme.set_color("font_color_fg","TabContainer",std_colors[CO_DEFAULT_FG])
		theme.set_font("font","TabContainer",std_font)


func set_button_styles(tag:String,style:String,data:Dictionary)->void:
	theme.set_stylebox("focus",style,EMPTY_ST)
	var but_st:Dictionary={
		BS_NORMAL:ThemeParser.create_sb_flat({},button_colorsets[BS_NORMAL]),
		BS_DISABLED:ThemeParser.create_sb_flat({},button_colorsets[BS_DISABLED]),
		BS_HOVER:ThemeParser.create_sb_flat({},button_colorsets[BS_HOVER]),
		BS_PRESSED:ThemeParser.create_sb_flat({},button_colorsets[BS_PRESSED]),
	}
	var but_cl:Dictionary={
		BS_NORMAL:std_colors[CO_DEFAULT_FG],
		BS_DISABLED:std_colors[CO_FADED_FG],
		BS_HOVER:std_colors[CO_DEFAULT_BG],
		BS_PRESSED:std_colors[CO_DEFAULT_BG]
	}
	theme.set_constant("hseparation",style,0.0)
	var frag:Dictionary=ThemeParser.typesafe_get(data,tag,{})
	if not frag.empty():
		for st in but_st:
			if frag.has(st):
				but_st[st]=ThemeParser.create_stylebox(frag,st,button_colorsets[st],panel_st[st])
				but_cl[st]=ThemeParser.parse_color(ThemeParser.typesafe_get(frag,st,{}),"color",button_colorsets[st]["fg"])
	for st in but_st:
		theme.set_stylebox(st,style,but_st[st])
		theme.set_color("font_color" if st==BS_NORMAL else "font_color_"+st,style,but_cl[st])

