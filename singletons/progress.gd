extends CanvasLayer


func _ready()->void:
	$C/Bar.hide()

func start()->void:
	$C/Bar.value=0.0
	FADER.show(self)
	$C/Bar.show()

func end()->void:
	$C/Bar.hide()
	FADER.hide(self)

func set_value(v:float)->void:
	$C/Bar.value=v
