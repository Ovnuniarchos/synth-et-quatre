extends Reference
class_name Waveform

signal name_changed(wave,name)

var data:Array=[]
var size_po2:int=8 setget set_size
# warning-ignore:unused_class_variable
var name:String="" setget set_name

func _init()->void:
	resize_data(1<<size_po2)

func set_name(n:String)->void:
	name=n
	emit_signal("name_changed",self,n)

func set_size(s:int)->void:
	size_po2=int(clamp(s,4.0,16.0))
	resize_data(1<<size_po2)

func get_byte_size()->int:
	return 1<<size_po2

func resize_data(new_size:int)->void:
	var old_size:int=data.size()
	data.resize(new_size)
	if new_size>old_size:
		for i in range(old_size,new_size):
			data[i]=0.0

func duplicate()->Waveform:
	var nw:Waveform=get_script().new()
	nw.name=name
	nw.size_po2=size_po2
	nw.data=data.duplicate()
	return nw

func equals(other:Waveform)->bool:
	# Name is irrelevant
	return size_po2!=other.size_po2
