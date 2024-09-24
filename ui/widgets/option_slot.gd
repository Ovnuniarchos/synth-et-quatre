tool extends HBoxContainer


signal item_selected(index)


export (String) var label:String setget set_label
export (String) var tooltip:String setget set_tooltip


func set_label(t:String)->void:
	label=t
	if not is_node_ready():
		yield(self,"ready")
	$Label.text=t


func set_tooltip(t:String)->void:
	tooltip=t
	if not is_node_ready():
		yield(self,"ready")
	$Label.hint_tooltip=t


func set_options(options:Array)->void:
	var opb:OptionButton=$OptionButton
	opb.clear()
	for op in options:
		opb.add_item(op['label'],op['id'])


func get_label_control()->Label:
	return $Label as Label


func select(index:int)->void:
	var opb:OptionButton=$OptionButton
	opb.set_block_signals(true)
	opb.select(index)
	opb.set_block_signals(false)


func _on_OptionButton_item_selected(index: int) -> void:
	emit_signal("item_selected",index)
