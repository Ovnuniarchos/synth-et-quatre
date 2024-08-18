extends Node
class_name WaveController

# warning-ignore:unused_signal
signal params_changed


var wave:SynthWave
# warning-ignore:unused_class_variable
var component:WaveComponent
# warning-ignore:unused_class_variable
var designer:Control
# warning-ignore:unused_class_variable
var title_node:WaveComponentTitleBar
var from_node:SpinBar


func _ready()->void:
	ThemeHelper.apply_styles_to_group(ThemeHelper.get_theme(),"LabelControl","Label")


func get_component_index(wc:WaveComponent)->int:
	return wave.components.find(wc)


func adjust_max_node_from()->void:
	if from_node!=null:
		from_node.max_value=wave.components.size()-1


func setup()->void:
	title_node.index=get_component_index(component)
	title_node.connect("delete_requested",designer,"_on_delete_requested")
	title_node.connect("move_requested",designer,"_on_move_requested")
