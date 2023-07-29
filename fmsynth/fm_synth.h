#ifndef FM_SYNTH_H
#define FM_SYNTH_H

#include <Array.hpp>

#include "voice.h"
#include "waveforms.h"

class FmSynth{
private:
	static const int MAX_VOICES=32;
	static const int MAX_WAVES=256;
	static const int MIN_USR_WAVE=4;
	static const int MAX_LFOS=4;
	Voice voices[MAX_VOICES];
	Wave *waves[MAX_WAVES];
	bool mute_voice[MAX_VOICES];

	int lfo_waves[MAX_LFOS]={0,0,0,0};
	float lfo_mix_rate=DEFAULT_MIX_RATE;
	float lfo_freqs[MAX_LFOS]={1.0,1.0,1.0,1.0};
	FixedPoint lfo_deltas[MAX_LFOS]={0L,0L,0L,0L};
	FixedPoint lfo_phis[MAX_LFOS]={0L,0L,0L,0L};
	FixedPoint lfo_duties[MAX_LFOS]={0L,0L,0L,0L};

	_ALWAYS_INLINE_ FixedPoint generate_lfo(int ix,FixedPoint phi,FixedPoint duty_cycle);
	WaveState wave_state[MAX_LFOS];

public:
	FmSynth(){
		int i;
		for(i=MIN_USR_WAVE;i<MAX_WAVES;i++) waves[i]=NULL;
		waves[0]=new RectangleWave();
		waves[1]=new SawWave();
		waves[2]=new TriangleWave();
		waves[3]=new NoiseWave();
		for(i=0;i<MAX_VOICES;i++){
			voices[i].set_wave_list(waves);
			mute_voice[i]=false;
		}
	};

	~FmSynth(){
		int i;
		for(i=0;i<MAX_VOICES;i++) voices[i].set_wave_list(NULL);
		for(i=0;i<MAX_WAVES;i++) delete waves[i];
	}

	void generate(FixedPoint &left,FixedPoint &right);

	void set_mix_rate(float mix_rate);
	void set_note(int voice,int op_mask,int cents);
	void set_freq_mul(int voice,int op_mask,int multiplier);
	void set_freq_div(int voice,int op_mask,int divider);
	void set_detune(int voice,int op_mask,int millis);

	void set_wave(int voice,int op_mask,int wave_num);
	void set_duty_cycle(int voice,int op_mask,FixedPoint duty_cycle);
	void set_phase(int voice,int op_mask,FixedPoint phi);
	void shift_phase(int voice,int op_mask,FixedPoint delta);
	void define_wave(int wave_num,godot::Array wave);
	void define_sample(int wave_num,int loop_start,int loop_end,float rec_freq,float sam_freq,godot::Array sample);

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
	void set_enable(int voice,int op_mask,int enable_bits);
	void set_clip(int voice,bool clip_bits);

	void set_pm_factor(int voice,int op_from,int op_to,int pm_factor);
	void set_output(int voice,int op_mask,int volume);

	void set_panning(int voice,int panning,bool invert_left,bool invert_right);
	void set_volume_right(int voice,int volume);

	void set_lfo_freq(int lfo,float freq);
	void set_lfo_delta(int lfo);
	void set_lfo_wave(int lfo,int wave_num);
	void set_lfo_duty_cycle(int lfo,FixedPoint duty_cycle);
	void set_lfo_phase(int lfo,FixedPoint phi);

	void mute_voices(int mute_mask);

};

#endif