extends Reference
class_name Instrument

var name:String="Instrument"

func duplicate()->Instrument:
	var ni:Instrument=get_script().new()
	ni.name=name
	return ni

# warning-ignore:unused_argument
# Deprecated
func uses_waveform(w_ix:int)->bool:
	return false

# warning-ignore:unused_argument
func delete_waveform(w_ix:int)->void:
	pass
