#include <cmath>

#include <cstdio>
#include "operator.h"

void Operator::set_wave_list(Wave **list){
	waves=list;
}

_ALWAYS_INLINE_ void Operator::calculate_envelope(){
	if(eg_counter){
		eg_counter--;
		return;
	}
	eg_counter=EG_DIVIDER;
	// PRE_ATTACK: speed+(endlevel if speed>0 else duration)
	// PRE_DECAY: speed+(endlevel if speed>0 else duration)
	// FIXME: Check interactions with eg_repeat
	switch(eg_phase){
		case PRE_ATTACK:
			if(eg_patk_rate>0L){
				eg_vol+=eg_patk_rate;
				if(eg_vol>=eg_patk_level){
					eg_tick=0L;
					eg_vol=eg_repeat==PRE_ATTACK?0L:eg_patk_level;
					eg_phase=eg_repeat==PRE_ATTACK?PRE_ATTACK:ATTACK;
				}
			}else{
				eg_tick+=eg_delta_tick;
				if(eg_tick>=eg_patk_level){
					eg_tick=0L;
					eg_vol=eg_repeat==PRE_ATTACK?0L:eg_vol;
					eg_phase=eg_repeat==PRE_ATTACK?PRE_ATTACK:ATTACK;
				}
			}
			break;
		case ATTACK:
			eg_vol+=eg_atk_rate;
			if(eg_vol>=FP_ONE){
				eg_vol=eg_repeat==ATTACK?eg_patk_level:FP_ONE;
				eg_phase=eg_repeat==ATTACK?PRE_ATTACK:PRE_DECAY;
				eg_tick=0L;
			}
			break;
		case PRE_DECAY:
			if(eg_pdec_rate>0L){
				eg_vol-=eg_pdec_rate;
				if(eg_vol<=eg_pdec_level){
					eg_tick=0L;
					eg_vol=eg_repeat==PRE_DECAY?0L:eg_pdec_level;
					eg_phase=eg_repeat==PRE_DECAY?PRE_ATTACK:DECAY;
				}
			}else{
				eg_tick+=eg_delta_tick;
				if(eg_tick>=eg_pdec_level){
					eg_tick=0L;
					eg_vol=eg_repeat==PRE_DECAY?0L:eg_vol;
					eg_phase=eg_repeat==PRE_DECAY?PRE_ATTACK:DECAY;
				}
			}
			break;
		case DECAY:
			eg_vol-=eg_dec_rate;
			if(eg_vol<=eg_sus_level){
				eg_vol=eg_sus_level;
				eg_phase=eg_repeat==DECAY?PRE_ATTACK:SUSTAIN;
			}
			break;
		case SUSTAIN:
			eg_vol-=eg_sus_rate;
			if(!on){
				eg_phase=eg_repeat==SUSTAIN?PRE_ATTACK:RELEASE;
			}else if(eg_vol<=0L){
				eg_vol=0L;
				eg_phase=eg_repeat==SUSTAIN?PRE_ATTACK:OFF;
			}
			break;
		case SUSTAIN_UP:
			eg_vol+=eg_atk_rate;
			if(!on){
				eg_phase=eg_repeat==SUSTAIN?PRE_ATTACK:RELEASE;
			}else if(eg_vol>=eg_sus_level){
				eg_vol=eg_sus_level;
				eg_phase=SUSTAIN;
			}
			break;
		case RELEASE:
			eg_vol-=eg_rel_rate;
			if(eg_vol<=0L){
				eg_vol=0L;
				eg_phase=eg_repeat==RELEASE?PRE_ATTACK:OFF;
			}
			break;
		default:
			eg_vol=0L;
			enabled=false;
			on=false;
	}
};

_ALWAYS_INLINE_ bool Operator::is_valid_wave(int ix){
	return waves!=NULL && waves[ix]!=NULL;
}

_ALWAYS_INLINE_ void Operator::set_delta(){
	float rec_freq=(is_valid_wave(wave_ix)?waves[wave_ix]->recorded_freq:1.0)*FP_ONE;
	float sam_freq=(is_valid_wave(wave_ix)?waves[wave_ix]->sample_freq:1.0)*mix_rate;
	switch(detune_mode){
		case FIXED:
			delta=(fixed_freq*freq_mul*rec_freq)/(freq_div*sam_freq);
			break;
		case DELTA:
			delta=(((frequency*freq_mul*rec_freq)/freq_div)+(fixed_freq*rec_freq))/sam_freq;
			break;
		default:
			delta=(frequency*freq_mul*detune*rec_freq)/(freq_div*sam_freq);
	}
}

FixedPoint Operator::generate(FixedPoint pm_in,FixedPoint am_lfo_in,FixedPoint fm_lfo_in){
	if(!enabled){
		return 0L;
	}
	calculate_envelope();
	if(!is_valid_wave(wave_ix)){
		return 0L;
	}
	FixedPoint sample=(waves[wave_ix]->generate(phi,pm_in,duty_cycle,wave_state)*eg_vol)>>FP_INT_SHIFT;
	// AM
	FixedPoint mod=((am_lfo_in*am_level)>>FP_INT_SHIFT)+am_floor;
	sample=(sample*mod)>>FP_INT_SHIFT;
	// FM
	mod=((fm_lfo_in*(fm_lfo_in>0?fm_max:fm_min))>>FP_INT_SHIFT)+FP_ONE;
	phi=waves[wave_ix]->fix_loop(phi,(delta*mod)>>FP_INT_SHIFT);
	//
	return sample;
}

_ALWAYS_INLINE_ FixedPoint Operator::get_rate(int rate,int &dst_rate){
	dst_rate=clamp(rate,0,255);
	float inv_rate=256.0-dst_rate;
	inv_rate=(inv_rate*inv_rate/24.0)+1.0;
	float inv_ksr=1.0-((key_cents+200)*key_scale*0.000009); // 0.000009 ≃ 1.0/(key_scale_max(14300)+200)*max_ksr(7)
	return ENVELOPE_RATE_1S/(mix_rate*inv_rate*inv_ksr);
};

void Operator::set_mix_rate(float m){
	mix_rate=m<1.0?1.0:m;
	set_frequency(key_cents,frequency);
	set_attack_rate(attack_rate);
	set_decay_rate(decay_rate);
	set_sustain_rate(sustain_rate);
	set_release_rate(release_rate);
	eg_tick=0L;
	eg_delta_tick=(FP_ONE*EG_DIVIDER)/mix_rate;
}

void Operator::set_frequency(int cents,float _frequency){
	frequency=_frequency;
	key_cents=cents;
	set_delta();
}

void Operator::set_freq_mul(int multiplier){
	freq_mul=clamp(multiplier,1,32);
	set_delta();
}

void Operator::set_freq_div(int divider){
	freq_div=clamp(divider,1,32);
	set_delta();
}

void Operator::set_detune(int frequency,float _detune){
	detune=_detune;
	fixed_freq=frequency;//<0?-frequency:frequency;
	set_delta();
}

void Operator::set_detune_mode(int mode){
	detune_mode=mode;
	set_delta();
}

//

void Operator::set_wave(int wave_num){
	wave_ix=wave_num;
	set_delta();
}

void Operator::set_duty_cycle(FixedPoint _duty_cycle){
	duty_cycle=_duty_cycle;
}

void Operator::set_phase(FixedPoint _phi){
	phi=_phi;
}

void Operator::shift_phase(FixedPoint delta){
	phi+=delta;
}

//

void Operator::set_pre_attack_rate(int rate){
	if(rate>0){
		eg_patk_rate=get_rate(rate,pre_attack_rate);
	}else{
		pre_attack_rate=0;
		eg_patk_rate=0L;
	}
}

void Operator::set_pre_attack_level(int level){
	pre_attack_level=clamp(level,0,255);
	eg_patk_level=(FP_ONE*level)/255;
}

void Operator::set_attack_rate(int rate){
	eg_atk_rate=get_rate(rate,attack_rate);
}

void Operator::set_pre_decay_rate(int rate){
	if(rate>0){
		eg_pdec_rate=get_rate(rate,pre_decay_rate);
	}else{
		pre_decay_rate=0;
		eg_pdec_rate=0L;
	}
}

void Operator::set_pre_decay_level(int level){
	pre_decay_level=clamp(level,0,255);
	eg_pdec_level=(FP_ONE*level)/255;
}

void Operator::set_decay_rate(int rate){
	eg_dec_rate=get_rate(rate,decay_rate);
}

void Operator::set_sustain_level(int level){
	sustain_level=clamp(level,0,255);
	eg_sus_level=(FP_ONE*level)/255;
	if(eg_phase==SUSTAIN || eg_phase==SUSTAIN_UP){
		if(eg_vol>eg_sus_level){
			eg_phase=DECAY;
		}else if(eg_vol<eg_sus_level){
			eg_phase=SUSTAIN_UP;
		}
	}
}

void Operator::set_sustain_rate(int rate){
	if(rate>0){
		eg_sus_rate=get_rate(rate,sustain_rate);
	}else{
		sustain_rate=0;
		eg_sus_rate=0L;
	}
}

void Operator::set_release_rate(int rate){
	eg_rel_rate=get_rate(rate,release_rate);
}

void Operator::set_repeat(int phase){
	eg_repeat=(ADSR)clamp(phase,(int)OFF,(int)PRE_ATTACK);
}

void Operator::set_ksr(int ksr){
	key_scale=clamp(ksr,0,7);
	set_attack_rate(attack_rate);
	set_decay_rate(decay_rate);
	set_sustain_rate(sustain_rate);
	set_release_rate(release_rate);
}

//

void Operator::set_am_intensity(int intensity){
	intensity=clamp(intensity,0,255)+(intensity<=0?0:1);
	am_level=intensity<<15;
	am_floor=FP_ONE-am_level;
}

void Operator::set_fm_intensity(int millis){
	float fm=clamp(millis,0,12000)/12000.0;
	fm_max=(pow(2.0,fm)*FP_ONE)-FP_ONE;
	fm_min=-((pow(2.0,-fm)*FP_ONE)-FP_ONE);
}

//

void Operator::set_enable(bool enable){
	enabled=enable;
}

void Operator::key_on(bool legato){
	enabled=true;
	if(eg_phase==OFF){
		phi=0L;
		eg_counter=0L;
		eg_phase=PRE_ATTACK;
		eg_tick=0;
		on=true;
	}
	if(!legato){
		if(is_valid_wave(wave_ix) && waves[wave_ix]->resets_on_keyon()) {
			phi=0L;
		}
		eg_phase=PRE_ATTACK;
		eg_tick=0;
		on=true;
	}
	set_attack_rate(attack_rate);
	set_pre_attack_rate(pre_attack_rate);
	set_pre_attack_level(pre_attack_level);
	set_decay_rate(decay_rate);
	set_sustain_rate(sustain_rate);
	set_release_rate(release_rate);
}

void Operator::key_off(){
	if(eg_repeat==SUSTAIN){
		eg_phase=PRE_ATTACK;
		on=true;
		eg_tick=0;
	}else{
		eg_phase=RELEASE;
		on=false;
	}
}

void Operator::stop(){
	enabled=false;
	eg_phase=OFF;
	eg_vol=0L;
	phi=0L;
	on=false;
}
