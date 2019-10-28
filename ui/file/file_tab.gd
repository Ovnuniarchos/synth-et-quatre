extends Tabs


func _on_Save_pressed()->void:
	var f:ChunkedFile=ChunkedFile.new()
	f.open(".songs/tmp.txt",File.WRITE)
	GLOBALS.song.serialize(f)
	f.close()

func _on_Load_pressed():
	var f:ChunkedFile=ChunkedFile.new()
	f.open(".songs/tmp.txt",File.READ)
	var new_song:Song=GLOBALS.song.deserialize(f)
	f.close()
	if new_song!=null:
		GLOBALS.song=new_song

func _on_CleanPats_pressed():
	GLOBALS.song.clean_patterns()
