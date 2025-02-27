tool extends HBoxContainer
class_name WaveComponentTitleBar

signal delete_requested(node)
signal move_requested(node,direction)

export (String) var title setget set_title
export (int) var index setget set_index

func _ready()->void:
	ThemeHelper.apply_styles_to_group(ThemeHelper.get_theme(),"LabelTitle","Title")

func set_title(t:String)->void:
	title=t
	set_title_string()

func set_index(i:int)->void:
	index=i
	set_title_string()

func set_title_string()->void:
	$Title.text=tr(title).format({"i_index":index})

func _on_Close_button_up():
	emit_signal("delete_requested",owner)

func _on_MoveL_button_up():
	emit_signal("move_requested",owner,-1)

func _on_MoveR_button_up():
	emit_signal("move_requested",owner,1)
