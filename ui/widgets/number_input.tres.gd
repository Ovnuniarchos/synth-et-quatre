extends LineEdit
class_name NumberEdit

signal value_changed(value)


export (int) var min_value:int=0 setget set_min_val
export (int) var max_value:int=255 setget set_max_val
export (bool) var has_decimals:bool=false setget set_has_decimals
export (bool) var negative:bool=false setget set_negative



func _init()->void:
	connect("text_changed",self,"_on_text_changed",[false])
	connect("text_entered",self,"_on_text_entered")


func set_min_val(v:int)->void:
	min_value=v
	adjust_length()


func set_max_val(v:int)->void:
	max_value=v
	adjust_length()


func set_has_decimals(v:bool)->void:
	has_decimals=v
	adjust_length()


func set_negative(v:bool)->void:
	negative=v
	adjust_length()


func adjust_length()->void:
	max_length=ceil(log(max(abs(max_value),abs(min_value)))/log(10.0))+int(has_decimals)+int(negative)
	add_constant_override("minimum_spaces",max_length)


func _on_text_changed(nt:String,invalid_brk:bool)->void:
	var opos:int=caret_position
	var nt2:String=""
	var c2:int
	var pos:int=0
	var can_dec:bool=true
	for c in nt:
		c2=ord(c)
		if has_decimals and c2==0x2E and can_dec:
			nt2+=c
			can_dec=false
		elif negative and c2==0x2D and pos==0:
			nt2+=c
		elif c2>=0x30 and c2<=0x39:
			nt2+=c
		elif invalid_brk:
			break
		pos+=1
	text=nt2
	caret_position=min(opos,nt2.length())


func _on_text_entered(nt:String)->void:
	set_block_signals(true)
	_on_text_changed(nt,true)
	var v=float(text) if has_decimals else int(text)
	text=("%f" if has_decimals else "%d")%v
	set_block_signals(false)
	emit_signal("value_changed",v)


func get_value()->float:
	return float(text)


func set_value_no_signal(v:float)->void:
	set_block_signals(true)
	_on_text_changed("%f"%v,true)
	set_block_signals(false)
