extends WaveNodeComponent
class_name RampNodeComponent


const NODE_TYPE:String="Ramp"


var ramp_from:float=0.0
var ramp_to:float=1.0
var curve:float=1.0


func calculate()->Array:
	if output_valid:
		return output
	clear_array(output,size,NAN)
	var sz:int=max(1.0,size*range_length)
	var cycle:float=1.0/sz
	var phi:float=0.0
	var optr:int=fposmod(range_from*size,size)
	reset_decay()
	for i in sz:
		output[optr]=lerp(ramp_from,ramp_to,ease(phi,curve))
		phi+=cycle
		optr=(optr+1)&size_mask
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as RampNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"ramp_from","ramp_to","curve"
	])
