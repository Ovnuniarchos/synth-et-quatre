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
	NODES.ramp(output,max(1.0,size*range_length),fposmod(range_from*size,size),
		ramp_from,ramp_to,curve
	)
	output_valid=true
	return output


func equals(other:WaveNodeComponent)->bool:
	if (other as RampNodeComponent)==null:
		return false
	return .equals(other) and are_equal_approx(other,[
		"ramp_from","ramp_to","curve"
	])


func duplicate(container:Reference)->WaveNodeComponent:
	var nc:RampNodeComponent=.duplicate(container) as RampNodeComponent
	nc.ramp_from=ramp_from
	nc.ramp_to=ramp_to
	nc.curve=curve
	return nc
