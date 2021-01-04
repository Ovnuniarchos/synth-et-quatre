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
const DEFAULT_COLORS:Dictionary={
	CO_DEFAULT_FG:Color.black,
	CO_DEFAULT_BG:Color.white,
	CO_FADED_FG:Color(0.0,0.0,0.0,0.5),
	CO_FADED_BG:Color(1.0,1.0,1.0,0.5),
	CO_HOVER_FG:Color.white,
	CO_HOVER_BG:Color.black
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


var default_theme:Dictionary={
	"colors":{
		"default-fg":"black",
		"default-bg":"#9999aa",
		"faded-fg":"#80000000",
		"faded-bg":"#80ccccdd",
		"hover-fg":"white",
		"hover-bg":"black"
	},
	"default-image":"editor.png",
	"glyphs":{
		"arrow-up":{
			"rect":[24,112,8,16],
			"margin":[8,0]
		},
		"arrow-down":{
			"rect":[32,112,8,16],
			"margin":[8,0]
		},
		"arrow-left":{
			"rect":[48,112,8,16],
			"margin":[8,0]
		},
		"arrow-right":{
			"rect":[40,112,8,16],
			"margin":[8,0]
		},
		"close":{
			"rect":[56,112,8,16],
			"margin":[8,0]
		},
		"play":{
			"rect":[96,112,16,16],
			"margin":[2,0]
		},
		"play-track":{
			"rect":[64,112,16,16],
			"margin":[2,0]
		},
		"stop":{
			"rect":[112,112,16,16],
			"margin":[2,0]
		}
	},
	"font":{
		"file":"DejaVuSansMono-Bold.ttf",
		"size":14
	},
	"title":{
		"font":{"size":16}
	},
	"panel":{
		"type":"flat",
		"border-width":[1,2,2,1],
		"corner-radius":4,
		"margin":4,
		"antialias":false
	},
	"tab":{
		"normal":{
			"type":"flat",
			"border-width":[1,1,0],
			"corner-radius":[4,4,0,0],
			"margin":4
		},
		"selected":{
			"background":"#aaaabb",
			"border-width":[2,2,0]
		},
		"overlap":1
	},
	"button":{
		"normal":{
			"type":"flat",
			"border-width":2,
			"corner-radius":2,
			"antialias":false,
			"margin":3
		}
	},
	"menu":{
		"normal":{
			"border-width":0,
			"margin":0
		}
	},
	"accent-button":{
		"normal":{
			"type":"flat",
			"border-width":2,
			"margin":4
		},
		"disabled":{
			"type":"flat",
			"border-width":2,
			"margin":4
		},
		"hover":{
			"type":"flat",
			"border-width":2,
			"margin":4
		},
		"pressed":{
			"type":"flat",
			"background":"#006600",
			"border":"#00ff00",
			"border-width":2,
			"margin":4,
			"color":"#00ff00"
		}
	},
	"popup":{
		"hover":{
			"type":"flat",
			"border-width":0
		},
		"separator":{
			"color":"black",
			"line-width":2,
			"margin":4
		},
		"checked":{
			"rect":[12,114,12]
		},
		"unchecked":{
			"rect":[0,114,12],
		},
	},
	"scrollbar":{
		"normal":{
			"border-width":[1,2,2,1]
		},
		"hover":{
			"border-width":[1,2,2,1]
		},
		"pressed":{
			"border-width":[2,1,1,2]
		},
		"background":{
			"border-width":[2,1,1,2],
			"margin": [6,0]
		}
	},
	"listbox":{
		"background":{
			"border-width":[2,1,1,2],
			"margin":4
		},
		"separation":0
	},
	"input":{
		"normal":{
			"border-width":[2,1,1,2],
			"margin":4
		}
	},
	"spinbar":{
		"normal":{
			"background":{
				"margin":0
			},
			"foreground":{
				"background":"#666677",
				"border":"black"
			}
		},
		"hover":{
			"background":{
				"background":"black",
				"border":"white"
			},
			"foreground":{
				"background":"#333344",
				"border":"white"
			}
		},
	},
	"progress":{
		"normal":{
			"background":{
				"margin":2
			},
			"foreground":{
				"background":"#666677",
				"border":"black"
			}
		}
	},
	"splitter":{
		"horizontal":{
			"rect":[32,107,64,5],
			"margin":4
		},
		"vertical":{
			"rect":[96,48,5,64],
			"margin":4
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
	std_spacing=ThemeParser.parse_spacing(default_theme,"spacing",[4,4])
	theme.set_constant("separation","HBoxContainer",std_spacing[ThemeParser.SP_HORIZONTAL])
	theme.set_constant("separation","VBoxContainer",std_spacing[ThemeParser.SP_VERTICAL])
	# Default image
	std_image=ThemeParser.resource_load("res://theme/"+ThemeParser.typesafe_get(default_theme,"default-image",""),"StreamTexture",EMPTY_TEXTURE)
	# Glyphs
	set_default_glyphs(default_theme)
	# Fonts
	std_font=ThemeParser.parse_font(default_theme,"font",null)
	theme.set_font("default_font","",std_font)
	# Panels
	panel_st[BS_NORMAL]=ThemeParser.create_stylebox(default_theme,"panel",button_colorsets[BS_NORMAL],null,std_image)
	panel_st[BS_DISABLED]=ThemeParser.create_stylebox(default_theme,"panel",button_colorsets[BS_DISABLED],null,std_image)
	panel_st[BS_HOVER]=ThemeParser.create_stylebox(default_theme,"panel",button_colorsets[BS_HOVER],null,std_image)
	panel_st[BS_PRESSED]=ThemeParser.create_stylebox(default_theme,"panel",button_colorsets[BS_PRESSED],null,std_image)
	theme.set_stylebox("panel","PanelContainer",panel_st[BS_NORMAL])
	theme.set_stylebox("empty_panel","",EMPTY_STYLEBOX)
	# Popups
	set_popup_styles(default_theme)
	# Tabs
	set_tab_styles(default_theme)
	# Standard buttons
	set_button_styles(default_theme,"button","Button")
	ThemeHelper.copy_styles(theme,"Button","OptionButton")
	# Accent(check) buttons
	ThemeHelper.copy_styles(theme,"Button","AccentButton")
	set_button_styles(default_theme,"accent-button","AccentButton")
	# Menu buttons
	ThemeHelper.copy_styles(theme,"Button","MenuButton")
	set_button_styles(default_theme,"menu","MenuButton")
	# Scrollbars
	set_scrollbar_styles(default_theme,"scrollbar")
	# Item list
	set_itemlist_styles(default_theme,"listbox")
	# Input
	set_input_styles(default_theme,"input")
	# SpinBars
	set_bar_styles(default_theme,"spinbar","SpinBar")
	set_bar_styles(default_theme,"progress","ProgressBar")
	# Labels
	std_text_style=set_label_styles(default_theme,"text","Label",{
		"font":std_font,
		"color":theme.get_color(CO_DEFAULT_FG,"Colors")
	})
	set_label_styles(default_theme,"title","LabelTitle",std_text_style)
	set_label_styles(default_theme,"label","LabelControl",std_text_style)
	# Splitters
	set_splitter_styles(ThemeParser.typesafe_get(default_theme,"splitter",{}),"horizontal","VSplitContainer")
	set_splitter_styles(ThemeParser.typesafe_get(default_theme,"splitter",{}),"vertical","HSplitContainer")


func set_splitter_styles(data:Dictionary,key:String,splitter_type:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	var at:AtlasTexture=ThemeParser.parse_image(frag,std_image)
	var margin:float=ThemeParser.typesafe_get(frag,"margin",0.0)*2.0
	if at!=null:
		margin+=at.region.size.x if key=="vertical" else at.region.size.y
	theme.set_constant("separation",splitter_type,margin)
	theme.set_icon("grabber",splitter_type,at)
	theme.set_constant("autohide",splitter_type,int(ThemeParser.parse_boolean(frag,"autohide",false)))


func set_label_styles(data:Dictionary,key:String,label_type:String,default:Dictionary)->Dictionary:
	var ret:Dictionary=ThemeParser.parse_text_styles(data,key,default)
	theme.set_constant("line_spacing",label_type,0)
	theme.set_font("font",label_type,ret["font"])
	theme.set_color("font_color",label_type,ret["color"])
	theme.set_color("font_outline_modulate",label_type,ret["outline"])
	if ret["shadow-type"]==ThemeParser.SHADOW_TYPES[ThemeParser.ST_NONE]:
		theme.set_color("font_color_shadow",label_type,Color.transparent)
	else:
		theme.set_color("font_color_shadow",label_type,ret["shadow-color"])
	theme.set_constant("shadow_offset_x",label_type,ret["shadow-offset"][0])
	theme.set_constant("shadow_offset_y",label_type,ret["shadow-offset"][1])
	theme.set_constant("shadow_as_outline",label_type,int(ret["shadow-type"]==ThemeParser.SHADOW_TYPES[ThemeParser.ST_OUTLINE]))
	return ret


func set_bar_styles(data:Dictionary,key:String,bar_type:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	for mode in [BS_NORMAL,BS_DISABLED,BS_HOVER]:
		var frag2:Dictionary=ThemeParser.typesafe_get(frag,mode,{})
		theme.set_stylebox("bg_"+mode,bar_type,ThemeParser.create_stylebox(frag2,"background",bar_colorsets[mode]["bg"],panel_st[mode],std_image))
		theme.set_stylebox("fg_"+mode,bar_type,ThemeParser.create_stylebox(frag2,"foreground",bar_colorsets[mode]["fg"],panel_st[mode],std_image))
		theme.set_color("font_color_"+mode,bar_type,ThemeParser.parse_color(frag2,"color",bar_colorsets[mode]["text"]))
		theme.set_font("font_"+mode,bar_type,ThemeParser.parse_font(frag2,"font",std_font))


func set_default_glyphs(data:Dictionary)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,"glyphs",{})
	for glyph in frag:
		theme.set_icon(glyph,"Glyphs",ThemeParser.parse_glyph(frag[glyph],std_image))


func set_input_styles(data:Dictionary,key:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	theme.set_font("font","LineEdit",ThemeParser.parse_font(frag,"font",std_font))
	theme.set_color("font_color","LineEdit",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"normal",{}),"color",std_colors[CO_DEFAULT_FG]))
	theme.set_color("font_color_selected","LineEdit",std_colors[CO_DEFAULT_BG])
	theme.set_color("selection_color","LineEdit",std_colors[CO_DEFAULT_FG])
	theme.set_color("cursor_color","LineEdit",std_colors[CO_DEFAULT_FG])
	theme.set_stylebox("normal","LineEdit",ThemeParser.create_stylebox(frag,"normal",button_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
	var sb:StyleBox=theme.get_stylebox("normal","LineEdit")
	if data.has("focus"):
		theme.set_stylebox("focus","LineEdit",ThemeParser.create_stylebox(frag,"focus",button_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
		theme.set_color("font_color_focus","LineEdit",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"focus",{}),"color",std_colors[CO_DEFAULT_FG]))
	else:
		theme.set_stylebox("focus","LineEdit",ThemeParser.create_stylebox(frag,"focus",button_colorsets[BS_NORMAL],sb,std_image))
		theme.set_color("font_color_focus","LineEdit",std_colors[CO_DEFAULT_FG])
	if data.has("disabled"):
		theme.set_stylebox("read_only","LineEdit",ThemeParser.create_stylebox(frag,"disabled",button_colorsets[BS_DISABLED],panel_st[BS_DISABLED],std_image))
		theme.set_color("font_color_uneditable","LineEdit",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"disabled",{}),"color",std_colors[CO_FADED_FG]))
	else:
		theme.set_stylebox("read_only","LineEdit",ThemeParser.create_stylebox(frag,"disabled",button_colorsets[BS_DISABLED],sb,std_image))
		theme.set_color("font_color_uneditable","LineEdit",std_colors[CO_FADED_FG])


func set_itemlist_styles(data:Dictionary,key:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	theme.set_font("font","ItemList",ThemeParser.parse_font(frag,"font",std_font))
	if frag.has("background"):
		theme.set_stylebox("bg","ItemList",ThemeParser.create_stylebox(frag,"background",button_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
		theme.set_color("font_color","ItemList",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"background",{}),"color",std_colors[CO_DEFAULT_FG]))
	else:
		theme.set_stylebox("bg","ItemList",panel_st[BS_NORMAL])
		theme.set_color("font_color","ItemList",std_colors[CO_DEFAULT_FG])
	theme.set_stylebox("bg_focus","ItemList",theme.get_stylebox("bg","ItemList"))
	if frag.has("selected"):
		var t:StyleBox=ThemeParser.create_stylebox(frag,"selected",button_colorsets[BS_PRESSED],panel_st[BS_PRESSED],std_image)
		theme.set_stylebox("selected","ItemList",t)
		theme.set_color("font_color_selected","ItemList",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,"selected",{}),"color",std_colors[CO_DEFAULT_BG]))
	else:
		theme.set_stylebox("selected","ItemList",panel_st[BS_PRESSED])
		theme.set_color("font_color_selected","ItemList",std_colors[CO_DEFAULT_BG])
	theme.set_stylebox("selected_focus","ItemList",theme.get_stylebox("selected","ItemList"))
	theme.set_color("guide_color","ItemList",Color.transparent)
	theme.set_constant("vseparation","ItemList",ThemeParser.typesafe_get(frag,"separation",4))
	theme.set_constant("line_separation","ItemList",ThemeParser.typesafe_get(frag,"separation",4))


func set_scrollbar_styles(data:Dictionary,key:String)->void:
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	theme.set_stylebox("grabber","HScrollBar",ThemeParser.create_stylebox(frag,"normal",box_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
	theme.set_stylebox("grabber","VScrollBar",ThemeParser.rotate_content_margin(theme.get_stylebox("grabber","HScrollBar")))
	theme.set_stylebox("grabber_highlight","HScrollBar",ThemeParser.create_stylebox(frag,"hover",box_colorsets[BS_HOVER],panel_st[BS_HOVER],std_image))
	theme.set_stylebox("grabber_highlight","VScrollBar",ThemeParser.rotate_content_margin(theme.get_stylebox("grabber_highlight","HScrollBar")))
	theme.set_stylebox("grabber_pressed","HScrollBar",ThemeParser.create_stylebox(frag,"pressed",box_colorsets[BS_PRESSED],panel_st[BS_PRESSED],std_image))
	theme.set_stylebox("grabber_pressed","VScrollBar",ThemeParser.rotate_content_margin(theme.get_stylebox("grabber_pressed","HScrollBar")))
	theme.set_stylebox("scroll","HScrollBar",ThemeParser.create_stylebox(frag,"background",box_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
	theme.set_stylebox("scroll","VScrollBar",ThemeParser.rotate_content_margin(theme.get_stylebox("scroll","HScrollBar")))


func set_default_colors(data:Dictionary)->Dictionary:
	var frag:Dictionary=ThemeParser.typesafe_get(data,"colors",{})
	var ret:Dictionary={}
	for ci in DEFAULT_COLORS:
		ret[ci]=ThemeParser.parse_color(frag,ci,DEFAULT_COLORS[ci])
		theme.set_color(ci,"Colors",ret[ci])
	return ret


func set_popup_styles(data:Dictionary)->void:
	theme.set_color("font_color","PopupMenu",std_colors[CO_DEFAULT_FG])
	theme.set_color("font_color_hover","PopupMenu",std_colors[CO_DEFAULT_BG])
	theme.set_constant("hseparation","PopupMenu",0)
	theme.set_constant("vseparation","PopupMenu",0)
	var frag:Dictionary=ThemeParser.typesafe_get(data,"popup",{})
	theme.set_font("font","PopupMenu",ThemeParser.parse_font(frag,"font",std_font))
	theme.set_stylebox("panel","PopupMenu",ThemeParser.create_stylebox(frag,"normal",button_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image))
	theme.set_stylebox("hover","PopupMenu",ThemeParser.create_stylebox(frag,"hover",button_colorsets[BS_HOVER],panel_st[BS_HOVER],std_image))
	var sep_st:StyleBoxLine=StyleBoxLine.new()
	var frag2:Dictionary=ThemeParser.typesafe_get(frag,"separator",{})
	sep_st.color=ThemeParser.parse_color(frag2,"color",std_colors[CO_DEFAULT_FG])
	sep_st.thickness=ThemeParser.typesafe_get(frag2,"line-width",2)
	sep_st.grow_begin=-max(0,ThemeParser.typesafe_get(frag2,"margin",2))
	sep_st.grow_end=sep_st.grow_begin
	theme.set_stylebox("separator","PopupMenu",sep_st)
	theme.set_icon("radio_checked","PopupMenu",ThemeParser.parse_glyph(ThemeParser.typesafe_get(frag,"checked",{}),std_image))
	theme.set_icon("radio_unchecked","PopupMenu",ThemeParser.parse_glyph(ThemeParser.typesafe_get(frag,"unchecked",{}),std_image))
	var t:Texture=ThemeParser.parse_glyph(ThemeParser.typesafe_get(frag,"dropper",{}),null)
	theme.set_icon("arrow","OptionButton",theme.get_icon("arrow-down","Glyphs") if t==null else t)
	# Another undocumented style
	theme.set_constant("modulate_arrow","OptionButton",1)


func set_tab_styles(data:Dictionary)->void:
	theme.set_stylebox("panel","TabContainer",panel_st[BS_NORMAL])
	if data.has("tab"):
		var frag:Dictionary=ThemeParser.typesafe_get(data,"tab",{})
		var tab_st:StyleBox=panel_st[BS_NORMAL]
		var tab_cl:Color=ThemeParser.parse_color(ThemeParser.typesafe_get(frag,TB_NORMAL,{}),"color",std_colors[CO_DEFAULT_FG])
		theme.set_font("font","TabContainer",ThemeParser.parse_font(frag,"font",std_font))
		if frag.has("normal"):
			tab_st=ThemeParser.create_stylebox(frag,TB_NORMAL,button_colorsets[BS_NORMAL],panel_st[BS_NORMAL],std_image)
		else:
			tab_st=panel_st[BS_NORMAL]
		if frag.has("overlap"):
			tab_st=tab_st.duplicate()
			tab_st.expand_margin_bottom=ThemeParser.typesafe_get(frag,"overlap",0)
		theme.set_stylebox("tab_bg","TabContainer",tab_st)
		theme.set_color("font_color_bg","TabContainer",tab_cl)
		if frag.has("selected"):
			tab_st=ThemeParser.create_stylebox(frag,TB_SELECTED,button_colorsets[BS_NORMAL],tab_st,std_image)
			if frag.has("overlap"):
				tab_st=tab_st.duplicate()
				tab_st.expand_margin_bottom=ThemeParser.typesafe_get(frag,"overlap",0)
			theme.set_stylebox("tab_fg","TabContainer",tab_st)
			theme.set_color("font_color_fg","TabContainer",ThemeParser.parse_color(ThemeParser.typesafe_get(frag,TB_SELECTED,{}),"color",tab_cl))
		else:
			theme.set_stylebox("tab_fg","TabContainer",tab_st)
			theme.set_color("font_color_fg","TabContainer",tab_cl)
	else:
		theme.set_stylebox("tab_bg","TabContainer",panel_st[BS_NORMAL])
		theme.set_color("font_color_bg","TabContainer",std_colors[CO_DEFAULT_FG])
		theme.set_stylebox("tab_fg","TabContainer",panel_st[BS_NORMAL])
		theme.set_color("font_color_fg","TabContainer",std_colors[CO_DEFAULT_FG])
		theme.set_font("font","TabContainer",std_font)


func set_button_styles(data:Dictionary,key:String,node_type:String)->void:
	theme.set_stylebox("focus",node_type,EMPTY_STYLEBOX)
	var but_st:Dictionary={
		BS_NORMAL:ThemeParser.create_sb_flat({},button_colorsets[BS_NORMAL],panel_st[BS_NORMAL])
	}
	var but_cl:Dictionary={
		BS_NORMAL:std_colors[CO_DEFAULT_FG],
		BS_DISABLED:std_colors[CO_FADED_FG],
		BS_HOVER:std_colors[CO_DEFAULT_BG],
		BS_PRESSED:std_colors[CO_DEFAULT_BG]
	}
	theme.set_constant("hseparation",node_type,0)
	var frag:Dictionary=ThemeParser.typesafe_get(data,key,{})
	if not frag.empty():
		theme.set_font("font",node_type,ThemeParser.parse_font(frag,"font",std_font))
		for st in [BS_NORMAL,BS_DISABLED,BS_HOVER,BS_PRESSED]:
			but_st[st]=ThemeParser.create_stylebox(frag,st,button_colorsets[st],but_st[BS_NORMAL],std_image)
			but_cl[st]=ThemeParser.parse_color(ThemeParser.typesafe_get(frag,st,{}),"color",button_colorsets[st]["fg"])
	for st in but_st:
		theme.set_stylebox(st,node_type,but_st[st])
		theme.set_color("font_color" if st==BS_NORMAL else "font_color_"+st,node_type,but_cl[st])
		# Undocumented (but handy) theme color
		theme.set_color("icon_color_"+st,node_type,but_cl[st])

