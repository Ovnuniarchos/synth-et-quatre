tool extends Tabs


signal title_changed(index,title)


export (String) var title:String="" setget set_title


func set_title(t:String)->void:
	title=t
	emit_signal("title_changed",get_index(),title)
	
