extends Object
class_name ThemeParser


enum{FC_TOPLEFT,FC_TOPRIGHT,FC_BOTTOMRIGHT,FC_BOTTOMLEFT}
enum{FS_TOP,FS_RIGHT,FS_BOTTOM,FS_LEFT}
enum{DIM_X,DIM_Y}


const SP_HORIZONTAL:String="horizontal"
const SP_VERTICAL:String="vertical"
const TYPE_NUMBER:Array=[TYPE_REAL,TYPE_INT]
const BT_FLAT:String="flat"
const BT_BITMAP:String="bitmap"
const BOX_TYPES:Dictionary={
	BT_FLAT:0,
	BT_BITMAP:1
}
const SM_STRETCH:String="stretch"
const SM_TILE:String="tile"
const SM_FIT:String="fit"
const STRETCH_MODES:Dictionary={
	SM_STRETCH:StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH,
	SM_TILE:StyleBoxTexture.AXIS_STRETCH_MODE_TILE,
	SM_FIT:StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
}
const HM_NONE:String="none"
const HM_LIGHT:String="light"
const HM_NORMAL:String="normal"
const HINT_MODES:Dictionary={
	HM_NONE:DynamicFontData.HINTING_NONE,
	HM_LIGHT:DynamicFontData.HINTING_LIGHT,
	HM_NORMAL:DynamicFontData.HINTING_NORMAL
}


static func typesafe_get(d:Dictionary,key:String,default):
	var ret=d.get(key,default)
	if typeof(ret)==typeof(default):
		return ret
	elif typeof(ret) in TYPE_NUMBER and typeof(default) in TYPE_NUMBER:
		return ret
	return default


static func parse_boolean(d:Dictionary,key:String,default:bool)->bool:
	var ret=d.get(key)
	if typeof(ret)==TYPE_BOOL:
		return ret
	elif typeof(ret) in TYPE_NUMBER:
		return bool(ret)
	elif typeof(ret)==TYPE_STRING:
		return ret.to_lower() in ["yes","true","on"]
	return default


static func parse_color(data:Dictionary,key:String,default:Color)->Color:
	var t:int=typeof(data.get(key,false))
	if t==TYPE_STRING:
		var c:String=data.get(key)
		if c.is_valid_html_color():
			return Color(c)
		return ColorN(c.to_lower().replace(" ",""))
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


static func parse_sides_corners(data:Dictionary,key:String,default:float)->Array:
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


static func parse_rectangle(data:Dictionary,key:String,default:float)->Array:
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


static func parse_string_list(data:Dictionary,key:String,max_length:int,default:String)->Array:
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


static func parse_number_list(data:Dictionary,key:String,max_length:int,default:float)->Array:
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


static func parse_names(name:String,names:Dictionary,default:int)->int:
	return typesafe_get(names,name.to_lower(),default)


static func parse_spacing(data:Dictionary,key:String,defaults:Array)->Dictionary:
	var frag:Dictionary=typesafe_get(data,key,{})
	return {
		SP_HORIZONTAL: typesafe_get(frag,SP_HORIZONTAL,defaults[0]),
		SP_VERTICAL: typesafe_get(frag,SP_VERTICAL,defaults[1])
	}


static func create_stylebox(data:Dictionary,key:String,colorset:Dictionary,default:StyleBox)->StyleBox:
	var frag:Dictionary=typesafe_get(data,key,{})
	if frag.empty():
		return create_sb_flat({},colorset,null) if default==null else default
	var t:int=parse_names(typesafe_get(frag,"type",BT_FLAT),BOX_TYPES,-1)
	if t==-1:
		if default is StyleBoxTexture:
			t=BOX_TYPES[BT_BITMAP]
		else:
			t=BOX_TYPES[BT_FLAT]
	if t==BOX_TYPES[BT_FLAT]:
		return create_sb_flat(frag,colorset,default as StyleBoxFlat)
	else:
		return create_sb_bitmap(frag)


static func create_sb_flat(data:Dictionary,colorset:Dictionary,base:StyleBoxFlat)->StyleBoxFlat:
	var def_fg:Color=colorset["fg"]
	var def_bg:Color=colorset["bg"]
	var st:StyleBoxFlat=StyleBoxFlat.new() if base==null else base.duplicate()
	if data.has("background") or base==null:
		st.bg_color=parse_color(data,"background",def_bg)
	else:
		st.bg_color=def_bg
	var values:Array
	if data.has("corner-radius") or base==null:
		values=parse_sides_corners(data,"corner-radius",0.0)
		st.corner_radius_top_left=values[FC_TOPLEFT]
		st.corner_radius_top_right=values[FC_TOPRIGHT]
		st.corner_radius_bottom_right=values[FC_BOTTOMRIGHT]
		st.corner_radius_bottom_left=values[FC_BOTTOMLEFT]
		st.corner_detail=8 if values.max()>0.0 else 0
	if data.has("antialias") or base==null:
		st.anti_aliasing=parse_boolean(data,"antialias",values.max()>0.0)
	if data.has("border") or base==null:
		st.border_color=parse_color(data,"border",def_fg)
	else:
		st.border_color=def_fg
	if data.has("border-width") or base==null:
		values=parse_sides_corners(data,"border-width",2.0)
		st.border_width_top=values[FS_TOP]
		st.border_width_right=values[FS_RIGHT]
		st.border_width_bottom=values[FS_BOTTOM]
		st.border_width_left=values[FS_LEFT]
	if data.has("margin") or base==null:
		values=parse_sides_corners(data,"margin",-1.0)
		st.content_margin_top=values[FS_TOP]
		st.content_margin_right=values[FS_RIGHT]
		st.content_margin_bottom=values[FS_BOTTOM]
		st.content_margin_left=values[FS_LEFT]
	return st


static func create_sb_bitmap(data:Dictionary={})->StyleBoxTexture:
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
	values=parse_string_list(data,SM_STRETCH,2,SM_STRETCH)
	st.axis_stretch_horizontal=parse_names(values[0],STRETCH_MODES,STRETCH_MODES[SM_STRETCH])
	st.axis_stretch_vertical=parse_names(values[1],STRETCH_MODES,STRETCH_MODES[SM_STRETCH])
	return st


static func rotate_content_margin(sb:StyleBox)->StyleBox:
	var sb2:StyleBox=sb.duplicate()
	sb2.content_margin_top=sb.content_margin_left
	sb2.content_margin_right=sb.content_margin_top
	sb2.content_margin_bottom=sb.content_margin_right
	sb2.content_margin_left=sb.content_margin_bottom
	return sb2


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


static func set_styles(theme:Theme,from:String,to:Control)->void:
	if theme==null:
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


static func parse_font(data:Dictionary,tag:String,base:DynamicFont)->DynamicFont:
	var frag:Dictionary=typesafe_get(data,tag,{})
	if not frag.empty():
		var fnt:DynamicFont=DynamicFont.new() if base==null else base.duplicate()
		var dfd:DynamicFontData
		dfd=resource_load("res://theme/"+typesafe_get(frag,"file",""),"DynamicFontData",fnt.font_data)
		fnt.font_data=dfd
		fnt.size=typesafe_get(frag,"size",14 if base==null else base.size)
		fnt.outline_size=typesafe_get(frag,"outline-size",0 if base==null else base.outline_size)
		fnt.outline_color=parse_color(frag,"outline",Color.white if base==null else base.outline_color)
		if fnt.font_data!=null:
			fnt.font_data.antialiased=typesafe_get(frag,"antialias",true)
			fnt.font_data.hinting=parse_names(typesafe_get(frag,"hinting",HM_NORMAL),HINT_MODES,HINT_MODES[HM_NORMAL])
		return fnt
	return base


static func resource_load(path:String,type:String,default:Resource)->Resource:
	var dir:Directory=Directory.new()
	if dir.file_exists(path):
		var r:Resource=load(path)
		return r if r.get_class()==type else default
	return default


static func parse_glyph(data:Dictionary,default:StreamTexture)->AtlasTexture:
	var at:AtlasTexture=null
	var img:Texture=resource_load("res://theme/"+typesafe_get(data,"file",""),"StreamTexture",default)
	if img==null:
		return null
	at=AtlasTexture.new()
	at.atlas=img
	at.filter_clip=true
	var rect:Array=parse_rectangle(data,"rect",-1.0)
	if rect.min()<0.0:
		return null
	at.region=Rect2(rect[0],rect[1],rect[2],rect[3])
	var margin:Array=parse_number_list(data,"margin",2,0.0)
	var offset:Array=parse_number_list(data,"offset",2,0.0)
	at.margin=Rect2(offset[0]+margin[0],offset[1]+margin[1],margin[0]*2.0,margin[1]*2.0)
	return at
