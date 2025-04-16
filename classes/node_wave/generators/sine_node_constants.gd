extends Reference
class_name SineNodeConstants

enum {
	SNQ_0_1,SNQ_1_0,SNQ_0_N1,SNQ_N1_0,SNQ_1,SNQ_0,SNQ_N1,SNQ_MAX
}
const STRINGS:Dictionary={
	SNQ_0_1:"NODE_SINEQ_0_1",
	SNQ_1_0:"NODE_SINEQ_1_0",
	SNQ_0_N1:"NODE_SINEQ_0_-1",
	SNQ_N1_0:"NODE_SINEQ_-1_0",
	SNQ_1:"NODE_SINEQ_1",
	SNQ_0:"NODE_SINEQ_0",
	SNQ_N1:"NODE_SINEQ_-1"
}


static func get_defaults()->Array:
	return [SNQ_0_1,SNQ_1_0,SNQ_0_N1,SNQ_N1_0].duplicate()
