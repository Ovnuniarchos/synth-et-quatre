extends Synth


var mute_mask:int=0

#

func mute_voices(mask:int)->int:
	mute_mask=mask
	synth.mute_voices(mask)
	var count:int=GLOBALS.song.num_channels
	for _i in range(GLOBALS.song.num_channels):
		if bool(mask&1):
			count-=1
		mask>>=1
	return count
