#include "fm_synth.h"

FmSynth::FmSynth(){
	for(int i=0;i<MAX_WAVES;i++) waves[i]=NULL;
	for(int i=0;i<MAX_VOICES;i++) mute_voice[i]=false;
}

FmSynth::~FmSynth(){
	for(int i=0;i<MAX_WAVES;i++) delete waves[i];
}


void FmSynth::set_mix_rate(float mix_rate){
	mix_rate=mix_rate<1.0?1.0:mix_rate;
	for(int i=0;i<MAX_VOICES;i++){
		voices[i].set_mix_rate(mix_rate);
	}
	lfo_mix_rates[0]=mix_rate;
	lfo_mix_rates[1]=mix_rate;
	lfo_mix_rates[2]=mix_rate;
	lfo_mix_rates[3]=mix_rate;
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


void FmSynth::set_wave_mode(int voice,int op_mask,int mode){
	mode&=255;
	if(mode>=4){
		voices[voice&31].set_wave(op_mask,&waves[mode-4]);
	}
	voices[voice&31].set_wave_mode(op_mask,mode);
}

void FmSynth::set_duty_cycle(int voice,int op_mask,int duty_cycle){
	voices[voice&31].set_duty_cycle(op_mask,(duty_cycle&0xff)<<16);
}

void FmSynth::set_wave(int wave_ix,godot::PoolRealArray wave){
	int size,mask,shift;
	wave_ix=(wave_ix&255)-4;
	if(wave.size()<1 || wave_ix<0){
		return;
	}
	size=UserWave::correct_wave_size(wave.size(),mask,shift);
	UserWave *new_wave=new UserWave();
	new_wave->size_mask=mask;
	new_wave->size_shift=shift;
	new_wave->wave=(size==0)?NULL:new FixedPoint[size];
	for(int i=0;i<size;i++){
		new_wave->wave[i]=wave[i]*FP_ONE;
	}
	UserWave *old_wave=waves[wave_ix];
	waves[wave_ix]=new_wave;
	delete old_wave;
}


void FmSynth::set_velocity(int voice,int vel){
	voices[voice&31].set_velocity(vel);
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
	voices[voice&31].set_am_lfo(op_mask,lfo);
}

void FmSynth::set_fm_intensity(int voice,int op_mask,int millis){
	voices[voice&31].set_fm_intensity(op_mask,millis);
}

void FmSynth::set_fm_lfo(int voice,int op_mask,int lfo){
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


void FmSynth::set_phase(int voice,int op_mask,int phi){
	voices[voice&31].set_phase(op_mask,phi);
}


void FmSynth::set_lfo_freq(int lfo,int freq8_8){
	lfo&=3;
	float frequency=(freq8_8&0xFFFF)/256.0;
	lfo_freqs[lfo]=frequency;
	lfo_deltas[lfo]=(frequency*FP_ONE)/lfo_mix_rates[lfo];
}

void FmSynth::set_lfo_wave_mode(int lfo,int mode){
	lfo&=3;
	mode&=255;
	if(mode>=4){
		lfos[lfo].set_wave(&waves[mode-4]);
	}
	lfos[lfo].set_mode(mode);
}

void FmSynth::set_lfo_duty_cycle(int lfo,int duty_cycle){
	lfos[lfo&3].set_duty_cycle((duty_cycle&0xff)<<16);
}

void FmSynth::mute_voices(int mute_mask){
	for(int i=0;i<MAX_VOICES;i++){
		mute_voice[i]=(bool)(mute_mask&1);
		mute_mask>>=1;
	}
}
