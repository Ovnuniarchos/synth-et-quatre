# Tone commands

All frequencies are affected by MUL/DIV/DET.

## 00xx

Set frequency to semitone `(xx/2)-2`. This affects the ending note of a portamento (0x03).

## 01xx

Adjust frequency by `xx-128` cents. This affects the ending note of a portamento (0x03).

## 02xx

Slide frequency by `xx-128` cents/tick. This affects the ending note of a portamento (0x03).

## 03xx

Slide frequency to current note by `xx` cents/tick.

##04xy

Arpeggio at note, note+`x` semitones, note+`y` semitones. Each note lasts 1 tick.

## 05xx

Set vibrato intensity to ±`xx×50` millis.

## 06xx

Adjust vibrato intensity by `xx-128` millis.

## 07xx

Slide vibrato intensity by `xx-128` millis/tick.

## 08xx

Set vibrato to use LFO #`xx`.

## 09xx

Set frequency multiplier to `xx+1`.

## 0Axx

Set frequency divider to `xx+1`.

## 0Bxx

Set detune to `(xx-128)×10` cents.

## 0Cxx

Adjust detune by `xx-128` millis.

## 0Dxx

Slide detune by `xx-128` millis/tick.



# Envelope commands

## 10xx

Set attack rate to `xx`.

## 11xx

Set decay rate to `xx`.

## 12xx

Set sustain level to `xx`.

## 13xx

Set sustain rate to `xx`.

## 14xx

Set release rate to `xx`.

## 15xx

Set key scale ratio to `xx`. This is truncated to the range `0-7`.

## 16xx

Set repeat mode to `xx`.

## 17xx

Set tremolo intensity from `1x` to `0x - 1x`.

## 18xx

Slide tremolo intensity by `xx-128` units/tick.

## 19xx

Set tremolo to use LFO # `xx`.



# Trigger commands

Any command that triggers after a delay will not trigger if that delay puts it after the current row, but any other effect in the same row will be registered anyways.

## 20xx

Delays row by `xx` ticks. This command ignores the operator mask.

Any other command, and any further delay/repeat will be relative to the end of this command.

## 21xx

Trigger note off after `xx` ticks.

## 22xx

Trigger note cut after `xx` ticks.

## 23xx

Trigger note on after `xx` ticks.

## 24xx

Trigger note stop+on after `xx` ticks.

## 25xx

Send note on every `xx` ticks.

## 26xx

Send note stop+on every `xx` ticks.



# Synth commands

## 3yxx

Set modulation intensity from operator `y&3` to operator `y/4`, to ±`π*xx/127.5`. This command ignores the operator mask.

## 40xx

Set operator `y` output to `xx/2.55`%.

## 41xx

Set waveform phase to `xx/2.56`%.

## 42xx

Set waveform #`xx`.

## 43xx

Set waveform duty cycle to `xx/2.56`%.



# Jump commands

## 50xx

Jump to order `xx`.

## 51xx

Jump to next order, row `xx`.

## 52xx

Delay playback by `xx` ticks.




# Global commands

## 60xx

Set LFO waveform `xx`.

## 61xx

Set LFO frequency to `xx`.

## 62xx

Set LFO duty cycle to `xx/2.56`%.

## 63xx

Set LFO phase to `xx/2.56`%.

## 64xx

Set song speed to `xx` ticks/row.

## 65xx

Set song speed to `xx` ticks/second.
