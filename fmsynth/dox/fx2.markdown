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

Set repeat mode to `xx`.

## 16xx

Set tremolo intensity from `1x` to `0x - 1x`.

## 17xx

Slide tremolo intensity by `xx-128` units/tick.

## 18xx

Set tremolo to use LFO # `xx`.



# Note commands

Any command that triggers after a delay will not trigger if that delay is greater than song speed (ticks/s), but any other effect in the same row will be registered anyways.

## 20xx

Trigger note off after `xx` ticks.

## 21xx

Trigger note cut after `xx` ticks.

## 22xx

Send key on every `xx` ticks.

## 23xx

Send key stop+key on every `xx` ticks.

## 24xx

Delays note by `xx` ticks.

## 25xx

Set waveform phase to `xx/2.56`%.



# Jump commands

## 30xx

Jump to order `xx`.

## 31xx

Jump to next order, row `xx`.

## 32xx

Delay playback by `xx` ticks.




# Global commands

## 40xx

Set LFO waveform `xx`.

## 41xx

Set LFO frequency to `xx`.

## 42xx

Set LFO duty cycle to `xx`.

## 43xx

Set LFO phase to `xx/256`%.

## 44xx

Set song speed to `xx` ticks/row.

## 45xx

Set song speed to `xx` ticks/second.
