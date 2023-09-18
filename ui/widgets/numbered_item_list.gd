extends ItemList
class_name NumberedItemList

export (int) var digits:int=2 setget set_digits
export (bool) var hex:bool=true setget set_hex
export (int) var offset:int=0 setget set_offset
export (bool) var allow_deselect:bool=false

var _pat:String="%02X %s"
var _last_selection:int=-1
var item_marked:Array=[]
var signals:Array

func _init()->void:
	GLOBALS.array_fill(item_marked,false,get_item_count())

func _ready()->void:
	signals=get_signal_connection_list("item_selected")
	for sig in signals:
		disconnect("item_selected",sig.target,sig.method)
	connect("item_selected",self,"_on_item_selected")
	renumber()

func add_item(text:String,icon:Texture=null,selectable:bool=true)->void:
	.add_item(_pat%[get_item_count()+offset,text],icon,selectable)
	item_marked.append(true)

func add_icon_item(icon:Texture,selectable:bool=true)->void:
	add_item("",icon,selectable)

func set_item_text(index:int,text:String)->void:
	.set_item_text(index,_pat%[index+offset,text])

func remove_item(index:int)->void:
	.remove_item(index)
	item_marked.remove(index)
	renumber()

func select(index:int,single:bool=true)->void:
	if index==_last_selection and allow_deselect:
		index=-1
	if index==-1:
		unselect_all()
	else:
		.select(index,single)
	_last_selection=index

func ensure_current_is_visible()->void:
	.ensure_current_is_visible()
	call_deferred("fix_ensure_current_is_visible")

func fix_ensure_current_is_visible()->void:
	# Forces recalc of scroll values, fixes bug in ItemList.ensure_current_is_visible
	update()

func _draw()->void:
	# Forces recalc of scroll values, fixes bug in ItemList.ensure_current_is_visible
	notification(NOTIFICATION_DRAW,true)
	notification(NOTIFICATION_RESIZED,true)

func _on_item_selected(ix:int)->void:
	if ix==_last_selection and allow_deselect:
		ix=-1
		unselect_all()
	_last_selection=ix
	for sig in signals:
		sig.target.call(sig.method,ix)

#

func renumber()->void:
	for i in range(get_item_count()):
		if item_marked[i]:
			.set_item_text(i,_pat%[i+offset,get_item_text(i).right(digits+1)])
		else:
			.set_item_text(i,_pat%[i+offset,get_item_text(i)])
			item_marked[i]=true

func set_digits(n:int)->void:
	digits=1 if n<1 else n
	set_pattern()

func set_hex(h:bool)->void:
	hex=h
	set_pattern()

func set_offset(o:int)->void:
	offset=o
	set_pattern()

func set_pattern()->void:
	_pat="%0"+str(digits)+("X" if hex else "d")+" %s"
	renumber()
