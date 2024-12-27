<type:string>
	<param:length type="uint32"/>
	<param:value type="utf8"/>
</type:string>

<type:boolean>
	<param:value type="uint8" value="value != 0">
</type:boolean>

<type:uint24>
	<param:value>
	<Hi type="uint8" value="value>>8"/>
	<Lo type="uint16" value="value&0xffff"/>
</type:uint24>

<Signature>
	<param:id type="ascii(8)"/>
	<param:version type="uint16"/>
</Signature>

<ChunkHeader>
	<param:id type="ascii(4)"/>
	<param:version type="uint16"/>
</ChunkHeader>

<Instrument>
	<Signature id="SFID\0d\0a\1a\0a"/>
	<InstrumentParameters/>
	<WaveList/>
</Instrument>

<InstrumentParameters>
	<ChunkHeader id="fM4I"/>
	<OpMask type="uint8"/>
	<if test="InstrumentParameters.version > 0">
		<Clip type="boolean"/>
	</if>
	<foreach:Operator>
		<AttackRate type="uint8"/>
		<DecayRate type="uint8"/>
		<SustainRate type="uint8"/>
		<SustainLevel type="uint8"/>
		<ReleaseRate type="uint8"/>
		<RepeatMode type="uint8(OFF|ATTACK|DECAY|SUSTAIN|RELEASE)"/>
		<Multiplier type="uint8"/>
		<Divider type="uint8"/>
		<Detune type="int16"/>
		<DutyCycle type="uint8"/>
		<Waveform type="uint8"/>
		<AmIntensity type="uint8"/>
		<AmLFO type="uint8"/>
		<FmIntensity type="uint16"/>
		<FmLFO type="uint8"/>
		<KeyScaler type="uint8"/>
	</foreach:Operator>
	<foreach:Operator>
		<ToOp1 type="uint8"/>
		<ToOp2 type="uint8"/>
		<ToOp3 type="uint8"/>
		<ToOp4 type="uint8"/>
		<Output type="uint8"/>
	</foreach:Operator>
	<Name type="string"/>
	<if test="InstrumentParameters.version > 1">
		<MacroCount type="uint16"/>
		<foreach:Macro>
			<Macro/>
		</foreach:Macro>
	</if>
</InstrumentParameters>

<Macro>
	<ChunkHeader id="mACR">
	<LoopStart type="int16"/>
	<LoopEnd type="int16"/>
	<ReleaseLoopStart type="int16"/>
	<StepCount type="uint16"/>
	<Delay type="uint16"/>
	<Mode type="uint8(ABSOLUTE|RELATIVE|MASK)"/>
	<TicksPerStep type="uint16"/>
	<Type type="ascii(4)"/>
	<Operator type="uint8"/>
	<Steps type="array[int64]" length="StepCount"/>
</Macro>

<WaveList>
	<ChunkHeader id="WAVL"/>
	<Count type="uint16"/>
	<foreach:Wave>
		<options>
			<SampleWave/>
			<SynthWave/>
			<NodeWave/>
		</options>
	</foreach:Wave>
</WaveList>

<SampleWave>
	<ChunkHeader id="sAMW"/>
	<SampleCount type="uint32"/>
	<BitsPerSample type="uint8"/>
	<LoopStart type="uint32"/>
	<LoopEnd type="uint32"/>
	<RecordedFrequency type="float"/>
	<SampleFrequency type="float"/>
	<Name type="string"/>
	<options>
		<Samples type="array[uint8]=value+0x80" length="SampleCount" if="BitsPerSample==8" option/>
		<Samples type="array[uint16]=value+0x8000" length="SampleCount" if="BitsPerSample==16" option/>
		<Samples type="array[float32]" length="SampleCount" if="BitsPerSample==32" option/>
		<Samples type="array[uint24]=value+0x800000" length="SampleCount" option/>
	</options>
</SampleWave>

<SynthWave>
	<ChunkHeader id="sYNW">
		<SizeLog2 type="uint8"/>
		<Name type="string"/>
		<ComponentCount type="uint16"/>
		<foreach:Component>
			<options>
				<NoiseWave option/>
				<RectangleWave option/>
				<SawWave option/>
				<SineWave option/>
				<TriangleWave option/>
				<BandPassFilter option/>
				<BandRejectFilter option/>
				<ClampFilter option/>
				<HighPassFilter option/>
				<LowPassFilter option/>
				<NormalizeFilter option/>
				<QuantizeFilter option/>
			</options>
		</foreach:Component>
	</ChunkHeader>
</SynthWave>

<ComponentHeader>
	<OutputMode type="uint8"/>
	<Volume type="float"/>
	<AmIntensity type="float"/>
	<XmIntensity type="float"/>
	<Source type="uint16"/>
</ComponentHeader>

<NoiseWave>
	<ChunkHeader id="nOIW"/>
	<ComponentHeader/>
	<Seed type="uint32"/>
	<Tone type="float"/>
	<StartAt type="float"/>
	<Length type="float"/>
</NoiseWave>

<RectangleWave>
	<ChunkHeader id="rECW"/>
	<ComponentHeader/>
	<Frequency type="float"/>
	<Phase type="float"/>
	<ZeroPhaseStart type="float"/>
	<NegativePhaseStart type="float"/>
	<Cycles type="float"/>
	<StartAt type="float"/>
	<PmIntensity type="float"/>
</RectangleWave>

<SawWave>
	<ChunkHeader id="sAWW"/>
	<ComponentHeader/>
	<Frequency type="float"/>
	<Phase type="float"/>
	<FirstHalf type="uint8"/>
	<SecondHalf type="uint8"/>
	<Cycles type="float"/>
	<StartAt type="float"/>
	<PmIntensity type="float"/>
</SawWave>

<SineWave>
	<ChunkHeader id="sINW"/>
	<ComponentHeader/>
	<Frequency type="float"/>
	<Phase type="float"/>
	<FirstQuarter type="uint8"/>
	<SecondQuarter type="uint8"/>
	<ThirdQuarter type="uint8"/>
	<FourthQuarter type="uint8"/>
	<Cycles type="float"/>
	<StartAt type="float"/>
	<PmIntensity type="float"/>
</SineWave>

<TriangleWave>
	<ChunkHeader id="tRIW"/>
	<ComponentHeader/>
	<Frequency type="float"/>
	<Phase type="float"/>
	<FirstHalf type="uint8"/>
	<SecondHalf type="uint8"/>
	<Cycles type="float"/>
	<StartAt type="float"/>
	<PmIntensity type="float"/>
</TriangleWave>

<BandPassFilter>
	<ChunkHeader id="bPFF"/>
	<ComponentHeader/>
	<LowCutoff type="float"/>
	<HiCutoff type="float"/>
	<Taps type="uint16"/>
</BandPassFilter>

<BandRejectFilter>
	<ChunkHeader id="bRFF"/>
	<ComponentHeader/>
	<LowCutoff type="float"/>
	<HiCutoff type="float"/>
	<Taps type="uint16"/>
</BandRejectFilter>

<ClampFilter>
	<ChunkHeader id="cLAF"/>
	<ComponentHeader/>
	<ClampHi type="boolean"/>
	<ClampLow type="boolean"/>
	<CutoffHi type="float"/>
	<CutoffLow type="float"/>
</ClampFilter>

<HighPassFilter>
	<ChunkHeader id="hPFF"/>
	<ComponentHeader/>
	<Cutoff type="float"/>
	<Taps type="uint16"/>
</HighPassFilter>

<LowPassFilter>
	<ChunkHeader id="lPFF"/>
	<ComponentHeader/>
	<Cutoff type="float"/>
	<Taps type="uint16"/>
</LowPassFilter>

<NormalizeFilter>
	<ChunkHeader id="nORF"/>
	<ComponentHeader/>
	<KeepCenter type="boolean"/>
</NormalizeFilter>

<QuantizeFilter>
	<ChunkHeader id="qUAF"/>
	<ComponentHeader/>
	<Steps type="uint8"/>
</QuantizeFilter>

<NodeWave>
</NodeWave>

=================================

<Song>
	<Signature id="SFMM\0d\0a\1a\0a"/>
	<Header/>
	<HighLights/>
	<Channels/>
	<Instruments/>
	<Orders/>
	<Patterns/>
	<Arpeggios/>
</Song>

<Header>
	<ChunkHeader id="MHDR"/>
	<PatternLength type="uint16"/>
	<TicksPerSecond type="uint16"/>
	<TicksPerRow type="uint16"/>
	<Title type="string"/>
	<Author type="string"/>
</Header>

<HighLights>
	<ChunkHeader id="hIGH"/>
	<MajorHighlight type="uint16"/>
	<MinorHighlight type="uint16"/>
</HighLights>

<Channels>
	<ChunkHeader id="CHAL"/>
	<ChannelCount type="uint16"/>
	<foreach:ChannelCount>
		<ChanneType type="ascii(4)" unused/>
		<FxCount type="uint8"/>
	</foreach:ChannelCount>
</Channels>

<Instruments>
	<ChunkHeader id="INSL"/>
	<foreach:LFO>
		<Frequency type="uint16" value="frequency*256"/>
		<Waveform type="uint8"/>
		<DutyCycle type="unit8"/>
	</foreach:LFO>
	<InstrumentCount type="uint16"/>
	<foreach:Instrument>
		<FmInstrument/>
	</foreach:Instrument>
	<WaveList/>
</Instruments>

<Orders>
	<ChunkHeader id="ORDL"/>
	<OrderCount type="uint16"/>
	<foreach:Orders>
		<PatternId type="array[uint8]" length="ChannelCount"/>
	</foreach:Orders>
</Orders>

<Patterns>
	<ChunkHeader id="PATL"/>
	<foreach:ChannelCount>
		<foreach:ChannelPattern>
			<Pattern/>
		</foreach:ChannelPattern>
	</foreach:ChannelCount>
</Patterns>

<Pattern>
	<ChunkHeader id="PATR"/>
	<ColumnsUsed type="uint32"/>
	<foreach:Column>
		<LegatoMode type="boolean" option/>
		<Note type="uint8" option/>
		<InstrumentId type="uint8" option/>
		<Volume type="uint8" option/>
		<if test="InstrumentParameters.version > 0">
			<ChannelInvert type="uint8" option/>
		</if>
		<Panpot type="uint8" option/>
		<Fx1Type type="uint8" option/>
		<Fx1Opmask type="uint8" option/>
		<Fx1Value type="uint8" option/>
		<Fx2Type type="uint8" option/>
		<Fx2Opmask type="uint8" option/>
		<Fx2Value type="uint8" option/>
		<Fx3Type type="uint8" option/>
		<Fx3Opmask type="uint8" option/>
		<Fx3Value type="uint8" option/>
		<Fx4Type type="uint8" option/>
		<Fx4Opmask type="uint8" option/>
		<Fx4Value type="uint8" option/>
	</foreach:Column>
</Pattern>

<Arpeggios>
	<ChunkHeader id="ARPL"/>
	<ArpeggioCount type="uint16"/>
	<foreach:Arpeggio>
		<Arpeggio/>
	</foreach:Arpeggio>
</Arpeggios>

<Arpeggio>
	<ChunkHeader id="aRPG">
	<LoopStart type="int16"/>
	<LoopEnd type="int16"/>
	<ReleaseLoopStart type="int16"/>
	<StepCount type="uint16"/>
	<Delay type="uint16"/>
	<Name type="string"/>
	<Index type="uint8"/>
	<Steps type="array[int64]" length="StepCount"/>
</Arpeggio>

