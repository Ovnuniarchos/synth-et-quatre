extends CanvasLayer

var vars={}
onready var bg=$C
onready var label=$C/Debug

func set_var(k:String,v,t:float=-1.0)->void:
	vars[k]=[v,t,t>0.0]
	if t>0.0:
		set_process(true)
	upd()

func unset_var(k:String)->void:
	vars.erase(k)
	upd()

func upd()->void:
	var t:PoolStringArray=PoolStringArray()
	for k in vars:
		t.append("%s:%s"%[k,vars[k][0]])
	label.text=t.join("\n")
	bg.rect_size.y=label.rect_size.y
	if bg.anchor_bottom==1:
		bg.margin_top=-label.rect_size.y

func _process(delta:float)->void:
	var active:bool=false
	var modlist:bool=false
	for k in vars:
		if vars[k][2]:
			vars[k][1]-=delta
			if vars[k][1]>0.0:
				active=true
			else:
				vars.erase(k)
				modlist=true
	if not active:
		set_process(false)
	if modlist:
		upd()

