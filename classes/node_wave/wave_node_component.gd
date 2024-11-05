extends Resource
class_name WaveNodeComponent


var viz_rect:Rect2
var size_po2:int setget set_size_po2
var size:int
var size_mask:int
var range_from:float=0.0
var range_length:float=1.0
var output:Array
var output_valid:bool
var inputs:Array

var _decay:float
var _last_value:float


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
		size_mask=size-1
		output_valid=false


func clear_array(arr:Array,new_size:int,value:float=0.0)->void:
	arr.resize(new_size)
	arr.fill(value)


func fill_out_of_region(region_sz:int,optr:int,input_values:Array,isolate_values:Array)->void:
	region_sz=size-region_sz
	for i in region_sz:
		if isolate_values[optr]<0.5:
			output[optr]=input_values[optr]
		optr=(optr+1)&size_mask


func calculate_slot(result:Array,slot:Array,selected_value:float)->void:
	clear_array(result,size,selected_value if slot.empty() else NAN)
	if slot.empty():
		return
	for inp in slot:
		var in_val:Array=inp.calculate()
		for optr in size:
			if not is_nan(in_val[optr]):
				result[optr]=(0.0 if is_nan(result[optr]) else result[optr])+in_val[optr]
	for optr in size:
		if is_nan(result[optr]):
			result[optr]=selected_value


func calculate_diffuse_boolean_slot(result:Array,slot:Array,selected_value:float)->void:
	calculate_slot(result,slot,selected_value)
	for optr in size:
		result[optr]=clamp(abs(result[optr]),0.0,1.0)


func calculate_boolean_slot(result:Array,slot:Array,selected_value:float)->void:
	calculate_slot(result,slot,selected_value)
	for optr in size:
		if not is_nan(result[optr]):
			result[optr]=float(abs(result[optr])>=0.5)


func calculate_option_slot(result:Array,slot:Array,values:Array,selected_value:float)->void:
	var vsz:float=values.size()
	selected_value=range_lerp(selected_value,0.0,vsz,0.0,1.0)
	calculate_slot(result,slot,selected_value)
	for optr in size:
		if not is_nan(result[optr]):
			result[optr]=values[clamp(lerp(0.0,vsz,abs(result[optr])),0.0,vsz-1)]


func reset_decay()->void:
	_last_value=0.0
	_decay=1.0


func calculate_decay(new_value:float,decay_value:float,cycle_size:float)->float:
	var t:float=new_value-_last_value
	if abs(t)<0.0001 or sign(t)!=sign(new_value):
		_decay=max(0.0,_decay-(pow(decay_value,4.0)*128.0/cycle_size))
	else:
		_decay=1.0
	_last_value=new_value
	return new_value*_decay


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
	if not (is_equal_approx(range_from,other.range_from)\
		and is_equal_approx(range_length,other.range_length)):
		return false
	for i in inputs.size():
		if other.inputs[i].size()!=inputs[i].size():
			return false
		for j in inputs[i].size():
			if not other.inputs[i][j].equals(inputs[i][j]):
				return false
	return true


func are_equal_approx(other:WaveNodeComponent,props:Array)->bool:
	var a
	var b
	var t:int
	for p in props:
		a=get(p)
		b=other.get(p)
		t=typeof(a)
		if t!=TYPE_INT and t!=TYPE_REAL and t!=TYPE_ARRAY:
			breakpoint
		if (t==TYPE_REAL and not is_equal_approx(a,b))\
			or (t==TYPE_INT and a!=b):
			return false
		elif t==TYPE_ARRAY:
			for i in a.size():
				t=typeof(a[i])
				if t!=TYPE_INT and t!=TYPE_REAL:
					breakpoint
				if (t==TYPE_INT and a[i]!=b[i])\
					or (t==TYPE_REAL and not is_equal_approx(a[i],b[i])):
					return false
	return true

func flat_components()->Array:
	var comps:Dictionary={}
	for i in inputs:
		for c in i:
			comps[c]=true
	return comps.keys()
