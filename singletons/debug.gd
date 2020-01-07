extends CanvasLayer

var vars={}
onready var bg=$C
onready var label=$C/Debug

func set_var(k:String,v)->void:
	vars[k]=v
	upd()

func unset_var(k:String)->void:
	vars.erase(k)
	upd()

func upd()->void:
	var t:PoolStringArray=PoolStringArray()
	for k in vars:
		t.append("%s:%s"%[k,vars[k]])
	label.text=t.join("\n")
	bg.rect_size.y=label.rect_size.y
	if bg.anchor_bottom==1:
		bg.margin_top=-label.rect_size.y
