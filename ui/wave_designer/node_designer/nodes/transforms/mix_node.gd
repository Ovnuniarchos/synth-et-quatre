extends NodeController


const OPS:Array=[
	"MIX","ADD","SUB","MUL","DIV","MOD","FMOD","POWER","MAX","MIN","CMP","SIGN_CP"
]


func _init()->void:
	node=MixNodeComponent.new()


func _ready()->void:
	for i in OPS.size():
		$Op/OptionButton.add_item("NODE_MIX_MODE_%s"%[i],i)


func set_parameters()->void:
	if not is_node_ready():
		yield(self,"ready")


func _on_Clamp_toggled(button_pressed:bool)->void:
	node.clamp_value=float(button_pressed)
	emit_signal("params_changed",self)


func _on_Op_item_selected(index:int)->void:
	node.op_value=index
	emit_signal("params_changed",self)


func _on_Mix_value_changed(value:float)->void:
	node.mix_value=value
	emit_signal("params_changed",self)
