# Note commands

## Basic commands

### 00xx (FX_FRQ_SET)

Set frequency to semitone `(xx÷2)-2`. This affects the ending note of a portamento (`03xx`).

### 01xx (FX_FRQ_ADJ)

Adjust frequency by `xx-128` cents. This affects the ending note of a portamento (`03xx`).

### 02xx (FX_FRQ_SLIDE)

Slide frequency by `xx-128` cents/tick. This affects the ending note of a portamento (`03xx`).

### 03xx (FX_FRQ_PORTA)

Slide frequency to current note by `xx` cents/tick.

### 04xy (FX_ARP_SHORT)

Select arepeggio `y` from the first 16 arpeggios for this row. Each note lasts `x+1` ticks. This sets the speed of further `05xx` commands.

### 05xx (FX_ARP_FULL)

Select arpeggio #`xx`, with the last selected speed (default 3 ticks/note).

### 06xx (FX_ARP_SPEED)

Set arpeggio speed to `xx+1` ticks/note.

### 07xx (FX_FMI_SET)

Set vibrato intensity to ±`xx×50` millis.

### 08xx (FX_FMI_ADJ)

Adjust vibrato intensity by `xx-128` millis.

### 09xx (FX_FMI_SLIDE)

Slide vibrato intensity by `xx-128` millis/tick.

### 0Axx (FX_FMI_LFO)

Set vibrato to use LFO #`xx`. This value is clamped to the range [0,3].

### 0Bxx (FX_AMI_SET)

Set tremolo intensity to `[(255-xx)÷2.55,100]`%.

### 0Cxx (FX_AMI_ADJ)

Adjust tremolo intensity by `(xx-128)÷2.55`%.

### 0Dxx (FX_AMI_SLIDE)

Slide tremolo intensity by `(xx-128)÷2.55`%/tick.

### 0Exx (FX_AMI_LFO)

Set tremolo to use LFO #`xx`. This value is clamped to the range [0,3].

### 10xx (FX_VOL_LEFT) NEW

Set left volume to `(xx-128)÷1.27`%, clamped to the range [-100,100]%. Negative values may be useful for pseudo-surround effects.

### 11xx (FX_VOL_RIGHT) NEW

Set right volume to `(xx-128)÷1.27`%, clamped to the range [-100,100]%. Negative values may be useful for pseudo-surround effects.



## Note trigger commands

Any command that triggers after a delay will not trigger if that delay puts it after the current row, but any other effect in the same row will be registered anyways. These commands ignore the operator mask.

### 20xx (FX_DLY_OFF)

Trigger note off after `xx` ticks.

### 21xx (FX_DLY_CUT)

Trigger note cut after `xx` ticks.

### 22xx (FX_DLY_ON)

Trigger note on after `xx` ticks. This note on is neither legato nor staccato, and supersedes the legato/staccato column value.

This command does not delay the natural note on, just retriggers it.

### 23xx (FX_DLY_RETRIG)

Fully retriggers the note, envelope and wave generators, after `xx` ticks.

This command does not delay the natural note on, just retriggers it.

### 24xx (FX_RPT_ON)

Send note on every `xx` ticks.

### 25xx (FX_RPT_RETRIG)

Fully retriggers the note, envelope and wave generators, every `xx` ticks.



# Synth commands

## Envelope commands

### 40xx (FX_ATK_SET)

Set attack rate to `xx`.

### 41xx (FX_DEC_SET)

Set decay rate to `xx`.

### 42xx (FX_SUL_SET)

Set sustain level to `xx`.

### 43xx (FX_SUR_SET)

Set sustain rate to `xx`.

### 44xx (FX_REL_SET)

Set release rate to `xx`.

### 45xx (FX_KS_SET)

Set key scale ratio to `xx`. This value is clamped to the range [0,7].

### 46xx (FX_RPM_SET)

Set repeat mode to `xx`. This value is clamped to the range [0,4].



## Frequency commands

### 50xx (FX_MUL_SET)

Set frequency multiplier to `xx`. This value is clamped to the range [0,32]. A value of 0 activates fixes frequency mode, where detune expresses an absolute frequency, instead of a detune from the natural frequency of the operator.

In fixed frequency mode, negative frequencies are considered positive.

### 51xx (FX_DIV_SET)

Set frequency divider to `xx+1`. This value is clamped to the range [1,32].

### 52xx (FX_DET_SET)

Set detune to `(xx-128)×10` cents. In fixed frequency mode, the frequency is set to `(xx-128)×100`Hz.

### 53xx (FX_DET_ADJ)

Adjust detune by `xx-128` millis. In fixed frequency mode, the frequency is adjusted by `xx-128`Hz.

### 54xx (FX_DET_SLIDE)

Slide detune by `xx-128` millis/tick. In fixed frequency mode, the frequency is slided by `xx-128`Hz.



## Operator commands

### 60xx – 63xx (FX_MOD_SET_MIN ... FX_MOD_SET_MAX)

Set modulation intensity from operator 1–4 to the operators selected by the operator mask, to ±`π*xx÷127.5`.

### 64xx (FX_OUT_SET)

Set operator output to `xx÷2.55`%.

### 65xx (FX_OP_ENABLE) NEW

Enables or disables the operators selected in the operator mask according to the lowest 4 bits of `xx`.

A disabled operator stops calculating its waves and envelopes, and is rendered silent, but is otherwise frozen. It will resume once re-enabled.

### 66xx (FX_CLIP_SET)

Set clipping on/off. 0 deactivates clipping, anything else activates it.

### 67xx (FX_WAVE_SET)

Set waveform #`xx`.

### 68xx (FX_DUC_SET)

Set duty cycle to `xx÷2.56`%.

### 69xx (FX_DUC_ADJ) NEW

Adjust duty cycle by `xx÷2.56`%.

### 6Axx (FX_DUC_SLIDE) NEW

Slide waveform duty dycle by `(xx-128)÷2.56`%/tick.

### 6Bxx (FX_PHI_SET)

Set waveform phase to `xx÷2.56`%.

### 6Cxx (FX_PHI_ADJ) NEW

Adjust waveform phase by `(xx-128)÷2.56`%.

### 6Dxx (FX_PHI_SLIDE) NEW

Slide waveform phase by `(xx-128)÷2.56`%/tick.

### 6Exx (FX_DLY_PHI0)

Resets the wave generator phase after `xx` ticks.

### 6Fxx (FX_RPT_PHI0)

Resets the wave generator phase every `xx` ticks.



## LFO commands

The LFOs to be affected are selected with the operator mask. In case of conflict, only the last LFO command in a row affects the LFOs.

### 70xx (FX_LFO_WAVE_SET)

Set LFO waveform `xx`.

### 71xx (FX_LFO_DUC_SET)

Set LFO duty cycle to `xx÷2.56`%.

### 72xx (FX_LFO_DUC_ADJ) NEW

Adjust  LFO duty cycle to `(xx-128)÷2.56`%.

### 73xx (FX_LFO_DUC_SLIDE) NEW

Slide LFO duty cycle to `(xx-128)÷2.56`%/tick.

### 74xx (FX_LFO_PHI_SET)

Set LFO phase to `xx÷2.56`%.

### 75xx (FX_LFO_PHI_ADJ) NEW

Adjust LFO phase to `(xx-128)÷2.56`%.

### 76xx (FX_LFO_PHI_SLIDE) NEW

Slise LFO phase to `(xx-128)÷2.56`%/tick.

### 77xx (FX_LFO_FREQ_SET)

Set LFO frequency to `xx÷16`Hz.

### 78xx (FX_LFO_FREQ_ADJ) NEW

Adjust LFO frequency by `(xx-128)÷8`Hz.

### 79xx (FX_LFO_FREQ_SLIDE) NEW

Slide LFO frequency by `(xx-128)÷8`Hz/tick.

### 7Axx (FX_LFO_FREQ_SET_HI)

Set LFO frequency integral part to `xx`Hz.

### 7Bxx (FX_LFO_FREQ_ADJ_HI) NEW

Adjust LFO frequency part by `xx-128`Hz.

### 7Cxx (FX_LFO_FREQ_SLIDE_HI) NEW

Slide LFO frequency part by `xx-128`Hz/tick.

### 7Dxx (FX_LFO_FREQ_SET_LO)

Set LFO frequency decimal part to `xx÷256`Hz.

### 7Exx (FX_LFO_FREQ_ADJ_LO) NEW

Adjust LFO frequency by `(xx-128)÷2.56`Hz.

### 7Fxx (FX_LFO_FREQ_SLIDE_LO) NEW

Slide LFO frequency by `(xx-128)÷2.56`Hz.







# Play commands

Save for `C0xx`, only the last command (in channel order) will be used, and any further delay/repeat will be relative to the end of it.

Delays are executed before jumps and tempo changes.

## C0xx

Delays this note by `xx` ticks. Any other command for this row, and any further delay/repeat will be relative to the end of this command.

## C1xx

Delay all channels by `xx` ticks.

## C2xx

Jump to order `xx`. If order `xx` does not exist, jump to order 0.

This command cancels `43xx`.

## C3xx

Jump to next order, row `xx`.

## C4xx

Set song speed to `xx+1` ticks/row.

## C5xx

Set song speed to `xx+1` ticks/second.
