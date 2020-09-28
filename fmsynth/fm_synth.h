#ifndef FM_SYNTH_H
#define FM_SYNTH_H

#include <Variant.hpp>
#include <Array.hpp>
#include "voice.h"

class FmSynth{
private:
	static const int MAX_WAVES=252;
	static const int MAX_LFOS=4;
	static const int LAST_LFO=MAX_LFOS-1;
	static const int MAX_VOICES=32;
	Voice voices[MAX_VOICES];
	UserWave *waves[MAX_WAVES];
	bool mute_voice[MAX_VOICES];

	Wave lfos[MAX_LFOS];
	float lfo_mix_rate=DEFAULT_MIX_RATE;
	float lfo_freqs[MAX_LFOS]={1.0,1.0,1.0,1.0};
	FixedPoint lfo_deltas[MAX_LFOS]={0L,0L,0L,0L};
	FixedPoint lfo_phis[MAX_LFOS]={0L,0L,0L,0L};

public:
	FmSynth();
	~FmSynth();

	_ALWAYS_INLINE_ void generate(FixedPoint &left,FixedPoint &right){
		FixedPoint lfo_vals[MAX_LFOS]={
			lfos[0].generate(lfo_phis[0],0L),
			lfos[1].generate(lfo_phis[1],0L),
			lfos[2].generate(lfo_phis[2],0L),
			lfos[3].generate(lfo_phis[3],0L)
		};
		lfo_phis[0]+=lfo_deltas[0];
		lfo_phis[1]+=lfo_deltas[1];
		lfo_phis[2]+=lfo_deltas[2];
		lfo_phis[3]+=lfo_deltas[3];
		left=right=0;
		for(int i=0;i<MAX_VOICES;i++){
			FixedPoint s=voices[i].generate(lfo_vals);
			if(mute_voice[i]){
				continue;
			}
			left+=(s*voices[i].get_volume_left())>>6;
			right+=(s*voices[i].get_volume_right())>>6;
		}
	};

	void set_mix_rate(float mix_rate);
	void set_note(int voice,int op_mask,int cents);
	void set_freq_mul(int voice,int op_mask,int multiplier);
	void set_freq_div(int voice,int op_mask,int divider);
	void set_detune(int voice,int op_mask,int millis);

	void set_wave_mode(int voice,int op_mask,int mode);
	void set_duty_cycle(int voice,int op_mask,FixedPoint duty_cycle);
	void set_phase(int voice,int op_mask,FixedPoint phi);
	void set_wave(int wave_ix,godot::Array wave);
	void set_sample(int wave_ix,int loop_start,int loop_end,float rec_freq,float sam_freq,godot::Array sample);

	void set_volume(int voice,int vel);
	void set_attack_rate(int voice,int op_mask,int rate);
	void set_decay_rate(int voice,int op_mask,int rate);
	void set_sustain_level(int voice,int op_mask,int level);
	void set_sustain_rate(int voice,int op_mask,int rate);
	void set_release_rate(int voice,int op_mask,int rate);
	void set_repeat(int voice,int op_mask,int phase);
	void set_ksr(int voice,int op_mask,int ksr);

	void set_am_intensity(int voice,int op_mask,int intensity);
	void set_am_lfo(int voice,int op_mask,int lfo);
	void set_fm_intensity(int voice,int op_mask,int millis);
	void set_fm_lfo(int voice,int op_mask,int lfo);

	void key_on(int voice,int op_mask,int velocity,bool legato);
	void key_off(int voice,int op_mask);
	void stop(int voice,int op_mask);
	void set_enable(int voice,int op_mask,bool enable);

	void set_pm_factor(int voice,int op_from,int op_to,int pm_factor);
	void set_output(int voice,int op_mask,int volume);

	void set_panning(int voice,int panning,bool invert_left,bool invert_right);
	void set_volume_right(int voice,int volume);

	void set_lfo_freq(int lfo,int freq8_8);
	void set_lfo_delta(int lfo);
	void set_lfo_wave_mode(int lfo,int mode);
	void set_lfo_duty_cycle(int lfo,FixedPoint duty_cycle);
	void set_lfo_phase(int lfo,FixedPoint phi);

	void mute_voices(int mute_mask);

};

#endif