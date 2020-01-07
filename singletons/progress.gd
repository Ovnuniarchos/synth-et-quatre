extends CanvasLayer


func _ready()->void:
	$Bar.hide()

func start()->void:
	$Bar.value=0.0
	FADER.show(self)
	$Bar.show()

func end()->void:
	$Bar.hide()
	FADER.hide(self)

func set_value(v:float)->void:
	$Bar.value=v
