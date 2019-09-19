#include <cmath>

#include "operator.h"

FixedPoint Operator::get_rate(int rate,int &var){
	var=clamp(rate,0,255);
	if (var<128) return (ENVELOPE_RATE*var)/(mix_rate*128);
	return (ENVELOPE_RATE<<8)/(mix_rate*(256-var));
};

void Operator::set_mix_rate(float m){
	mix_rate=m<1.0?1.0:m;
	set_frequency(frequency);
	set_attack_rate(attack_rate);
	set_decay_rate(decay_rate);
	set_sustain_rate(sustain_rate);
	set_release_rate(release_rate);
}

void Operator::set_frequency(float frequency){
	this->frequency=frequency;
	set_delta();
}

void Operator::set_freq_mul(int multiplier){
	freq_mul=clamp(multiplier,0,31)+1;
	set_delta();
}

void Operator::set_freq_div(int divider){
	freq_div=clamp(divider,0,31)+1;
	set_delta();
}

void Operator::set_detune(float detune){
	this->detune=detune;
	set_delta();
}


void Operator::set_wave_mode(int mode){
	wave.set_mode(mode);
}

void Operator::set_duty_cycle(FixedPoint duty_cycle){
	wave.set_duty_cycle(duty_cycle);
}

void Operator::set_wave(UserWave **user_wave){
	wave.set_wave(user_wave);
}


void Operator::set_attack_rate(int rate){
	eg_ar=get_rate(rate,attack_rate);
}

void Operator::set_decay_rate(int rate){
	eg_dr=get_rate(rate,decay_rate);
}

void Operator::set_sustain_level(int level){
	sustain_level=clamp(level,0,255);
	eg_sl=(FP_ONE*level)/255;
}

void Operator::set_sustain_rate(int rate){
	if(rate>0){
		eg_sr=get_rate(rate,sustain_rate);
	}else{
		sustain_rate=0;
		eg_sr=0L;
	}
}

void Operator::set_release_rate(int rate){
	eg_rr=get_rate(rate,release_rate);
}

void Operator::set_repeat(int phase){
	eg_repeat=(ADSR)clamp(phase,(int)OFF,(int)ATTACK);
}


void Operator::set_am_intensity(int intensity){
	intensity&=255;
	intensity+=(intensity==0?0:1);
	am_level=intensity<<15;
	am_floor=FP_ONE-am_level;
}

void Operator::set_fm_intensity(int millis){
	float fm=clamp(millis,0,12000)/12000.0;
	fm_max=(pow(2.0,fm)*FP_ONE)-FP_ONE;
	fm_min=-((pow(2.0,-fm)*FP_ONE)-FP_ONE);
}


void Operator::key_on(bool legato){
	enabled=true;
	if(eg_phase==OFF){
		phi=0L;
		eg_counter=EG_DIVIDER;
		eg_phase=ATTACK;
		on=true;
	}
	if(!legato){
		eg_phase=ATTACK;
		on=true;
	}
}

void Operator::key_off(){
	if(enabled){
		eg_phase=eg_repeat==SUSTAIN?ATTACK:RELEASE;
		on=false;
	}
}

void Operator::stop(){
	eg_phase=OFF;
	eg_vol=0L;
	enabled=false;
	on=false;
}


void Operator::set_phase(FixedPoint phi){
	this->phi=phi;
}
