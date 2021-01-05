extends Control


func _ready():
	theme=THEME.theme
	$FileDialog.notification(NOTIFICATION_ENTER_TREE)


func _on_Button_pressed():
	$AcceptDialog.popup_centered_ratio()


func _on_Button2_pressed():
	$FileDialog.popup_centered_ratio()
