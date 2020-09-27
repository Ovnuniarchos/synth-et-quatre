extends Reference
class_name Waveform

signal name_changed(wave,name)

var data:Array=[]
var size:int=0
# warning-ignore:unused_class_variable
var name:String="" setget set_name

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

func equals(other:Waveform)->bool:
	# Name is irrelevant
	return size!=other.size
