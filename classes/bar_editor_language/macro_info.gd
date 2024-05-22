extends Resource
class_name MacroInfo


enum{BMODE_ABS,BMODE_REL,BMODE_SWABS,BMODE_SWREL,BMODE_MASK,BMODE_SELECT}
enum{MODE_SEL=-2,MODE_MASK,MODE_ABS,MODE_REL,MODE_TBD}

const MODES:Array=[
	MODE_ABS,MODE_REL,MODE_TBD,MODE_TBD,MODE_MASK,MODE_SEL
]

var min_value:int
var max_value:int
var mode:int
var values:Array


func _init(be:Node)->void:
	if be==null or be.get("min_value_rel")==null:
		return
	mode=MODES[be.get("mode")]
	if mode==MODE_TBD:
		mode=MODE_REL if be.get("relative") else MODE_ABS
	if mode==MODE_REL:
		min_value=be.get("min_value_rel")
		max_value=be.get("max_value_rel")
	else:
		min_value=be.get("min_value_abs")
		max_value=be.get("max_value_abs")
	values=be.get("values")


func can_use_alpha()->bool:
	return mode>=MODE_ABS
