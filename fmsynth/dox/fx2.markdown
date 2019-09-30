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





## XXxx
Trigger note off after `xx` ticks.

## XXxx
Trigger note cut after `xx` ticks.

## XXxx

Send key on every `xx` ticks.

## XXxx

Send key stop+key on every `xx` ticks.

## XXxx

Set waveform phase to `xx/2.56`%.

## XXxx

Jump to order `xx`.

## XXxx

Jump to next order, row `xx`.

## XXxx

Set LFO waveform `xx`.

## XXxx

Set LFO frequency to `xx`.

## XXxx

Set LFO duty cycle to `xx`.

## XXxx

Set LFO phase to `xx/256`%.

## XXxx

Delays not by `xx` ticks. If `xx` is greater than song speed, the note will not play (but any effect will be registered).

## XXxx

Delay playback by `xx` ticks.

## XXxx

Set song speed to `xx` ticks/row.