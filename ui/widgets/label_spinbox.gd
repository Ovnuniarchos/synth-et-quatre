tool extends HBoxContainer
class_name LabelSpinBox

signal value_changed(value)

export (String) var label:String="Label" setget set_label
export (float) var min_value:float=0.0 setget set_min_value
export (float) var max_value:float=100.0 setget set_max_value
export (float) var step:float=1.0 setget set_step

var value:float=0.0

func _ready()->void:
	set_label(label)
	set_min_value(min_value)
	set_max_value(max_value)
	set_step(step)
	set_value(value)

func set_label(t:String)->void:
	label=t
	if $Label:
		$Label.text=t

func set_value(v:float)->void:
	value=stepify(clamp(v,min_value,max_value),step)
	if $Value:
		$Value.value=value
	property_list_changed_notify()

func set_min_value(v:float)->void:
	min_value=v
	if $Value:
		$Value.min_value=v
	set_value(stepify(clamp(value,min_value,max_value),step))

func set_max_value(v:float)->void:
	max_value=v
	if $Value:
		$Value.max_value=v
	set_value(stepify(clamp(value,min_value,max_value),step))

func set_step(v:float)->void:
	step=v
	if $Value:
		$Value.step=v
	set_value(stepify(clamp(value,min_value,max_value),step))

func _on_value_changed(v:float)->void:
	set_value(v)
	emit_signal("value_changed",value)
