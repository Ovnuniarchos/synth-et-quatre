extends CanvasLayer


func _ready()->void:
	$C/Bar.hide()
	$C/Bar.theme=ThemeHelper.get_theme()

func start()->void:
	$C/Bar.value=0.0
	FADER.show_fader(self)
	$C/Bar.show()

func end()->void:
	$C/Bar.hide()
	FADER.hide_fader(self)

func set_value(v:float)->void:
	$C/Bar.value=v
