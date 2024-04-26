extends Resource
class_name MacroInfo


enum{BMODE_ABS,BMODE_REL,BMODE_SWABS,BMODE_SWREL,BMODE_MASK,BMODE_SELECT}
enum{MODE_MASK=-1,MODE_ABS,MODE_REL,MODE_UNK}

const MODES:Array=[
	MODE_ABS,MODE_REL,MODE_UNK,MODE_UNK,MODE_MASK,MODE_ABS
]

var min_value:int
var max_value:int
var mode:int


func _init(be:Node)->void:
	if be.get("min_value_rel")==null:
		return
	mode=MODES[be.get("mode")]
	if mode==MODE_UNK:
		mode=MODE_REL if be.get("relative") else MODE_ABS
	if mode==MODE_REL:
		min_value=be.get("min_value_rel")
		max_value=be.get("max_value_rel")
	else:
		min_value=be.get("min_value_abs")
		max_value=be.get("max_value_abs")
