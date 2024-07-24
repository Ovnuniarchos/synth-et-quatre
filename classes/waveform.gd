extends Reference
class_name Waveform

signal name_changed(wave,name)


var data:Array=[]
var size:int=0
# warning-ignore:unused_class_variable
var name:String="" setget set_name
var file_name:String


func set_name(n:String)->void:
	name=n
	emit_signal("name_changed",self,n)


func resize_data(new_size:int)->void:
	var old_size:int=data.size()
	data.resize(new_size)
	if new_size>old_size:
		for i in range(old_size,new_size):
			data[i]=0.0


func duplicate()->Waveform:
	var nw:Waveform=get_script().new()
	nw.name=name
	nw.size=size
	nw.data=data.duplicate()
	return nw


func copy(from:Waveform,full:bool=false)->void:
	if full:
		name=from.name


func equals(other:Waveform)->bool:
	# Name is irrelevant
	if other.get("WAVE_TYPE")!=get("WAVE_TYPE") and get("WAVE_TYPE")!=null:
		return false
	return size==other.size
