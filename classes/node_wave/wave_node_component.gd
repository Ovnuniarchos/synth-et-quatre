extends Reference
class_name WaveNodeComponent


const SLOT_ID:String="id"
const SLOT_IN:String="in"
enum{DE_NAN,DIFF_BOOL,BOOL,OPTION,CLAMP}


var viz_rect:Rect2
var size_po2:int setget set_size_po2
var size:int
var size_mask:int
var range_from:float=0.0
var range_length:float=1.0
var output:Array
var output_valid:bool
var inputs:Array
var wave:WeakRef

var _decay:float
var _decay_factor:float
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
		if isolate_values[optr]<0.5: output[optr]=input_values[optr]
		optr=(optr+1)&size_mask


# calculate_xxx return true if their result was already cached
func calculate_slot(result:Array,slot:Array,selected_value:float,mode:Array=[DE_NAN])->bool:
	if output_valid:
		var unchanged:bool=not result.empty()
		for inp in slot:
			unchanged=unchanged and inp.output_valid
		if unchanged:
			return true
	clear_array(result,size,selected_value if slot.empty() else NAN)
	if slot.empty():
		return false
	for inp in slot:
		NODES.accumulate(inp.calculate(),result)
	if mode[0]==DE_NAN:
		NODES.de_nan_ize(result,selected_value)
	elif mode[0]==DIFF_BOOL:
		NODES.diff_booleanize(result)
	elif mode[0]==BOOL:
		NODES.booleanize(result)
	elif mode[0]==OPTION:
		NODES.optionize(result,selected_value,mode[1])
	elif mode[0]==CLAMP:
		NODES.clamp(result,mode[1],mode[2])
	return false


func calculate_diffuse_boolean_slot(result:Array,slot:Array,selected_value:float)->bool:
	return calculate_slot(result,slot,selected_value,[DIFF_BOOL])


func calculate_boolean_slot(result:Array,slot:Array,selected_value:float)->bool:
	return calculate_slot(result,slot,selected_value,[BOOL])


func calculate_option_slot(result:Array,slot:Array,option_count:int,selected_value:float)->bool:
	return calculate_slot(result,slot,selected_value,[OPTION,option_count])


func calculate_clamped_slot(result:Array,slot:Array,selected_value:float,minval:float,maxval:float)->bool:
	return calculate_slot(result,slot,selected_value,[CLAMP,minval,maxval])


# DEPRECATE
func reset_decay(cycle_size:float)->void:
	_last_value=0.0
	_decay=1.0
	_decay_factor=128.0/max(1.0,cycle_size)


# DEPRECATE
func calculate_decay(new_value:float,decay_value:float)->float:
	var t:float=new_value-_last_value
	if abs(t)<0.00000001 or sign(t)!=sign(new_value):
		_decay=max(0.0,_decay-(pow(decay_value,4.0)*_decay_factor))
	else:
		_decay=1.0
	_last_value=new_value
	return new_value*_decay


func invalidate()->void:
	output_valid=false


func connect_node(from:WaveNodeComponent,to:int)->void:
	if to>-1 and to<inputs.size() and not from in inputs[to][SLOT_IN]:
		inputs[to][SLOT_IN].append(from)
		output_valid=false


func disconnect_node(from:WaveNodeComponent,to:int)->void:
	if to>-1 and to<inputs.size() and from in inputs[to][SLOT_IN]:
		inputs[to][SLOT_IN].erase(from)
		output_valid=false


func equals(other:WaveNodeComponent)->bool:
	if not (is_equal_approx(range_from,other.range_from)\
		and is_equal_approx(range_length,other.range_length)):
		return false
	if inputs.size()!=other.inputs.size():
		return false
	for i in inputs.size():
		if inputs[i][SLOT_ID]!=other.inputs[i][SLOT_ID]:
			return false
	var this_slot:Array
	var other_slot:Array
	for i in inputs.size():
		this_slot=inputs[i][SLOT_IN]
		other_slot=other.inputs[i][SLOT_IN]
		if this_slot.size()!=other_slot.size():
			return false
		for j in this_slot.size():
			if not this_slot[j].equals(other_slot[j]):
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


func get_slot(slot_id:String)->Dictionary:
	for i in inputs:
		if i[SLOT_ID]==slot_id:
			return i
	return {}


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:WaveNodeComponent=get_script().new()
	nc.viz_rect=viz_rect
	nc.size_po2=size_po2
	nc.range_from=range_from
	nc.range_length=range_length
	nc.wave=weakref(container)
	for slot_ix in inputs.size():
		for comp in inputs[slot_ix][SLOT_IN]:
			nc.inputs[slot_ix][SLOT_IN].append(
				container.find_component(comp)
			)
	return nc


func post_duplicate()->void:
	for slot in inputs:
		for inp_ix in slot[SLOT_IN].size():
			slot[SLOT_IN][inp_ix]=wave.get_ref().components[slot[SLOT_IN][inp_ix]]
