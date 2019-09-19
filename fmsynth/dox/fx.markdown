# Effects

## 0fxy - Arpeggio
base -> base+x semitones -> base+y semitones

## 1fxx Tone slide
+(x-128) cents per tick

## 3fxx Tone portamento
±x cents per tick, until $this tone

## 4fxy Vibrato

## 5fxy Tremolo

## 6fxx Volume slide
+(x-128) units (??) per tick

## 7fxx Volume portamento
±x units (??) per tick, until $this volume

## 80xx Panning

## 81xx Pattern Jump

## 82xx Set speed

## 83xx Jump to next pattern

## 84xx Arpeggio speed

## 85xx LFO speed

## 86xx LFO waveform

## 9fxx Retrig
Retrigger operator(s) every xx ticks

## Afxx Note cut

## Bfxx Note delay




Exx - Extended Commands
- E0xx – Arpeggio Tick Speed: Use xx to define the speed of the
arpeggio (00xy) effect. Bigger numbers are slower.
- E1xy - Note Slide Up: Use x to define the speed, and y to define the
number of semitones to increment. This effect is similar to 3xx -
Portamento to Note.
- E2xy - Note Slide Down Use x to define the speed, and y to define the
number of semitones to decrement. This effect is similar to 3xx -
Portamento to Note.
- E3xx - Set Vibrato Mode: This command will define vibrato mode, 1 UP
ONLY (like guitars), 2 DOWN ONLY, 0 both/normal mode.
- E4xx - Set Fine Vibrato Depth: This command will define the fine
vibrato depth, default value is F.
- E5xx - Set Fine Tune: This command will change notes pitch in a
precise way, it is a fine tweak offset with origin in E580. E5FF goes to
current note + 1 semitone, E500 is current note – 1 semitone.
- EBxx - Set Samples Bank: This command will change the current
sample bank to xx. A max of 12 sample banks can be used, from 0 to 11.
- ECxx - Note Cut: This command will rapidly cut a triggered note, a
value greater than the speed of the current row will be ignored.
- EDxx - Note Delay: This command will delay a note a short period of
time, a value greater than the speed of the current row will be ignored.
- EExx – Sync Signal: To be used in .vgm exports for synchronization
with visuals or other devices. It writes a data block of type FF size 3 with
register 0x00 0x00 and DATA xx.
In HEX: 0x67 0x66 0xFF 0x03 0x00 0x00 0x00 0x00 0x00 xx
- EFxx - Set Global Fine Tune: This command will add or subtract to the
global pitch of the entire song, a value greater than 80 will add, and a
value lower than 80 will subtract (this effect is cumulative).
Fxx - Set Speed Value 2
This command will set the playback speed 2 dynamically.

10xx – Noise Mode Set:
This effect will enable the noise output of the 4th operator of the last FM
channel. 00 means disabled, standard behavior as a FM operator. From 0x01 to
0x20 (HEX) you will set the white noise frequency. This provides independence
from the main frequency of the other operators (to make noise and kick at the
same time at different pitches, for example)
11xx - Feedback Control:
The FB is a global parameter of a YM2612's channel. You can designate xx with
a value from 0 to 7.
12xx - TL Operator 1 Control:
With this effect you can modify the TL of the operator 1. You can designate xx
with a value from 0 to 7F.
13xx - TL Operator 2 Control:
With this effect you can modify the TL of the operator 2. You can designate xx
with a value from 0 to 7F.
14xx - TL Operator 3 Control:
With this effect you can modify the TL of the operator 3. You can designate xx
with a value from 0 to 7F.
15xx - TL Operator 4 Control:
With this effect you can modify the TL of the operator 4. You can designate xx
with a value from 0 to 7F.
16xy - MULT Control:
The Multiplier factor is a frequency multiplier, all of the 4 operators are
capable of have its own values of MULT.
The x value is the operator to modify, you can designate a value from 1 to 4.
The y value controls the MULT value; you can designate a value from 0 to F.
17xx – Set LFO Speed:
This effect will set the LFO’s speed. It starts disabled (00), the max value is FF.

18xx – Set LFO Waveform:
This effect will change the LFO waveform, 0 SAW, 1 SQUARE, 2 TRIANGLE, 3
NOISE.
19xx - Global AR Control:
This effect will control all the AR values of all operators of the current
instrument, a value higher than 0x1F (31) would be ignored.
1Axx - AR Operator 1 Control:
This effect will control the AR value of the operator number 1 of the current
instrument, a value higher than 0x1F (31) would be ignored.
1Bxx - AR Operator 2 Control:
This effect will control the AR value of the operator number 2 of the current
instrument, a value higher than 0x1F (31) would be ignored.
1Cxx - AR Operator 3 Control:
This effect will control the AR value of the operator number 3 of the current
instrument, a value higher than 0x1F (31) would be ignored.
1Dxx - AR Operator 4 Control:
This effect will control the AR value of the operator number 4 of the current
instrument, a value higher than 0x1F (31) would be ignored.

20xx – Set Sample Delta:
This effect will set the speed of sample playback, very useful to make tonal
samples. The formula is: delta*(31250/255)hz = sample hz




0xy 	Arpeggio 	No 	Plays an arpeggiation of three notes in one row, cycling between the current note, current note + x semitones, and current note + y semitones. 	Pitch
1xx 	Portamento Up 	No 	Increases current note pitch by xx units on every tick of the row except the first. 	Pitch
2xx 	Portamento Down 	No 	Decreases current note pitch by xx units on every tick of the row except the first. 	Pitch
3xx 	Tone Portamento 	Yes 	Slides the pitch of the previous note towards the current note by xx units on every tick of the row except the first. 	Pitch
4xy 	Vibrato 	Yes 	Executes vibrato with speed x and depth y on the current note.
Modulates with selected vibrato waveform (see the Waveform Types table for more details). 	Pitch
5xy 	Volume Slide + Tone Portamento 	No 	Functions like Axy with 300.
Parameters are used like Axy. 	Miscellaneous
6xy 	Volume Slide + Vibrato 	No 	Functions like Axy with 400.
Parameters are used like Axy. 	Miscellaneous
7xy 	Tremolo 	Yes 	Executes tremolo with speed x and depth y on the current note.
Modulates with selected tremolo waveform (see the Waveform Types table for more details). 	Volume
8xx 	Set Panning 	— 	Sets the current channel's panning position.
Ranges from 00h (left) to FFh (right). 	Panning
9xx 	Sample Offset 	Yes 	Starts playing the current sample from position x × 256, instead of position 0.
Ineffective if there is no note in the same pattern cell. 	Miscellaneous
Axy 	Volume Slide 	No 	Slides the current note volume up or down.

    A0y decreases note volume by y units on every tick of the row except the first.
    Ax0 increases note volume by x units on every tick of the row except the first.

	Volume
Bxx 	Position Jump 	— 	Causes playback to jump to pattern position xx.
B00 would restart a song from the beginning (first pattern in the Order List).
If Dxx is on the same row, the pattern specified by Bxx will be the pattern Dxx jumps in.
Ranges from 00h to 7Fh (127; maximum amount of patterns for the MOD format). 	Global (Pattern)
Cxx 	Set Volume 	— 	Sets the current note volume to xx.
Ranges from 00h (off) to 40h (full). 	Volume
Dxx 	Pattern Break 	— 	Jumps to row xx of the next pattern in the Order List.
If the current pattern is the last pattern in the Order List, Dxx will jump to row xx of the first pattern.
If Bxx is on the same row, the pattern specified by Bxx will be the pattern Dxx jumps in.
Ranges from 00h to 3Fh (64; maximum amount of rows for each pattern in the MOD format). 	Global (Pattern)
E0x 	Set Filter 	— 	Configures the Amiga's LED lowpass filter.

    E00 enables emulation of the lowpass filter.
    E01 disables emulation of the lowpass filter.

Enabling the filter makes the sound output more muffled and is not recommended.
Using this effect is only recommended to explicitly disable the filter for environments where it might not be disabled by default (such as a real Amiga system).
OpenMPT only emulates the lowpass filter if the Amiga resampler is enabled in the Mixer settings.
	Miscellaneous
E1x 	Fine Portamento Up 	No 	Similar to 1xx, but only applies on the first tick of the row. 	Pitch
E2x 	Fine Portamento Down 	No 	Similar to 2xx, but only applies on the first tick of the row. 	Pitch
E3x 	Glissando Control 	— 	This effect is not widely supported and behaves quirky in OpenMPT.
Configures whether tone portamento effects slide by semitones or not.

    E30 disables glissando.
    E31 enables glissando.

	Pitch
E4x 	Set Vibrato Waveform 	— 	Sets the waveform of future Vibrato effects (see the Waveform Types table for more details). 	Pitch
E5x 	Set Finetune 	— 	Sets the finetune value for the current sample.
Functions similarly to the same setting in the Sample Editor. 	Pitch
E60 	Pattern Loop Start 	— 	Marks the current row position to be used as the start of a pattern loop. 	Global (Pattern)
E6x 	Pattern Loop 	— 	Each time this command is reached, jumps to the row marked by E60 until x jumps have occured in total.
If E6x is used in a pattern with no E60 effect, E6x will use the row position marked by any previous E60 effect.
Pattern loops cannot span multiple patterns.
Ranges from 1h to Fh. 	Global (Pattern)
E7x 	Set Tremolo Waveform 	— 	Sets the waveform of future Tremolo effects (see the Waveform Types table for more details). 	Volume
E8x 	Set Panning 	— 	8xx is a much finer panning effect.
Sets the current channel's panning position.
Ranges from 0h (left) to Fh (right). 	Panning
E9x 	Retrigger 	No 	Retriggers the current note every x ticks.
This effect works with parameters greater than the current Speed setting if the row after it also contains an E9x effect. 	Miscellaneous
EAx 	Fine Volume Slide Up 	No 	Similar to Ax0, but only applies on the first tick of the row. 	Volume
EBx 	Fine Volume Slide Down 	No 	Similar to A0y, but only applies on the first tick of the row. 	Volume
ECx 	Note Cut 	— 	Sets note volume to 0 after x ticks.
If x is greater than or equal to the current module Speed, this command is ignored. 	Miscellaneous
EDx 	Note Delay 	— 	Delays the note or instrument change in the current pattern cell by x ticks.
If x is greater than or equal to the current module Speed, the current pattern cell's contents are never played. 	Miscellaneous
EEx 	Pattern Delay 	— 	Repeats the current row x times.
Notes are not retriggered on every repetition, but effects are still processed.
If multiple EEx commands are found on the same row, only the rightmost is considered. 	Global (Pattern)
EFx 	Invert Loop Commands 	— 	This effect permanently modifies the module file when encountered during playback.

    EFx, when used with a looped sample, goes through the sample loop and inverts all sampling points (i.e. changes the sign) one by one at speed x.
    EF0 cancels EFx.

Samples modified by this effect cannot be recovered automatically (e.g. no undo point is created).
	Miscellaneous
Fxx 	Set Speed / Tempo 	— 	Avoid using 20h or 00h as parameters.

    Sets the module Speed (ticks per row) if xx is less than 20h.
    Sets the module Tempo if xx greater than or equal to 20h.

Some players (including old OpenMPT versions) differ in their interpretations of F20.
F00 does nothing in OpenMPT, but some players stop the song when they encounter it.
	Global (Timing)




0xy 	Arpeggio 	No 	Plays an arpeggiation of three notes in one row, cycling between the current note, current note + x semitones, and current note + y semitones. 	Pitch
1xx 	Portamento Up 	Yes 	Increases current note pitch by xx units on every tick of the row except the first. 	Pitch
2xx 	Portamento Down 	Yes 	Decreases current note pitch by xx units on every tick of the row except the first. 	Pitch
3xx 	Tone Portamento 	Yes 	Slides the pitch of the previous note towards the current note by xx units on every tick of the row except the first. 	Pitch
4xy 	Vibrato 	Yes 	Executes vibrato with speed x and depth y on the current note.
Modulates with selected vibrato waveform (see the Waveform Types table for more details). 	Pitch
5xy 	Volume Slide + Tone Portamento 	Yes 	Functions like Axy with 300.
Parameters are used like Axy. 	Miscellaneous
6xy 	Volume Slide + Vibrato 	Yes 	Functions like Axy with 400.
Parameters are used like Axy. 	Miscellaneous
7xy 	Tremolo 	Yes 	Executes tremolo with speed x and depth y on the current note.
Modulates with selected tremolo waveform (see the Waveform Types table for more details). 	Volume
8xx 	Set Panning 	— 	Sets the current sample's panning position.
As every sample has an enforced default panning, this setting is reset by any future entries in the instrument column.
Ranges from 00h (left) to FFh (right). 	Panning
9xx 	Sample Offset 	Yes 	Starts playing the current sample from position x × 256, instead of position 0.
Ineffective if there is no note in the same pattern cell. 	Miscellaneous
Axy 	Volume Slide 	Yes 	Slides the current note volume up or down.

    A0y decreases note volume by y units on every tick of the row except the first.
    Ax0 increases note volume by x units on every tick of the row except the first.

	Volume
Bxx 	Position Jump 	— 	Causes playback to jump to pattern position xx.
B00 would restart a song from the beginning (first pattern in the Order List).
If Dxx is on the same row and to the right of Bxx, the pattern specified by Bxx will be the pattern Dxx jumps in. 	Global (Pattern)
Cxx 	Set Volume 	— 	Sets the current note volume to xx.
Ranges from 00h (off) to 40h (full). 	Volume
Dxx 	Pattern Break 	— 	To maintain compatibility with Fasttracker II, you should not jump past row 3Fh (63).
Jumps to row xx of the next pattern in the Order List.
If the current pattern is the last pattern in the Order List, Dxx will jump to row xx of the first pattern.
If Bxx is on the same row and to the left of Bxx, the pattern specified by Bxx will be the pattern Dxx jumps in. 	Global (Pattern)
E1x 	Fine Portamento Up 	Yes 	Similar to 1xx, but only applies on the first tick of the row. 	Pitch
E2x 	Fine Portamento Down 	Yes 	Similar to 2xx, but only applies on the first tick of the row. 	Pitch
E3x 	Glissando Control 	— 	This effect is not widely supported and behaves quirky in OpenMPT.
Configures whether tone portamento effects slide by semitones or not.

    E30 disables glissando.
    E31 enables glissando.

	Pitch
E4x 	Set Vibrato Waveform 	— 	Sets the waveform of future Vibrato effects (see the Waveform Types table for more details). 	Pitch
E5x 	Set Finetune 	— 	Sets the finetune value for the current sample.
Functions similarly to the same setting in the Sample Editor. 	Pitch
E60 	Pattern Loop Start 	— 	A Fasttracker II bug makes use of this command non-trivial.
Marks the current row position to be used as the start of a pattern loop.
When E60 is used on pattern row x, the following pattern also starts from row x instead of row 0.
This can be circumvented by using a D00 command on the last row of the same pattern. 	Global (Pattern)
E6x 	Pattern Loop 	— 	Each time this command is reached, jumps to the row marked by E60 until x jumps have occured in total.
If E6x is used in a pattern with no E60 effect, E6x will use the row position marked by any previous E60 effect.
Pattern loops cannot span multiple patterns.
Ranges from 1h to Fh. 	Global (Pattern)
E7x 	Set Tremolo Waveform 	— 	Sets the waveform of future Tremolo effects (see the Waveform Types table for more details). 	Volume
E8x 	Set Panning 	— 	8xx is a much finer panning effect.
Sets the current channel's panning position.
Ranges from 0h (left) to Fh (right). 	Panning
E9x 	Retrigger 	No 	Retriggers the current note every x ticks.
This effect works with parameters greater than the current Speed setting if the row after it also contains an E9x effect. 	Miscellaneous
EAx 	Fine Volume Slide Up 	Yes 	Similar to Ax0, but only applies on the first tick of the row. 	Volume
EBx 	Fine Volume Slide Down 	Yes 	Similar to A0y, but only applies on the first tick of the row. 	Volume
ECx 	Note Cut 	— 	Sets note volume to 0 after x ticks.
If x is greater than or equal to the current module Speed, this command is ignored. 	Miscellaneous
EDx 	Note Delay 	— 	This command is very buggy (e.g. portamento effects next to a note delay are ignored). You should not rely on these bugs to be emulated by other players.
Delays the note or instrument change in the current pattern cell by x ticks.
If x is greater than or equal to the current module Speed, the current pattern cell's contents are never played. 	Miscellaneous
EEx 	Pattern Delay 	— 	Repeats the current row x times.
Notes are not retriggered on every repetition, but effects are still processed.
If multiple EEx commands are found on the same row, only the rightmost is considered. 	Global (Pattern)
EFx 	Set Active Macro 	— 	This effect is a ModPlug hack.
Selects the active parametered macro for the current channel. 	Miscellaneous
Fxx 	Set Speed / Tempo 	— 	Avoid using 00h as a parameter.

    Sets the module Speed (ticks per row) if xx is less than 20h.
    Sets the module Tempo if xx greater than or equal to 20h.

In OpenMPT and Fasttracker II, F00 sets the Speed to 65535 ticks per row, but in other players it may stop the song entirely, or simply do nothing.
	Global (Timing)
Gxx 	Set Global Volume 	— 	Sets the global volume.
Ranges from 00h (off) to 40h (full). 	Volume
Hxy 	Global Volume Slide 	Yes 	Similar to Axy, but applies to the global volume. 	Volume
Kxx 	Key Off 	— 	Avoid using 00h as a parameter; it interferes with other entries (e.g. notes, instruments) in the same pattern cell.
Triggers a Note Off command after xx ticks. 	Miscellaneous
Lxx 	Set Envelope Position 	— 	Sets the volume envelope playback position to xx ticks.
If the volume envelope’s sustain point is enabled, the panning envelope position is also changed. 	Volume
Pxy 	Panning Slide 	Yes 	Slides the current sample's panning position left or right.

    P0y slides the panning to the left by y units on the first tick of the row.
    Px0 slides the panning to the right by x units on the first tick of the row.

	Panning
Rxy 	Retrigger 	Yes 	This command is very buggy (e.g. if a volume command is in the same pattern cell as Rxy, it will skip some ticks).
Retriggers the current note every y ticks and changes the volume based on the x value (see the Retrigger Volume table for more details). 	Miscellaneous
Txy 	Tremor 	Yes 	Rapidly switches the sample volume on and off on every tick of the row except the first.
Volume is on for x + 1 ticks and off for y + 1 ticks.
For instrument plugins (ModPlug hack), this command sends note-on and note-off messages instead of modifying the volume. 	Volume
X1x 	Extra Fine Portamento Up 	Yes 	Similar to E1x, but with 4 times the precision. 	Pitch
X2x 	Extra Fine Portamento Down 	Yes 	Similar to E2x, but with 4 times the precision. 	Pitch
X5x 	Set Panbrello Waveform 	— 	This effect is a ModPlug hack.
Sets the waveform of future Panbrello effects (see the Waveform Types table for more details). 	Panning
X6x 	Fine Pattern Delay 	— 	This effect is a ModPlug hack.
Extends the current row by x ticks.
If multiple X6x commands are found on the same row, the sum of their parameters is used. 	Global (Pattern)
X9x 	Sound Control 	— 	This effect is a ModPlug hack.
Executes a sound control command (see the Sound Control table for more details). 	Miscellaneous
XAx 	High Offset 	— 	This effect is a ModPlug hack.
Sets the high offset for future 9xx commands.
x × 65536 (10000h) is added to all offset effects that follow this command. 	Miscellaneous
Yxy 	Panbrello 	Yes 	This effect is a ModPlug hack.
Executes Panbrello with speed x and depth y on the current note.
Modulates with selected Panbrello waveform (see the Waveform Types table for more details). 	Panning
Zxx 	MIDI Macro 	— 	This effect is a ModPlug hack.
Executes a MIDI Macro. 	Miscellaneous
\xx 	Smooth MIDI Macro 	— 	This effect is a ModPlug hack.
Executes an interpolated MIDI Macro. 




