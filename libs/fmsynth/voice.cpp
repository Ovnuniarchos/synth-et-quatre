#include <cmath>
#include <cstdio>
#include "voice.h"

void Voice::set_wave_list(Wave **list){
	for(int i=0;i<MAX_OPS;i++) ops[i].set_wave_list(list);
}

FixedPoint Voice::generate(FixedPoint* lfo_ins){
	FixedPoint out=0L;
	for(int i=0;i<MAX_OPS;i++){
		FixedPoint pm=0L;
		for(int j=0;j<MAX_OPS;j++){
			if(i==j){
				pm+=(last_samples[0][j]+last_samples[1][j])*pms[j][i];
			}else{
				pm+=last_samples[0][j]*pms[j][i];
			}
		}
		pm>>=8;
		last_samples[1][i]=last_samples[0][i];
		last_samples[0][i]=ops[i].generate(pm,lfo_ins[am_lfos[i]],lfo_ins[fm_lfos[i]]);
		out+=last_samples[0][i]*outs[i];
	}
	if(volume>new_volume){
		volume--;
	}else if(volume<new_volume){
		volume++;
	}
	return ((clip?clamp(out,-CLIP,CLIP):out)*volume)>>16;
};

void Voice::set_mix_rate(float mix_rate){
	for(int i=0;i<MAX_OPS;i++){
		ops[i].set_mix_rate(mix_rate);
	}
}

void Voice::set_note(int op_mask,int cents){
	cents=clamp(cents,-200,14300); // Some leeway beyond MIDI 0-127
	float freq=pow(2.0,(cents-6900)/1200.0)*440.0;
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_frequency(cents,freq);
	}
}

void Voice::set_freq_mul(int op_mask,int multiplier){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_freq_mul(multiplier);
	}
}

void Voice::set_freq_div(int op_mask,int divider){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_freq_div(divider);
	}
}

void Voice::set_detune(int op_mask,int millis){
	millis=clamp(millis,-12000,12000);
	float detune=pow(2.0,millis/12000.0);
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_detune(millis,detune);
	}
}

void Voice::set_detune_mode(int op_mask,int mode){
	mode=clamp(mode,0,2);
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_detune_mode(mode);
	}
}


void Voice::set_wave(int op_mask,int wave_num){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_wave(wave_num);
	}
}

void Voice::set_duty_cycle(int op_mask,FixedPoint duty_cycle){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_duty_cycle(duty_cycle);
	}
}

void Voice::set_phase(int op_mask,FixedPoint phi){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_phase(phi);
	}
}

void Voice::shift_phase(int op_mask,FixedPoint delta){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].shift_phase(delta);
	}
}


void Voice::set_velocity(int vel){
	new_volume=clamp(vel,0,255)+(vel==0?0:1);
}

void Voice::set_pre_attack_rate(int op_mask,int rate){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_pre_attack_rate(rate);
	}
}

void Voice::set_pre_attack_level(int op_mask,int level){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_pre_attack_level(level);
	}
}

void Voice::set_attack_rate(int op_mask,int rate){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_attack_rate(rate);
	}
}

void Voice::set_pre_decay_rate(int op_mask,int rate){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_pre_decay_rate(rate);
	}
}

void Voice::set_pre_decay_level(int op_mask,int level){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_pre_decay_level(level);
	}
}

void Voice::set_decay_rate(int op_mask,int rate){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_decay_rate(rate);
	}
}

void Voice::set_sustain_level(int op_mask,int level){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_sustain_level(level);
	}
}

void Voice::set_sustain_rate(int op_mask,int rate){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_sustain_rate(rate);
	}
}

void Voice::set_release_rate(int op_mask,int rate){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_release_rate(rate);
	}
}

void Voice::set_repeat(int op_mask,int phase){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_repeat(phase);
	}
}

void Voice::set_ksr(int op_mask,int ksr){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_ksr(ksr);
	}
}


void Voice::set_am_intensity(int op_mask,int intensity){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_am_intensity(intensity);
	}
}

void Voice::set_am_lfo(int op_mask,int lfo){
	lfo=clamp(lfo,0,255);
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) am_lfos[i]=lfo;
	}
}

void Voice::set_fm_intensity(int op_mask,int millis){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].set_fm_intensity(millis);
	}
}

void Voice::set_fm_lfo(int op_mask,int lfo){
	lfo=clamp(lfo,0,255);
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) fm_lfos[i]=lfo;
	}
}


void Voice::key_on(int op_mask,int vol,bool legato){
	new_volume=clamp(vol,0,255)+(vol>0?1:0);
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		ops[i].key_on(legato);
	}
}

void Voice::key_off(int op_mask){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) ops[i].key_off();
	}
}

void Voice::stop(int op_mask){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1){
			ops[i].stop();
			last_samples[0][i]=0L;
			last_samples[1][i]=0L;
		}
	}
}

void Voice::set_enable(int op_mask,int enable_bits){
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1,enable_bits>>=1){
		if(op_mask&1) ops[i].set_enable(enable_bits&1);
	}
}


void Voice::set_pm_factor(int op_from,int op_to,int factor){
	op_from=clamp(op_from,0,MAX_OPS-1);
	op_to=clamp(op_to,0,MAX_OPS-1);
	int pmf=clamp(factor,0,255)+(factor<=0?0:1);
	if(op_from!=op_to){
		pmf*=2;
	}
	pms[op_from][op_to]=pmf;
}

void Voice::set_output(int op_mask,int vol){
	vol=clamp(vol,0,255)+(vol<=0?0:1);
	for(int i=0;i<MAX_OPS;i++,op_mask>>=1){
		if(op_mask&1) outs[i]=vol;
	}
}


void Voice::set_panning(int panning,bool invert_left,bool invert_right){
	panning=clamp(panning,1,255);
	vol_left=(256-panning)+(panning<255?1:-1);
	if(invert_left){
		vol_left=-vol_left;
	}
	vol_right=(panning>1)?panning+1:0;
	if(invert_right){
		vol_right=-vol_right;
	}
}
