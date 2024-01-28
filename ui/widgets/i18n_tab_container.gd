tool extends TabContainer


func _ready()->void:
	if Engine.editor_hint:
		for t in get_children():
			t.connect("title_changed",self,"_on_tab_title_changed")
	for t in get_children():
		_on_tab_title_changed(t.get_index(),t.get("title"))


func _on_tab_title_changed(index:int,title:String)->void:
	set_tab_title(index,tr(title))
