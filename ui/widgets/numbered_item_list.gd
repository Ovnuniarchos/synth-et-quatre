extends ItemList
class_name NumberedItemList

export (int) var digits:int=2 setget set_digits
export (bool) var hex:bool=true setget set_hex

var _pat:String="%02X %s"
var item_marked:Array=[]

func _init()->void:
	GLOBALS.array_fill(item_marked,false,get_item_count())

func _ready()->void:
	renumber()

func add_item(text:String,icon:Texture=null,selectable:bool=true)->void:
	.add_item(_pat%[get_item_count(),text],icon,selectable)
	item_marked.append(true)

func add_icon_item(icon:Texture,selectable:bool=true)->void:
	add_item("",icon,selectable)

func set_item_text(index:int,text:String)->void:
	.set_item_text(index,_pat%[index,text])

func remove_item(index:int)->void:
	.remove_item(index)
	item_marked.remove(index)
	renumber()

func select(index:int,single:bool=true)->void:
	if index==-1:
		unselect_all()
	else:
		.select(index,single)

#

func renumber()->void:
	for i in range(0,get_item_count()):
		if item_marked[i]:
			.set_item_text(i,_pat%[i,get_item_text(i).right(digits+1)])
		else:
			.set_item_text(i,_pat%[i,get_item_text(i)])
			item_marked[i]=true

func set_digits(n:int)->void:
	digits=1 if n<1 else n
	set_pattern()

func set_hex(h:bool)->void:
	hex=h
	set_pattern()

func set_pattern()->void:
	_pat="%0"+str(digits)+("X" if hex else "d")+" %s"
	renumber()
