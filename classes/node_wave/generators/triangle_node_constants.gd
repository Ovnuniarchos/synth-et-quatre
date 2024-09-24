extends Reference
class_name TriangleNodeConstants

enum {
	TRQ_0_1,TRQ_1_0,TRQ_0_N1,TRQ_N1_0,TRQ_1,TRQ_0,TRQ_N1,TRQ_MAX
}
const STRINGS:Dictionary={
	TRQ_0_1:"NODE_TRIQ_0_1",
	TRQ_1_0:"NODE_TRIQ_1_0",
	TRQ_0_N1:"NODE_TRIQ_0_-1",
	TRQ_N1_0:"NODE_TRIQ_-1_0",
	TRQ_1:"NODE_TRIQ_1",
	TRQ_0:"NODE_TRIQ_0",
	TRQ_N1:"NODE_TRIQ_-1"
}
const AS_ARRAY:Array=[TRQ_0_1,TRQ_1_0,TRQ_0_N1,TRQ_N1_0,TRQ_1,TRQ_0,TRQ_N1]


static func get_defaults()->Array:
	return [TRQ_0_1,TRQ_1_0,TRQ_0_N1,TRQ_N1_0].duplicate()


static func get_calc_array()->Array:
	return [0.0,0.0,0.0,0.0,1.0,0.0,-1.0].duplicate()
