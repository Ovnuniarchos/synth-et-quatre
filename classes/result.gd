extends Reference
class_name Result


const ERR_MSGS:Dictionary={
	OK:"ERR_OK"
}


var error:int
var error_data:Dictionary
var data


func _init(errn:int=OK,res_data=null)->void:
	error=errn
	if errn==OK:
		data=res_data
		error_data={}
	else:
		error_data=res_data
		data=null


func get_message()->String:
	if error==OK:
		return tr(ERR_MSGS[OK])
	elif error in ERR_MSGS:
		return tr(ERR_MSGS[error]).format(error_data)
	else:
		return tr("ERR_BUG").format({"s_data":String(error_data)})


func has_error()->bool:
	return error!=OK


func _to_string()->String:
	return "{error:%d,error_data:%s,data:%s}"%[error,error_data,data]
