extends Reference
class_name Instrument

var name:String="Instrument"

func duplicate()->Instrument:
	var ni:Instrument=get_script().new()
	ni.name=name
	return ni
