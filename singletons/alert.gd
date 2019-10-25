extends CanvasLayer

onready var fader:Panel=$Fader
onready var dlg:AcceptDialog=$Fader/Alert

var active:bool=false

func _ready():
	fader.visible=false
	dlg.get_label().valign=Label.VALIGN_CENTER

func alert(message:String)->void:
	active=true
	fader.visible=true
	dlg.dialog_text=message
	dlg.popup_centered_clamped(Vector2(512.0,128.0),0.75)

func _on_popup_hide():
	active=false
	fader.visible=false
