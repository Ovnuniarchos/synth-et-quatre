extends CanvasLayer

var dialogs:Array=[]
var active:bool=false

func _ready()->void:
	hide_fader(null)

func hide_fader(dlg:Node)->void:
	close_dialog(dlg)
	if dialogs.empty():
		$Fader.hide()

func show_fader(dlg:Node)->void:
	open_dialog(dlg)
	$Fader.show()

func open_dialog(dlg:Node)->void:
	if dlg!=null and !(dlg in dialogs):
		dialogs.append(dlg)
	active=true

func close_dialog(dlg:Node)->void:
	if dlg!=null and (dlg in dialogs):
		dialogs.erase(dlg)
	if dialogs.empty():
		active=false
