extends Reference

enum{
	CMD_WAIT=0,
	CMD_DEBUG=254,
	CMD_END=255
}
const ATTRS=Pattern.ATTRS
const LG_MODE=Pattern.LEGATO_MODE
const DEFAULT_VOLUME:int=255
const DEFAULT_PAN:int=31
const SIG_VAL_MASK:int=0xFFFF
const SIG_CMD_MASK:int=0xFFFF0000
const SIG_DELAY_SONG:int=0x10000
const SIG_GOTO_ORDER:int=0x20000
const SIG_GOTO_NEXT:int=0x30000

const MAX_WAIT_TIME:float=float(0x1000000)
