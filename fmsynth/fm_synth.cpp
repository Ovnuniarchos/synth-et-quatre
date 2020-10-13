#include "fm_synth.h"

_ALWAYS_INLINE_ FixedPoint FmSynth::generate_lfo(int ix,FixedPoint phi,FixedPoint duty_cycle){
	return waves[ix]==NULL?0L:waves[ix]->generate(phi,0L,duty_cycle);
}

void FmSynth::generate(FixedPoint &left,FixedPoint &right){
	FixedPoint lfo_vals[MAX_LFOS]={
		generate_lfo(0,lfo_phis[0],lfo_duties[0]),
		generate_lfo(1,lfo_phis[1],lfo_duties[0]),
		generate_lfo(2,lfo_phis[2],lfo_duties[0]),
		generate_lfo(3,lfo_phis[3],lfo_duties[0])
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

void FmSynth::set_mix_rate(float mix_rate){
	mix_rate=max(mix_rate,1.0f);
	for(int i=0;i<MAX_VOICES;i++){
		voices[i].set_mix_rate(mix_rate);
	}
	lfo_mix_rate=mix_rate;
	set_lfo_freq(0,lfo_freqs[0]);
	set_lfo_freq(1,lfo_freqs[1]);
	set_lfo_freq(2,lfo_freqs[2]);
	set_lfo_freq(3,lfo_freqs[3]);
}

void FmSynth::set_note(int voice,int op_mask,int cents){
	voices[voice&31].set_note(op_mask,cents);
}

void FmSynth::set_freq_mul(int voice,int op_mask,int multiplier){
	voices[voice&31].set_freq_mul(op_mask,multiplier);
}

void FmSynth::set_freq_div(int voice,int op_mask,int divider){
	voices[voice&31].set_freq_div(op_mask,divider);
}

void FmSynth::set_detune(int voice,int op_mask,int millis){
	voices[voice&31].set_detune(op_mask,millis);
}


void FmSynth::set_wave(int voice,int op_mask,int wave_num){
	wave_num&=255;
	voices[voice&31].set_wave(op_mask,wave_num);
}

void FmSynth::set_duty_cycle(int voice,int op_mask,FixedPoint duty_cycle){
	voices[voice&31].set_duty_cycle(op_mask,duty_cycle);
}

void FmSynth::set_phase(int voice,int op_mask,FixedPoint phi){
	voices[voice&31].set_phase(op_mask,phi);
}

void FmSynth::define_wave(int wave_num,godot::Array wave){
	wave_num%=MAX_WAVES;
	if(wave_num<4){
		return;
	}
	Wave *old_wave=waves[wave_num];
	if(wave.size()>=1){
		waves[wave_num]=new UserWave(wave);
	}else{
		waves[wave_num]=NULL;
	}
	delete old_wave;
}

void FmSynth::define_sample(int wave_num,int loop_start,int loop_end,float rec_freq,float sam_freq,godot::Array sample){
	wave_num%=MAX_WAVES;
	if(wave_num<4){
		return;
	}
	Wave *old_wave=waves[wave_num];
	if(sample.size()>=1){
		waves[wave_num]=new SampleWave(sample,loop_start,loop_end,rec_freq,sam_freq);
	}else{
		waves[wave_num]=NULL;
	}
	delete old_wave;
}


void FmSynth::set_volume(int voice,int vel){
	voices[voice&31].set_volume(vel);
}

void FmSynth::set_attack_rate(int voice,int op_mask,int rate){
	voices[voice&31].set_attack_rate(op_mask,rate);
}

void FmSynth::set_decay_rate(int voice,int op_mask,int rate){
	voices[voice&31].set_decay_rate(op_mask,rate);
}

void FmSynth::set_sustain_level(int voice,int op_mask,int level){
	voices[voice&31].set_sustain_level(op_mask,level);
}

void FmSynth::set_sustain_rate(int voice,int op_mask,int rate){
	voices[voice&31].set_sustain_rate(op_mask,rate);
}

void FmSynth::set_release_rate(int voice,int op_mask,int rate){
	voices[voice&31].set_release_rate(op_mask,rate);
}

void FmSynth::set_repeat(int voice,int op_mask,int phase){
	voices[voice&31].set_repeat(op_mask,phase);
}

void FmSynth::set_ksr(int voice,int op_mask,int ksr){
	voices[voice&31].set_ksr(op_mask,ksr);
}


void FmSynth::set_am_intensity(int voice,int op_mask,int intensity){
	voices[voice&31].set_am_intensity(op_mask,intensity);
}

void FmSynth::set_am_lfo(int voice,int op_mask,int lfo){
	lfo=clamp(lfo,0,LAST_LFO);
	voices[voice&31].set_am_lfo(op_mask,lfo);
}

void FmSynth::set_fm_intensity(int voice,int op_mask,int millis){
	voices[voice&31].set_fm_intensity(op_mask,millis);
}

void FmSynth::set_fm_lfo(int voice,int op_mask,int lfo){
	lfo=clamp(lfo,0,LAST_LFO);
	voices[voice&31].set_fm_lfo(op_mask,lfo);
}


void FmSynth::key_on(int voice,int op_mask,int velocity,bool legato){
	voices[voice&31].key_on(op_mask,velocity,legato);
}

void FmSynth::key_off(int voice,int op_mask){
	voices[voice&31].key_off(op_mask);
}

void FmSynth::stop(int voice,int op_mask){
	voices[voice&31].stop(op_mask);
}

void FmSynth::set_enable(int voice,int op_mask,bool enable){
	voices[voice&31].set_enable(op_mask,enable);
}


void FmSynth::set_pm_factor(int voice,int op_from,int op_to,int pm_factor){
	voices[voice&31].set_pm_factor(op_from,op_to,pm_factor);
}

void FmSynth::set_output(int voice,int op_mask,int volume){
	voices[voice&31].set_output(op_mask,volume);
}


void FmSynth::set_panning(int voice,int panning,bool invert_left,bool invert_right){
	voices[voice&31].set_panning(panning,invert_left,invert_right);
}


void FmSynth::set_lfo_freq(int lfo,float freq){
	lfo=clamp(lfo,0,LAST_LFO);
	lfo_freqs[lfo]=max(freq,0.0f);
	set_lfo_delta(lfo);
}

void FmSynth::set_lfo_delta(int lfo){
	if(waves==NULL || waves[lfo_waves[lfo]]==NULL){
		lfo_deltas[lfo]=(lfo_freqs[lfo]*FP_ONE)/lfo_mix_rate;
	}else{
		lfo_deltas[lfo]=(lfo_freqs[lfo]*waves[lfo_waves[lfo]]->get_recorded_freq()*FP_ONE)/(lfo_mix_rate*waves[lfo_waves[lfo]]->get_sample_freq());
	}
}

void FmSynth::set_lfo_wave(int lfo,int wave_num){
	lfo=clamp(lfo,0,LAST_LFO);
	wave_num&=255;
	lfo_waves[lfo]=wave_num;
	set_lfo_delta(lfo);
}

void FmSynth::set_lfo_duty_cycle(int lfo,FixedPoint duty_cycle){
	lfo=clamp(lfo,0,LAST_LFO);
	lfo_duties[lfo]=duty_cycle&FP_DEC_MASK;
}

void FmSynth::set_lfo_phase(int lfo,FixedPoint phi){
	lfo=clamp(lfo,0,LAST_LFO);
	phi&=FP_DEC_MASK;
	if(waves==NULL || waves[lfo_waves[lfo]]==NULL){
		lfo_phis[lfo]=phi;
	}else{
		lfo_phis[lfo]=phi*(waves[lfo_waves[lfo]]->get_size()>>FP_INT_SHIFT);
	}
}


void FmSynth::mute_voices(int mute_mask){
	for(int i=0;i<MAX_VOICES;i++){
		mute_voice[i]=(bool)(mute_mask&1);
		mute_mask>>=1;
	}
}
