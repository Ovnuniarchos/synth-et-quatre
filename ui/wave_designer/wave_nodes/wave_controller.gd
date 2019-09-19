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
var title_node:HBoxContainer
var from_node:SpinBox

func get_component_index(wc:WaveComponent)->int:
	return wave.components.find(wc)

func adjust_max_node_from()->void:
	if from_node!=null:
		from_node.max_value=wave.components.size()-1
