extends Reference
class_name WaveComponent

enum OUT_MODE{OFF,REPLACE,ADD,AM,XM}

var input_comp:WaveComponent=self
var output_mode:int=OUT_MODE.ADD
var vol:float=1.0
var generated:Array=[]
var is_generated:bool=false
var modulator:Array=[]
var output:Array=[]
var am:float=0.0
var xm:float=0.0


func _init()->void:
	output_mode=OUT_MODE.ADD
	vol=1.0
	am=0.0
	xm=0.0
	input_comp=self

func duplicate()->WaveComponent:
	var nc:WaveComponent=get_script().new()
	nc.input_comp=self
	nc.output_mode=output_mode
	nc.vol=vol
	nc.am=am
	nc.xm=xm
	return nc

func are_equal_approx(a:Array)->bool:
	for i in range(0,a.size(),2):
		if !is_equal_approx(a[i],a[i+1]):
			return false
	return true

func equals(other:WaveComponent)->bool:
	# input_comp is compared by SynthWave
	if output_mode!=other.output_mode\
			or !are_equal_approx([vol,other.vol,am,other.am,xm,other.xm]):
		return false
	return true

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func calculate(size:int,input:Array,caller:WaveComponent)->Array:
	breakpoint
	return input

func set_modulator(size:int,pm:float,input:Array,caller:WaveComponent)->void:
	if caller==null:
		GLOBALS.array_fill(generated,0.0,size)
		is_generated=false
	if is_zero_approx(pm) and is_zero_approx(xm) and is_zero_approx(am):
		GLOBALS.array_fill(modulator,0.0,size)
	elif input_comp!=null:
		if !input_comp.is_generated and caller==null:
			input_comp.calculate(size,input,self)
		modulator=input_comp.generated
	else:
		modulator=input

func generate_output(size:int,input:Array,caller:WaveComponent):
	is_generated=true
	if caller!=null:
		return generated
	output.resize(size)
	for i in range(0,size):
		var modval:float=modulator[i]
		var val:float=generated[i]*lerp(1.0,(modval+1.0)*0.5,am)*lerp(1.0,modval,xm)
		if output_mode==OUT_MODE.OFF:
			output[i]=input[i]
		elif output_mode==OUT_MODE.REPLACE:
			output[i]=val*vol
		elif output_mode==OUT_MODE.ADD:
			output[i]=input[i]+val*vol
		elif output_mode==OUT_MODE.AM:
			output[i]=input[i]*lerp(1.0,(val+1.0)*0.5,vol)
		elif output_mode==OUT_MODE.XM:
			output[i]=input[i]*lerp(1.0,val,vol)
	return output

#

func serialize_start(out:ChunkedFile,tag:String,version:int,components:Array)->void:
	out.start_chunk(tag,version)
	out.store_8(output_mode)
	out.store_float(vol)
	out.store_float(am)
	out.store_float(xm)
	out.store_16(components.find(input_comp))

func deserialize_start(inf:ChunkedFile,c:WaveComponent,components:Array)->void:
	c.output_mode=inf.get_8()
	c.vol=inf.get_float()
	c.am=inf.get_float()
	c.xm=inf.get_float()
	var ic:int=inf.get_signed_16()
	if ic<0:
		c.input_comp=null
	elif ic<components.size():
		c.input_comp=components[ic]
	else:
		c.input_comp=c

