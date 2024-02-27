# Tone commands

All frequencies are affected by MUL/DIV/DET.

## 00xx

Set frequency to semitone `(xx÷2)-2`. This affects the ending note of a portamento (`03xx`).

## 01xx

Adjust frequency by `xx-128` cents. This affects the ending note of a portamento (`03xx`).

## 02xx

Slide frequency by `xx-128` cents/tick. This affects the ending note of a portamento (`03xx`).

## 03xx

Slide frequency to current note by `xx` cents/tick.

## 04xy

Select arepeggio `y` for this row. Each note lasts `x+1` ticks. This sets the speed of further `0Exx` commands.

## 05xx

Set vibrato intensity to ±`xx×50` millis.

## 06xx

Adjust vibrato intensity by `xx-128` millis.

## 07xx

Slide vibrato intensity by `xx-128` millis/tick.

## 08xx

Set vibrato to use LFO #`xx`. This value is clamped to the range `0-3`.

## 09xx

Set frequency multiplier to `xx+1`. This value is clamped to the range `0-31`.

## 0Axx

Set frequency divider to `xx+1`. This value is clamped to the range `0-31`.

## 0Bxx

Set detune to `(xx-128)×10` cents.

## 0Cxx

Adjust detune by `xx-128` millis.

## 0Dxx

Slide detune by `xx-128` millis/tick.

## 0Exx

Select arpeggio #`xx`, with the last selected speed (default 3 ticks/note).

## 0Fxx

Set arpeggio speed to `xx+1` ticks/note.



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

Set key scale ratio to `xx`. This value is clamped to the range 0-7.

## 16xx

Set repeat mode to `xx`. This value is clamped to the range 0-4.

## 17xx

Set tremolo intensity to `1-(xx÷255)x - 1x`.

## 18xx

Adjust tremolo intensity by `(xx-128)÷255`.

## 19xx

Slide tremolo intensity by `(xx-128)÷255`/tick.

## 1Axx

Set tremolo to use LFO # `xx`. This value is clamped to the range 0-3.



# Trigger commands

Any command that triggers after a delay will not trigger if that delay puts it after the current row, but any other effect in the same row will be registered anyways. These commands ignore the operator mask.

## 20xx

Trigger note off after `xx` ticks.

## 21xx

Trigger note cut after `xx` ticks.

## 22xx

Trigger note on after `xx` ticks. This note on is neither legato nor staccato, and supersedes the legato/staccato column value.

This command does not delay the natural note on, just retriggers it.

## 23xx

Fully retriggers the note, envelope and wave generators, after `xx` ticks.

This command does not delay the natural note on, just retriggers it.

## 24xx

Resets the wave generator phase after `xx` ticks.

## 25xx

Send note on every `xx` ticks. Further commands, with no value, can be used to set a retrigger period greater than a row.

This applies also to 27xx and 28xx.

## 26xx

Fully retriggers the note, envelope and wave generators, every `xx` ticks.

## 27xx

Resets the wave generator phase every `xx` ticks.



# Synth commands

In the LFO command set, the LFOs to be affected are selected with the operator mask. In case of conflict, only the last LFO command in a row affects the LFOs.

## 30xx – 33xx

Set modulation intensity from operator 1–4 to the operators selected by the operator mask, to ±`π*xx÷127.5`.

## 34xx

Set operator output to `xx÷2.55`%.

## 35xx

Set waveform #`xx`.

## 36xx

Set waveform duty cycle to `xx÷2.56`%.

## 37xx

Set waveform phase to `xx÷2.56`%.

## 38xx

Set LFO waveform `xx`.

## 39xx

Set LFO duty cycle to `xx÷2.56`%.

## 3Axx

Set LFO phase to `xx÷2.56`%.

## 3Bxx

Set LFO frequency to `xx÷16`Hz.

## 3Cxx

Set LFO frequency integral part to `xx`Hz.

## 3Dxx

Set LFO frequency decimal part to `xx÷256`Hz.

## 3Exx

Set clipping on/off. 0 deactivates clipping, anything else activates it.



# Play commands

Save for `40xx`, only the last command (in channel order) will be used, and any further delay/repeat will be relative to the end of it.

Delays are executed before jumps and tempo changes.

## 40xx

Delays this note by `xx` ticks. Any other command for this row, and any further delay/repeat will be relative to the end of this command.

## 41xx

Delay all channels by `xx` ticks.

## 42xx

Jump to order `xx`. If order `xx` does not exist, jump to order 0.

This command cancels `43xx`.

## 43xx

Jump to next order, row `xx`.

## 44xx

Set song speed to `xx+1` ticks/row.

## 45xx

Set song speed to `xx+1` ticks/second.
