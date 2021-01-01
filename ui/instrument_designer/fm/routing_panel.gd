tool extends VBoxContainer


signal routing_changed(value,from_op,to_op)


export (int,0,3) var from_op=1 setget set_from


func _ready()->void:
	$Title.text="OP %d" % (from_op+1)


func set_from(v:int)->void:
	from_op=v
	$Title.text="OP %d" % (from_op+1)


func _on_Slider_value_changed(value:float,to:int)->void:
	emit_signal("routing_changed",value,from_op,to)


func set_routing(to:int,v:float)->void:
	var r:Range
	if to>=0 and to<4:
		r=get_node("Routing/OP"+String(to+1)+"Slider")
	else:
		r=get_node("Routing/OutSlider")
	r.value=v
