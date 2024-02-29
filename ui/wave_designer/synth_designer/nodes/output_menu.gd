extends OptionButton


const OUTPUTS:Array=[
	"WAVED_STD_OUTPUT_OFF",
	"WAVED_STD_OUTPUT_REPLACE",
	"WAVED_STD_OUTPUT_ADD",
	"WAVED_STD_OUTPUT_AM",
	"WAVED_STD_OUTPUT_XM"
]


func _ready():
	for i in OUTPUTS.size():
		add_item(tr(OUTPUTS[i]),i)

