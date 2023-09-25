extends Reference

enum{
	CMD_FREQ=0x01, CMD_KEYON, CMD_KEYON_LEGATO, CMD_KEYON_STACCATO, CMD_KEYOFF,
	CMD_STOP, CMD_ENABLE,
	CMD_MULT=0x08, CMD_DIV, CMD_DET, CMD_DUC,
	CMD_WAV=0x0C,
	CMD_VEL=0x0D, CMD_AR, CMD_DR, CMD_SL, CMD_SR, CMD_RR, CMD_RM, CMD_KSR,
	CMD_PM=0x15, CMD_OUT,
	CMD_PAN=0x17,
	CMD_PHI=0x18,CMD_DPHI,
	CMD_AMS=0x1A, CMD_AML, CMD_FMS, CMD_FML,
	CMD_LFO_FREQ=0x1E, CMD_LFO_WAVE, CMD_LFO_DUC, CMD_LFO_PHI,
	CMD_CLIP=0x22
}
enum{
	FX_FRQ_SET=0x00, FX_FRQ_ADJ, FX_FRQ_SLIDE, FX_FRQ_PORTA, FX_ARPEGGIO,
	FX_FMI_SET, FX_FMI_ADJ, FX_FMI_SLIDE, FX_FMI_LFO,
	FX_MUL_SET, FX_DIV_SET,
	FX_DET_SET, FX_DET_ADJ, FX_DET_SLIDE,FX_ARP_SET,FX_ARP_SPEED
	FX_ATK_SET=0x10, FX_DEC_SET, FX_SUL_SET, FX_SUR_SET, FX_REL_SET,
	FX_KS_SET, FX_RPM_SET, FX_AMI_SET, FX_AMI_ADJ, FX_AMI_SLIDE, FX_AMI_LFO,
	FX_DLY_OFF=0x20, FX_DLY_CUT, FX_DLY_ON, FX_DLY_RETRIG, FX_DLY_PHI0,
	FX_RPT_ON, FX_RPT_RETRIG, FX_RPT_PHI0,
	FX_MOD_SET_MIN=0x30, FX_MOD_SET_MAX=0x33, FX_OUT_SET,
	FX_WAVE_SET, FX_DUC_SET, FX_PHI_SET,
	FX_LFO_WAVE_SET, FX_LFO_DUC_SET, FX_LFO_PHI_SET,
	FX_LFO_FREQ_SET, FX_LFO_FREQ_SET_HI, FX_LFO_FREQ_SET_LO,
	FX_CLIP_SET=0x3e,
	FX_DELAY=0x40, FX_DELAY_SONG, FX_GOTO_ORDER, FX_GOTO_NEXT,
	FX_TICKSROW_SET,FX_TICKSSEC_SET
	FX_DEBUG=0xFE,FX_END
}
enum{
	TRG_KEEP, TRG_ON, TRG_OFF, TRG_STOP
}

const MIN_FREQ:int=-200
const MAX_FREQ:int=14300
