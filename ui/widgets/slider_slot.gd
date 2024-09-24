tool extends HBoxContainer


signal value_changed(value)


const DEFAULTS:Array=[
	null,
	{"label":"NODE_FREQUENCY_PORT","big":5,"huge":20,"decs":2,"min":-32,"max":32,"val":1},
	{"label":"NODE_AMPLITUDE_PORT","big":5,"huge":20,"decs":2,"min":-1,"max":1,"val":1},
	{"label":"NODE_PHI0_PORT","big":5,"huge":20,"decs":2,"min":-1,"max":1,"val":0},
	{"label":"NODE_POWER_PORT","big":100,"huge":500,"decs":2,"min":0,"max":500,"val":1},
	{"label":"NODE_DECAY_PORT","big":5,"huge":20,"decs":2,"min":0,"max":1,"val":0},
	{"label":"NODE_DC_OFFSET_PORT","big":5,"huge":20,"decs":2,"min":-1,"max":1,"val":0},
	{"label":"NODE_RANGE_FROM_PORT","big":5,"huge":20,"decs":2,"min":-1,"max":1,"val":0},
	{"label":"NODE_RANGE_LEN_PORT","big":5,"huge":20,"decs":2,"min":0,"max":1,"val":1},
]

export (int,
	"Custom","Frequency","Amplitude","Phi0","Power","Decay","DCOffset","RangeFrom","RangeLength"
	) var type:int=0 setget set_type
export (String) var label:String setget set_label
export (String) var tooltip:String setget set_tooltip
export (float) var big_step:float=5.0 setget set_big_step
export (float) var huge_step:float=20.0 setget set_huge_step
export (int,0,4) var _decimals:int=2 setget set_decimals
export (float) var min_value:float=-1.0 setget set_min_value
export (float) var max_value:float=1.0 setget set_max_value
export (float) var value:float=0.0 setget set_value
export (bool) var clamp_lo:bool=true setget set_clamp_lo
export (bool) var clamp_hi:bool=true setget set_clamp_hi


func _ready()->void:
	set_type(type)


func set_type(t:int)->void:
	type=t
	if DEFAULTS[t]!=null:
		set_label(DEFAULTS[t]["label"])
		set_tooltip(DEFAULTS[t]["label"]+"_TTIP")
		set_big_step(DEFAULTS[t]["big"])
		set_huge_step(DEFAULTS[t]["huge"])
		set_decimals(DEFAULTS[t]["decs"])
		set_min_value(DEFAULTS[t]["min"])
		set_max_value(DEFAULTS[t]["max"])
		set_value(DEFAULTS[t]["val"])
		set_clamp_lo(true)
		set_clamp_hi(true)
		property_list_changed_notify()


func set_label(t:String)->void:
	label=t
	if not is_node_ready():
		yield(self,"ready")
	$Label.text=t


func set_tooltip(t:String)->void:
	tooltip=t
	if not is_node_ready():
		yield(self,"ready")
	$Label.hint_tooltip=t


func set_big_step(v:float)->void:
	big_step=v
	if not is_node_ready():
		yield(self,"ready")
	$SpinBar.big_step=v


func set_huge_step(v:float)->void:
	huge_step=v
	if not is_node_ready():
		yield(self,"ready")
	$SpinBar.huge_step=v


func set_decimals(v:int)->void:
	_decimals=v
	if not is_node_ready():
		yield(self,"ready")
	$SpinBar._decimals=v


func set_min_value(v:float)->void:
	min_value=v
	if not is_node_ready():
		yield(self,"ready")
	$SpinBar.min_value=v


func set_max_value(v:float)->void:
	max_value=v
	if not is_node_ready():
		yield(self,"ready")
	$SpinBar.max_value=v


func set_value(v:float)->void:
	value=v
	if not is_node_ready():
		yield(self,"ready")
	$SpinBar.set_value_no_signal(v)


func set_clamp_lo(b:bool)->void:
	clamp_lo=b
	if not is_node_ready():
		yield(self,"ready")
	$SpinBar.set_allow_lesser(not clamp_lo)


func set_clamp_hi(b:bool)->void:
	clamp_hi=b
	if not is_node_ready():
		yield(self,"ready")
	$SpinBar.set_allow_greater(not clamp_hi)


func get_label_control()->Label:
	return $Label as Label


func _on_SpinBar_value_changed(v:float)->void:
	value=v
	emit_signal("value_changed",value)
