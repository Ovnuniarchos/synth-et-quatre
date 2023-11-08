extends Reference
class_name Instrument

var name:String="Instrument"
# Transient
var file_name:String=""

func duplicate()->Instrument:
	var ni:Instrument=get_script().new()
	ni.name=name
	return ni

func copy(from:Instrument,full:bool=false)->void:
	if full:
		name=from.name

# warning-ignore:unused_argument
func delete_waveform(w_ix:int)->void:
	pass
