tool extends VBoxContainer


signal routing_changed(value,from_op,to_op)


export (int,0,3) var from_op=1 setget set_from


func _ready()->void:
	set_from(from_op)


func set_from(v:int)->void:
	from_op=v
	$Routing/Title.text="OP %d"%[from_op+1]
	var s:String
	for i in 4:
		s=tr("FMED_OPXY_TTIP")%[from_op+1,i+1] if from_op!=i else tr("FMED_OPXX_TTIP")%[i+1]
		get_node("Routing/OP%dLabel"%[i+1]).hint_tooltip=s
		get_node("Routing/OP%dSlider"%[i+1]).hint_tooltip=s
	s=tr("FMED_OUTX_TTIP")%[from_op+1]
	get_node("Routing/OutLabel").hint_tooltip=s
	get_node("Routing/OutSlider").hint_tooltip=s


func _on_Slider_value_changed(value:float,to:int)->void:
	emit_signal("routing_changed",value,from_op,to)


func set_routing(to:int,v:float)->void:
	var r:Range
	if to>=0 and to<4:
		r=get_node("Routing/OP"+String(to+1)+"Slider")
	else:
		r=get_node("Routing/OutSlider")
	r.value=v
