extends Reference
class_name IOSong


func obj_load(path:String)->void:
	var f:ChunkedFile=ChunkedFile.new()
	f.open(path,File.READ)
	var new_song:Song=GLOBALS.song.deserialize(f)
	f.close()
	if new_song!=null:
		new_song.file_name=path.get_file()
		AUDIO.tracker.stop()
		AUDIO.tracker.reset()
		GLOBALS.set_song(new_song)


func obj_save(path:String)->void:
	var f:ChunkedFile=ChunkedFile.new()
	f.open(path,File.WRITE)
	GLOBALS.song.serialize(f)
	GLOBALS.song.file_name=path.get_file()
	f.close()
