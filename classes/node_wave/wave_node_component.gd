extends Resource
class_name WaveNodeComponent


var viz_rect:Rect2
var size_po2:int setget set_size_po2
var size:int
var output:Array
var output_valid:bool
var inputs:Array


func _init()->void:
	output=[]
	size_po2=1
	set_size_po2(8)
	inputs=[]


func set_size_po2(s:int)->void:
	s=int(clamp(s,4.0,16.0))
	if s!=size_po2:
		clear_array(output,1<<s)
		size_po2=s
		size=1<<s
		output_valid=false


func clear_array(arr:Array,new_size:int,value:float=0.0)->void:
	arr.resize(new_size)
	arr.fill(value)


func calculate_slot(result:Array,slot:Array,def_value:float)->void:
	clear_array(result,size,def_value)
	for inp in slot:
		var in_val:Array=inp.calculate()
		for optr in size:
			if not is_nan(in_val[optr]):
				result[optr]+=in_val[optr]


func calculate_option_slot(result:Array,slot:Array,values:Array,def_value:float)->void:
	clear_array(result,size,NAN)
	var vsz:float=values.size()
	def_value=range_lerp(def_value,0.0,vsz,0.0,1.0)
	for inp in slot:
		var in_val:Array=inp.calculate()
		for optr in size:
			if not is_nan(in_val[optr]):
				if is_nan(result[optr]):
					result[optr]=def_value
				result[optr]+=in_val[optr]
	for optr in size:
		result[optr]=clamp(
			lerp(0.0,vsz,def_value if is_nan(result[optr]) else result[optr]),
			0.0,vsz-1
		)


func invalidate()->void:
	output_valid=false


func connect_node(from:WaveNodeComponent,to:int)->void:
	if to>-1 and to<inputs.size() and not from in inputs[to]:
		inputs[to].append(from)
		output_valid=false


func disconnect_node(from:WaveNodeComponent,to:int)->void:
	if to>-1 and to<inputs.size() and from in inputs[to]:
		inputs[to].erase(from)
		output_valid=false


func equals(other:WaveNodeComponent)->bool:
	if other.inputs.size()!=inputs.size():
		return false
	for i in inputs.size():
		if other.inputs[i].size()!=inputs[i].size():
			return false
		for j in inputs[i].size():
			if not other.inputs[i][j].equals(inputs[i][j]):
				return false
	return true


func flat_components()->Array:
	var comps:Dictionary={}
	for i in inputs:
		for c in i:
			comps[c]=true
	return comps.keys()
