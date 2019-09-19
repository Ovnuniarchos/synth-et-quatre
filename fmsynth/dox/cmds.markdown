00 nn
: Wait `nn+1` samples.
01 vv oo hh ll
: Set frequency in voice `vv`, with operator mask `oo`, to `hh:ll` cents.
02 vv oo nn
: Trigger (key on) voice `vv`, with operator mask `oo` and velocity `nn/255`%. A key on message automatically enables operators.
03 vv oo nn
: Trigger (key on / legato) voice `vv`, with operator mask `oo` and velocity `nn/255`%. A key on message automatically enables operators.
04 vv oo
: Release (key off) voice `vv`, with operator mask `oo`.
05 vv oo
: Silence voice `vv`, with operator mask `oo`. This ends envelopes, and disables operators immediately.
06 vv oo nn
: Set enable bit for voice `vv`, with operator mask `oo`, and enable bits `nn`. Disabling an operator stops its waveform and envelope generators, and sets its output to 0; but it does not stop it. An posterior enable "wakes up" the operator, making it continue where it stopped.
07 vv oo nn
: Set frequency multiplier in voice `vv`, with operator mask `oo`, to `nn+1`.
08 vv oo nn
: Set frequency divider in voice `vv`, with operator mask `oo`, to `nn+1`.
09 vv oo hh ll
: Set detune in voice `vv`, with operator mask `oo`, to `hh:ll` millis.
0A vv oo nn
: Set duty cycle high byte in voice `vv`, with operator mask `oo`, to `nn`. The duty cycle is then `duty_cycle/16777216`%.
0B vv oo nn
: Set wave in voice `vv`, with operator mask `oo`, to wave number `nn`. Waves 0-3 are internal. Waves 4+ are user-defined, and must be defined before use.
0C vv nn
: Set velocity for voice `vv` to `nn/255`%.
0D vv oo nn
: Set attack rate in voice `vv`, with operator mask `oo`, to `nn`.
0E vv oo nn
: Set decay rate in voice `vv`, with operator mask `oo`, to `nn`.
0F vv oo nn
: Set sustain level in voice `vv`, with operator mask `oo`, to `nn`.
10 vv oo nn
: Set sustain rate in voice `vv`, with operator mask `oo`, to `nn`.
11 vv oo nn
: Set release rate in voice `vv`, with operator mask `oo`, to `nn`.
12 vv oo nn
: Set repeat point voice `vv`, with operator mask `oo`, to `nn`. Modes are [0,attack,decay,sustain.release]
13 vv ff tt nn
: Set PM modulation factor for voice `vv`, from operator `ff` to operator `tt`, with factor `nn*PI/127.5`.
14 vv oo nn
: Set output volume for voice `vv`, with operator mask `oo`, to volume `nn/255`%.
15 vv nn
: Set pan position for voice `vv` to bits 0-5 of`nn`. 0 is left, 62-63 is right, and 31 is center. Bit 6 inverts the left channel, and bit 7 the right one. This allows for pseudo-surround effects.
16 vv oo pp
: Set waveform phase for voice `vv`, with operator mask `oo`, to `pp/256`%.
17 vv oo nn
: Set AM (tremolo) intensity for voice `vv`, with operator mask `oo`, to `nn/255`% amplitude.
18 vv oo nn
: Set AM (tremolo) intensity for voice `vv`, with operator mask `oo`, to `nn/255`% amplitude.
19 vv oo hh ll
: Set FM (vibrato) intensity for voice `vv`, with operator mask `oo`, to `hh:ll` millis.
1A vv oo hh ll
: Set FM (vibrato) intensity for voice `vv`, with operator mask `oo`, to `hh:ll` millis.
1B ff hh ll
: Set LFO number `ff` frequency to `(hh:ll)/256` Hz.
1C ff nn
: Set wave `nn` for LFO number `ff`. Waves 0-3 are internal. Waves 4+ are user-defined, and must be defined before use.
1D ff nn
: Set LFO number `ff`'s duty cycle high byte to `nn`. The duty cycle is then `duty_cycle/16777216`%.
FF
: Ends the command list. Any unrecognized command ends the command list, but this is the only command guaranteed to end the list.