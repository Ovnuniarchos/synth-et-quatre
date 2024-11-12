extends LineEdit
class_name NumberEdit

signal value_changed(value)


export (int) var min_value:int=0 setget set_min_val
export (int) var max_value:int=255 setget set_max_val
export (int) var _decimals:int=0 setget set_decimals
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


func set_decimals(v:int)->void:
	_decimals=v
	adjust_length()


func set_negative(v:bool)->void:
	negative=v or min_value<0 or max_value<0
	adjust_length()


func adjust_length()->void:
	max_length=1+ceil(log(max(abs(max_value),abs(min_value)))/log(10.0))+_decimals+int(_decimals>0)+int(negative)
	add_constant_override("minimum_spaces",max_length)


func _on_text_changed(nt:String,invalid_brk:bool)->void:
	var opos:int=caret_position
	var nt2:String=""
	var c2:int
	var pos:int=0
	var decs:int=_decimals
	var int_mode:bool=true
	for c in nt:
		c2=ord(c)
		if decs>0 and c2==0x2E and int_mode:
			nt2+=c
			int_mode=false
		elif negative and c2==0x2D and pos==0:
			nt2+=c
		elif c2>=0x30 and c2<=0x39:
			if int_mode or decs>0:
				nt2+=c
				if not int_mode:
					decs-=1
		elif invalid_brk:
			break
		pos+=1
	text=nt2
	caret_position=min(opos,nt2.length())


func _on_text_entered(nt:String)->void:
	set_block_signals(true)
	_on_text_changed(nt,true)
# warning-ignore:incompatible_ternary
	var v=float(text) if _decimals>0 else int(text)
	text=("%f" if _decimals>0 else "%d")%v
	set_block_signals(false)
	emit_signal("value_changed",v)


func get_value()->float:
	return float(text)


func set_value_no_signal(v:float)->void:
	set_block_signals(true)
	_on_text_changed("%f"%v,true)
	set_block_signals(false)
