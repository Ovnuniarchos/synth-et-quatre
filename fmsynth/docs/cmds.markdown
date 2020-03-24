# Command stream

# Commands

## `--:--:--:00 n` (WAIT)

Wait `n+1` samples.

## `--:oo:vv:01 cents` (SET FREQUENCY)

Set frequency in voice `vv`, with operator mask `oo`, to `cents` cents. `cents` is clamped to the range `-200 - 14300`.

## `ii:oo:vv:02` (KEY ON)

Trigger (key on-normal) voice `vv`, with operator mask `oo` and volume `ii÷2.55`%. Normal mode resets the envelope phase to attack, but does not reset its generated volume.

A key on message automatically enables operators, regardless of enable bits.

## `ii:oo:vv:03` (KEY ON LEGATO)

Trigger (key on-legato) voice `vv`, with operator mask `oo` and volume `ii÷2.55`%. Legato mode does not reset the envelope phase, nor its volume.

## `ii:oo:vv:04` (KEY ON STACCATO)

Trigger (key on-staccato) voice `vv`, with operator mask `oo` and volume `ii÷2.55`%. Staccato mode resets both the envelope phase, and its volume.

## `--:oo:vv:05` (KEY OFF)

Release (key off) voice `vv`, with operator mask `oo`. This puts the envelope generator in release mode immediately.

## `--:oo:vv:06` (STOP)

Silence voice `vv`, with operator mask `oo`. This ends envelopes, and disables operators immediately.

## `bb:oo:vv:07` (ENABLE OPERATORS)

Set enable bits for voice `vv`, with operator mask `oo`, and enable bits `bb`.

Disabling an operator stops its waveform and envelope generators, and sets its output to 0; but it does not stop it. A posterior enable "wakes up" the operator, making it continue where it stopped.

## `mm:oo:vv:08` (SET OP MULTIPLIER)

Set frequency multiplier in voice `vv`, with operator mask `oo`, to `mm+1`. `mm` is clamped to `0 - 31`, thus clamping the multiplier to `1 - 32`.

## `dd:oo:vv:09` (SET OP DIVIDER)

Set frequency divider in voice `vv`, with operator mask `oo`, to `dd+1`. `div` is clamped to `0 - 31`, thus clamping the divider to `1 - 32`.

## `--:oo:vv:0A mils` (SET OP DETUNE)

Set detune in voice `vv`, with operator mask `oo`, to `mils` millis. This value is clamped to the range `-12000 - 12000` (±1 octave).

## `--:oo:vv:0B duty` (SET OP DUTY CYCLE)

Set duty cycle in voice `vv`, with operator mask `oo`, to `duty`. `duty` is clamped to the range `0 - 16777215`, and the duty cycle is then `duty÷167772.16`%.

The duty cycle marks the point when the generator output stops being negated, so it can be applied to any waveform.

## `ww:oo:vv:0C` (SET OP WAVEFORM)

Set wave in voice `vv`, with operator mask `oo`, to wave number `ww`.

Waves 0 - 3 are internal. Waves 4+ are user-defined, and must be loaded before use.

## `--:ii:vv:0D` (SET VOICE VOLUME)

Set volume for voice `vv` to `ii÷2.55`%.

## `aa:oo:vv:0E` (SET OP ATTACK RATE)

Set attack rate in voice `vv`, with operator mask `oo`, to `aa`.

## `dd:oo:vv:0F` (SET OP DECAY RATE)

Set decay rate in voice `vv`, with operator mask `oo`, to `dd`.

## `ss:oo:vv:10` (SET OP SUSTAIN LEVEL)

Set sustain level in voice `vv`, with operator mask `oo`, to `ss`.

## `ss:oo:vv:11` (SET OP SUSTAIN RATE)

Set sustain rate in voice `vv`, with operator mask `oo`, to `ss`.

## `rr:oo:vv:12` (SET OP RELEASE RATE)

Set release rate in voice `vv`, with operator mask `oo`, to `rr`.

## `pp:oo:vv:13` (SET OP ENVELOPE REPEAT POINT)

Set envelope repeat point for voice `vv`, with operator mask `oo`, to `pp`. Modes are 0 (no repeat),1 (repeat from attack), 2 (repeat from decay), 3 (repeate from sustain), or 4 (repeat from release).

`pp` is clamped to the range `0 - 4`.

## `ss:oo:vv:14` (SET KEY SCALE FACTOR)

Set key scaling for voice `vv`, with operator mask `oo`, to `ss`. Higher values shorten the envelope for higher-pitched notes.

`ss` is clamped to the range `0-7`. 

## `ff:tt:vv:15 pm` (SET OP PM FACTOR)

Set PM modulation factor for voice `vv`, from operator `ff` to operator `tt`, with factor `pm×PI÷127.5`.

Only the lowest two bits of `ff` and `tt` are read. `pm` is clamped to the range `0 - 255`.

## `ii:oo:vv:16` (SET OP VOLUME)

Set output volume for voice `vv`, with operator mask `oo`, to volume `ii÷2.55`%.

## `--:pp:vv:17` (SET PANPOT)

Set pan position for voice `vv` to bits 0-5 of `pp`. 0 is left, 62-63 is right, and 31 is center.

Bit 6 inverts the left channel, and bit 7 the right one. This allows for pseudo-surround effects.

## `--:oo:vv:18 phi` (SET OP WAVE PHASE)

Set waveform phase for voice `vv`, with operator mask `oo`, to `phi÷167772.16`%. Only the lower 24 bits of `phi` are read.

## `aa:oo:vv:19` (SET OP AM INTENSITY)

Set AM (tremolo) intensity for voice `vv`, with operator mask `oo`, to `aa÷2.55`% amplitude.

## `nn:oo:vv:1A` (SET OP AM LFO)

Set AM (tremolo) LFO for voice `vv`, with operator mask `oo`, to LFO number `nn`. `nn` is clamped to the range `0 - 3`.

## `--:oo:vv:1A mils` (SET OP FM INTENSITY)

Set FM (vibrato) intensity for voice `vv`, with operator mask `oo`, to `mils` millis. `mils` is clamped to the range `0 - 12000`.

## `nn:oo:vv:1B` (SET OP FM LFO)

Set FM (vibrato) LFO for voice `vv`, with operator mask `oo`,to LFO number `nn`. `nn` is clamped to the range `0 - 3`.

## `--:--:ll:1C freq` (SET LFO FREQ)

Set LFO number `ll` frequency to `freq÷256` Hz.

`ll` is clamped to the range `0 - 3`. `freq`, to the range `0 - 65535`.

## `--:nn:ll:1D` (SET LFO WAVE)

Set wave `nn` for LFO number `ll`. Waves 0-3 are internal. Waves 4+ are user-defined, and must be defined before use.

`ll` is clamped to the range `0 - 3`.

## `--:--:ll:1E duty` (SET LFO DUTY CYCLE)

Set LFO number `ll`'s duty cycle to `duty`.

`ll` is clamped to the range `0 - 3`. `duty` is clamped to the range `0 - 16777215`, and the duty cycle is then `duty÷167772.16`%.

## `--:--:ll:1F phi` (SET LFO WAVE PHASE)

Set waveform phase for LFO `ll`, to `phi÷167772.16`%.

`ll` is clamped to the range `0 - 3`. Only the lower 24 bits of `phi` are read.

## `--:--:--:FE` (DEBUG)

Dumps the command buffer to console, up to this command.

## `--:--:--:FF` (END LIST)

Ends the command list. Any unrecognized command ends the command list, but this is the only command guaranteed to ever have this meaning.
