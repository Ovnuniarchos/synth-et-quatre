extends HBoxContainer
class_name LabelSpinBox

signal value_changed(value)

export (String) var label="Label" setget set_label
export (float) var value=0.0 setget set_value,get_value
export (float) var min_value=0.0 setget set_min_value,get_min_value
export (float) var max_value=100.0 setget set_max_value,get_max_value
export (float) var step=1.0 setget set_step,get_step

func set_label(t:String)->void:
	$Label.text=t

func set_value(v:float)->void:
	$Value.value=v

func get_value()->float:
	return $Value.value

func set_min_value(v:float)->void:
	$Value.min_value=v

func get_min_value()->float:
	return $Value.min_value

func set_max_value(v:float)->void:
	$Value.max_value=v

func get_max_value()->float:
	return $Value.max_value

func set_step(v:float)->void:
	$Value.step=v

func get_step()->float:
	return $Value.step

func _on_value_changed(v:float)->void:
	value=v
	emit_signal("value_changed",v)
