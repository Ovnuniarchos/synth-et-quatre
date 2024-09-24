extends Reference
class_name SawNodeConstants

enum {
	SWQ_N1_NH,SWQ_NH_0,SWQ_0_H,SWQ_H_1,
	SWQ_1_H,SWQ_H_0,SWQ_0_NH,SWQ_NH_N1,
	SWQ_1,SWQ_H,SWQ_0,SWQ_NH,SWQ_N1,SWQ_MAX
}
const STRINGS:Dictionary={
	SWQ_N1_NH:"NODE_SAWQ_-1_-0.5",
	SWQ_NH_0:"NODE_SAWQ_-0.5_0",
	SWQ_0_H:"NODE_SAWQ_0_0.5",
	SWQ_H_1:"NODE_SAWQ_0.5_1",
	SWQ_1_H:"NODE_SAWQ_1_0.5",
	SWQ_H_0:"NODE_SAWQ_0.5_0",
	SWQ_0_NH:"NODE_SAWQ_0_-0.5",
	SWQ_NH_N1:"NODE_SAWQ_-0.5_-1",
	SWQ_1:"NODE_SAWQ_1",
	SWQ_H:"NODE_SAWQ_0.5",
	SWQ_0:"NODE_SAWQ_0",
	SWQ_NH:"NODE_SAWQ_-0.5",
	SWQ_N1:"NODE_SAWQ_-1"
}
const AS_ARRAY:Array=[
	SWQ_N1_NH,SWQ_NH_0,SWQ_0_H,SWQ_H_1,
	SWQ_1_H,SWQ_H_0,SWQ_0_NH,SWQ_NH_N1,
	SWQ_1,SWQ_H,SWQ_0,SWQ_NH,SWQ_N1
]


static func get_defaults()->Array:
	return [SWQ_N1_NH,SWQ_NH_0,SWQ_0_H,SWQ_H_1].duplicate()


static func get_calc_array()->Array:
	return [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0,0.5,0.0,-0.5,-1.0].duplicate()
