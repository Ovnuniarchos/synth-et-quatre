# Command stream

# Commands

## `--:--:--:00 n` (WAIT)

Wait `n+1` samples.

## `--:oo:vv:01 cents` (SET FREQUENCY)

Set frequency in voice `vv`, with operator mask `oo`, to `cents` cents. `cents` is clamped to the range `[-200, 14300]`.

## `--:ii:vv:02` (SET VOICE VELOCITY)

Set velocity/volume for voice `vv` to `ii÷2.55`%.

## `ii:oo:vv:03` (KEY ON)

Trigger (key on-normal) voice `vv`, with operator mask `oo` and volume `ii÷2.55`%. Normal mode resets the envelope phase to attack, but does not reset its generated volume.

A key on message automatically enables operators, regardless of enable bits.

## `ii:oo:vv:04` (KEY ON LEGATO)

Trigger (key on-legato) voice `vv`, with operator mask `oo` and volume `ii÷2.55`%. Legato mode does not reset the envelope phase, nor its volume.

## `ii:oo:vv:05` (KEY ON STACCATO)

Trigger (key on-staccato) voice `vv`, with operator mask `oo` and volume `ii÷2.55`%. Staccato mode resets both the envelope phase, and its volume.

## `--:oo:vv:06` (KEY OFF)

Release (key off) voice `vv`, with operator mask `oo`. This puts the envelope generator in release mode immediately.

## `--:oo:vv:07` (STOP)

Silence voice `vv`, with operator mask `oo`. This ends envelopes, and disables operators immediately.

## `--:pp:vv:08` (SET PANPOT)

Set pan position for voice `vv` to bits 0-5 of `pp`. 0 is left, 62-63 is right, and 31 is center.

Bit 6 inverts the left channel, and bit 7 the right one. This allows for pseudo-surround effects.

## `cc:--:vv:09` (SET CLIP)

Set clipping for voice `vv`.

Any value of `cc` not equal to zero enables clipping.


## `bb:oo:vv:20` (ENABLE OPERATORS)

Set enable bits for voice `vv`, with operator mask `oo`, and enable bits `bb`.

Disabling an operator stops its waveform and envelope generators, and sets its output to 0; but it does not stop it. A posterior enable "wakes up" the operator, making it continue where it stopped.

## `mm:oo:vv:21` (SET OP MULTIPLIER)

Set frequency multiplier in voice `vv`, with operator mask `oo`, to `mm`. `mm` is clamped to `[1, 32]`.

## `dd:oo:vv:22` (SET OP DIVIDER)

Set frequency divider in voice `vv`, with operator mask `oo`, to `dd`. `dd` is clamped to `[1, 32]`.

## `--:oo:vv:23 mils` (SET OP DETUNE)

Set detune in voice `vv`, with operator mask `oo`, to `mils` millis. This value is clamped to the range `[-12000, 12000]` (±1 octave)

## `mm:oo:vv:24` (SET OP DETUNE MODE)

Set detune mode in voice `vv`, with operator mask `oo`, to mode `mm`. This value is clamped to the range `[0, 2]`. The modes are:

NORMAL (0)
: The detune value is the amount of millis to add to the operator base frequency.

FIXED FREQUENCY (1)
: The detune value is a frequency in Hz to which the operator is set. This frequency is multiplied by the multiplier, and divided by the divider.

DELTA FREQUENCY (2)
: The detune value is a number of Hz to add to the operator frequency. It's not affected by neither the multiplier, nor the divider.

## `--:oo:vv:25 duty` (SET OP DUTY CYCLE)

Set duty cycle in voice `vv`, with operator mask `oo`, to `duty÷167772.16`%. Only the lower 24 bits of `duty` are read.

The duty cycle marks the point when the generator output stops being negated, so it can be applied to any waveform.

## `ww:oo:vv:26` (SET OP WAVEFORM)

Set wave in voice `vv`, with operator mask `oo`, to wave number `ww`.

Waves 0 - 3 are internal. Waves 4+ are user-defined, and must be loaded before use.

## `aa:oo:vv:27` (SET OP ATTACK RATE)

Set attack rate in voice `vv`, with operator mask `oo`, to `aa`.

## `dd:oo:vv:28` (SET OP DECAY RATE)

Set decay rate in voice `vv`, with operator mask `oo`, to `dd`.

## `ss:oo:vv:29` (SET OP SUSTAIN LEVEL)

Set sustain level in voice `vv`, with operator mask `oo`, to `ss`.

## `ss:oo:vv:2A` (SET OP SUSTAIN RATE)

Set sustain rate in voice `vv`, with operator mask `oo`, to `ss`.

## `rr:oo:vv:2B` (SET OP RELEASE RATE)

Set release rate in voice `vv`, with operator mask `oo`, to `rr`.

## `pp:oo:vv:2C` (SET OP ENVELOPE REPEAT POINT)

Set envelope repeat point for voice `vv`, with operator mask `oo`, to `pp`. Modes are 0 (no repeat),1 (repeat from attack), 2 (repeat from decay), 3 (repeat from sustain), or 4 (repeat from release).

`pp` is clamped to the range `[0, 4]`.

## `ss:oo:vv:2D` (SET KEY SCALE FACTOR)

Set key scaling for voice `vv`, with operator mask `oo`, to `ss`. Higher values shorten the envelope for higher-pitched notes.

`ss` is clamped to the range `[0, 7]`. 

## `ff:tt:vv:2E pm` (SET OP PM FACTOR)

Set PM modulation factor for voice `vv`, from operator `ff` to operator `tt`, with factor `pm×PI÷127.5`.

Only the lowest two bits of `ff` and `tt` are read. `pm` is clamped to the range `[0, 255]`.

## `ii:oo:vv:2F` (SET OP VOLUME)

Set output volume for voice `vv`, with operator mask `oo`, to volume `ii÷2.55`%.

## `--:oo:vv:30 phi` (SET OP WAVE PHASE)

Set waveform phase for voice `vv`, with operator mask `oo`, to `phi÷167772.16`%. Only the lower 24 bits of `phi` are read.

## `--:oo:vv:31 dphi` (ADVANCE OP WAVE PHASE)

Set waveform phase for voice `vv`, with operator mask `oo`, to `phi÷167772.16`%. Only the lower 24 bits of `phi` are read.

## `aa:oo:vv:32` (SET OP AM INTENSITY)

Set AM (tremolo) intensity for voice `vv`, with operator mask `oo`, to `aa÷2.55`% amplitude.

## `nn:oo:vv:33` (SET OP AM LFO)

Set AM (tremolo) LFO for voice `vv`, with operator mask `oo`, to LFO number `nn`. `nn` is clamped to the range `[0, 3]`.

## `--:oo:vv:34 mils` (SET OP FM INTENSITY)

Set FM (vibrato) intensity for voice `vv`, with operator mask `oo`, to `mils` millis. `mils` is clamped to the range `[0, 12000]`.

## `nn:oo:vv:35` (SET OP FM LFO)

Set FM (vibrato) LFO for voice `vv`, with operator mask `oo`,to LFO number `nn`. `nn` is clamped to the range `[0, 3]`.

## `--:--:ll:40 freq` (SET LFO FREQ)

Set LFO number `ll` frequency to `freq÷256` Hz.

`ll` is clamped to the range `[0, 3]`. `freq`, to the range `[0, 65535]`.

## `--:nn:ll:41` (SET LFO WAVE)

Set wave `nn` for LFO number `ll`. Waves 0-3 are internal. Waves 4+ are user-defined, and must be defined before use.

`ll` is clamped to the range `[0, 3]`.

## `--:--:ll:42 duty` (SET LFO DUTY CYCLE)

Set LFO number `ll`'s duty cycle to `duty÷167772.16`%.

`ll` is clamped to the range `[0, 3]`. Only the lower 24 bits of `duty` are read.

## `--:--:ll:43 phi` (SET LFO WAVE PHASE)

Set waveform phase for LFO `ll`, to `phi÷167772.16`%.

`ll` is clamped to the range `[0, 3]`. Only the lower 24 bits of `duty` are read.

## `--:--:--:FE` (DEBUG)

Dumps the command buffer to console, up to this command.

## `--:--:--:FF` (END LIST)

Ends the command list. Any unrecognized command ends the command list, but this is the only command guaranteed to ever have this meaning.
