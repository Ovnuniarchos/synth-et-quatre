#include "tracker.h"
#include <Vector2.hpp>
#include <cstdio>

using namespace godot;

void SynthTracker::_register_methods(){
	register_method("generate", &SynthTracker::generate);
	register_method("set_mix_rate",&SynthTracker::set_mix_rate);
	register_method("set_note",&SynthTracker::set_note);
	register_method("set_freq_mul",&SynthTracker::set_freq_mul);
	register_method("set_freq_div",&SynthTracker::set_freq_div);
	register_method("set_detune",&SynthTracker::set_detune);

	register_method("set_wave_mode",&SynthTracker::set_wave_mode);
	register_method("set_duty_cycle",&SynthTracker::set_duty_cycle);
	register_method("set_wave",&SynthTracker::set_wave);

	register_method("set_velocity",&SynthTracker::set_velocity);
	register_method("set_attack_rate",&SynthTracker::set_attack_rate);
	register_method("set_decay_rate",&SynthTracker::set_decay_rate);
	register_method("set_sustain_level",&SynthTracker::set_sustain_level);
	register_method("set_sustain_rate",&SynthTracker::set_sustain_rate);
	register_method("set_release_rate",&SynthTracker::set_release_rate);
	register_method("set_repeat",&SynthTracker::set_repeat);

	register_method("set_am_intensity",&SynthTracker::set_am_intensity);
	register_method("set_am_lfo",&SynthTracker::set_am_lfo);
	register_method("set_fm_intensity",&SynthTracker::set_fm_intensity);
	register_method("set_fm_lfo",&SynthTracker::set_fm_lfo);

	register_method("key_on",&SynthTracker::key_on);
	register_method("key_off",&SynthTracker::key_off);
	register_method("stop",&SynthTracker::stop);
	register_method("set_enable",&SynthTracker::set_enable);

	register_method("set_pm_factor",&SynthTracker::set_pm_factor);
	register_method("set_output",&SynthTracker::set_output);

	register_method("set_panning",&SynthTracker::set_panning);

	register_method("set_phase",&SynthTracker::set_phase);

	register_method("set_lfo_wave_mode",&SynthTracker::set_lfo_wave_mode);
	register_method("set_lfo_duty_cycle",&SynthTracker::set_lfo_duty_cycle);
	register_method("set_lfo_freq",&SynthTracker::set_lfo_freq);
}


SynthTracker::SynthTracker(){
}

SynthTracker::~SynthTracker(){
}


void SynthTracker::_init(){
}


//#define TRACE_CMDS
#ifdef TRACE_CMDS
#define TRACE(...) printf(__VA_ARGS__)
#else
#define TRACE(...)
#endif

#ifndef VAR2INT
#define VAR2INT(x) ((int)x)
#endif

#ifndef DVAR2INT
#define DVAR2INT(x,y) ((VAR2INT(x)<<8)|VAR2INT(y))
#endif

PoolVector2Array SynthTracker::generate(int size,float volume,Array cmds){
	buffer.resize(size);
	PoolVector2Array::Write writer=buffer.write();
	volume/=FP_ONE;
	int cmd_ptr=0,cmd_sz=cmds.size(),time=0,next_time=0;
	for(int i=0;size;i++,size--,time++){
		while(cmd_ptr<cmd_sz && time==next_time){
			switch(VAR2INT(cmds[cmd_ptr++])){
				case CMD_WAIT:
					TRACE("WAI %02x  ",VAR2INT(cmds[cmd_ptr]));
					next_time=time+VAR2INT(cmds[cmd_ptr++])+1;
					break;
				case CMD_FREQ:
					TRACE("FRQ %02x %02x %02x%02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]),VAR2INT(cmds[cmd_ptr+3]));
					synth.set_note(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),DVAR2INT(cmds[cmd_ptr+2],cmds[cmd_ptr+3]));
					cmd_ptr+=4;
					break;
				case CMD_KEYON:
					TRACE("KON %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.key_on(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]),false);
					cmd_ptr+=3;
					break;
				case CMD_KEYON_LEGATO:
					TRACE("KOL %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.key_on(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]),true);
					cmd_ptr+=3;
					break;
				case CMD_KEYOFF:
					TRACE("KOF %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]));
					synth.key_off(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]));
					cmd_ptr+=2;
					break;
				case CMD_STOP:
					TRACE("STO %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]));
					synth.stop(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]));
					cmd_ptr+=2;
					break;
				case CMD_ENABLE:
					TRACE("ENA %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_enable(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_MULT:
					TRACE("MUL %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_freq_mul(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_DIV:
					TRACE("DIV %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_freq_div(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_DET:
					TRACE("DET %02x %02x %02x%02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]),VAR2INT(cmds[cmd_ptr+3]));
					synth.set_detune(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),DVAR2INT(cmds[cmd_ptr+2],cmds[cmd_ptr+3]));
					cmd_ptr+=4;
					break;
				case CMD_DUC:
					TRACE("DUC %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_duty_cycle(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_WAVE:
					TRACE("WAV %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_wave_mode(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_VEL:
					TRACE("VEL %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]));
					synth.set_velocity(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]));
					cmd_ptr+=2;
				case CMD_AR:
					TRACE("ATR %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_attack_rate(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_DR:
					TRACE("DER %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_decay_rate(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_SL:
					TRACE("SUL %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_sustain_level(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_SR:
					TRACE("SUR %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_sustain_rate(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_RR:
					TRACE("RER %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_release_rate(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_RM:
					TRACE("RPM %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_repeat(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_PM:
					TRACE("PMF %02x %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]),VAR2INT(cmds[cmd_ptr+3]));
					synth.set_pm_factor(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]),VAR2INT(cmds[cmd_ptr+3]));
					cmd_ptr+=4;
					break;
				case CMD_OUT:
					TRACE("OUT %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_output(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_PAN:{
					int pan_val=VAR2INT(cmds[cmd_ptr+1]);
					TRACE("PAN %02x %02x  ",VAR2INT(cmds[cmd_ptr]),pan_val);
					synth.set_panning(VAR2INT(cmds[cmd_ptr]),pan_val&63,pan_val&64,pan_val&128);
					cmd_ptr+=2;
					break;
				}
				case CMD_PHI:
					TRACE("PHI %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_phase(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_AMS:
					TRACE("AMS %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_am_intensity(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_AM_LFO:
					TRACE("AML %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_am_lfo(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_FMS:
					TRACE("FMS %02x %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]),VAR2INT(cmds[cmd_ptr+3]));
					synth.set_fm_intensity(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),DVAR2INT(cmds[cmd_ptr+2],cmds[cmd_ptr+3]));
					cmd_ptr+=4;
					break;
				case CMD_FM_LFO:
					TRACE("FML %02x %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_fm_lfo(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_LFO_FREQ:
					TRACE("LFF %02x %02x%02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]),VAR2INT(cmds[cmd_ptr+2]));
					synth.set_lfo_freq(VAR2INT(cmds[cmd_ptr+1]),DVAR2INT(cmds[cmd_ptr+1],cmds[cmd_ptr+2]));
					cmd_ptr+=3;
					break;
				case CMD_LFO_WAVE:
					TRACE("LFW %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]));
					synth.set_lfo_wave_mode(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]));
					cmd_ptr+=2;
					break;
				case CMD_LFO_DUC:
					TRACE("LFD %02x %02x  ",VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]));
					synth.set_lfo_duty_cycle(VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]));
					cmd_ptr+=2;
					break;
				case CMD_END:
					TRACE("END@%x  ",cmd_ptr-1);
					cmd_ptr=cmd_sz;
					break;
				default:
					TRACE("??? %02x  ",VAR2INT(cmds[cmd_ptr-1]));
					cmd_ptr=cmd_sz;
			}
		}
		FixedPoint left,right;
		synth.generate(left,right);
		writer[i]=Vector2(left*volume,right*volume);
	}
	TRACE("\n");
	return buffer;
}


void SynthTracker::set_mix_rate(float mix_rate){
	synth.set_mix_rate(mix_rate);
}

void SynthTracker::set_note(int voice,int op_mask,int cents){
	synth.set_note(voice,op_mask,cents);
}

void SynthTracker::set_freq_mul(int voice,int op_mask,int multiplier){
	synth.set_freq_mul(voice,op_mask,multiplier);
}

void SynthTracker::set_freq_div(int voice,int op_mask,int divider){
	synth.set_freq_div(voice,op_mask,divider);
}

void SynthTracker::set_detune(int voice,int op_mask,int millis){
	synth.set_detune(voice,op_mask,millis);
}


void SynthTracker::set_wave_mode(int voice,int op_mask,int mode){
	synth.set_wave_mode(voice,op_mask,mode);
}

void SynthTracker::set_duty_cycle(int voice,int op_mask,FixedPoint duty_cycle){
	synth.set_duty_cycle(voice,op_mask,duty_cycle);
}

void SynthTracker::set_wave(int wave_ix,PoolRealArray wave){
	synth.set_wave(wave_ix,wave);
}


void SynthTracker::set_velocity(int voice,int vel){
	synth.set_velocity(voice,vel);
}

void SynthTracker::set_attack_rate(int voice,int op_mask,int rate){
	synth.set_attack_rate(voice,op_mask,rate);
}

void SynthTracker::set_decay_rate(int voice,int op_mask,int rate){
	synth.set_decay_rate(voice,op_mask,rate);
}

void SynthTracker::set_sustain_level(int voice,int op_mask,int level){
	synth.set_sustain_level(voice,op_mask,level);
}

void SynthTracker::set_sustain_rate(int voice,int op_mask,int rate){
	synth.set_sustain_rate(voice,op_mask,rate);
}

void SynthTracker::set_release_rate(int voice,int op_mask,int rate){
	synth.set_release_rate(voice,op_mask,rate);
}

void SynthTracker::set_repeat(int voice,int op_mask,int phase){
	synth.set_repeat(voice,op_mask,phase);
}


void SynthTracker::set_am_intensity(int voice,int op_mask,int intensity){
	synth.set_am_intensity(voice,op_mask,intensity);
}

void SynthTracker::set_am_lfo(int voice,int op_mask,int lfo){
	synth.set_am_lfo(voice,op_mask,lfo);
}

void SynthTracker::set_fm_intensity(int voice,int op_mask,int millis){
	synth.set_fm_intensity(voice,op_mask,millis);
}

void SynthTracker::set_fm_lfo(int voice,int op_mask,int lfo){
	synth.set_fm_lfo(voice,op_mask,lfo);
}


void SynthTracker::key_on(int voice,int op_mask,int velocity,bool legato){
	synth.key_on(voice,op_mask,velocity,legato);
}

void SynthTracker::key_off(int voice,int op_mask){
	synth.key_off(voice,op_mask);
}

void SynthTracker::stop(int voice,int op_mask){
	synth.stop(voice,op_mask);
}

void SynthTracker::set_enable(int voice,int op_mask,bool enable){
	synth.set_enable(voice,op_mask,enable);
}


void SynthTracker::set_pm_factor(int voice,int op_from,int op_to,int pm_factor){
	synth.set_pm_factor(voice,op_from,op_to,pm_factor);
}

void SynthTracker::set_output(int voice,int op_mask,int volume){
	synth.set_output(voice,op_mask,volume);
}


void SynthTracker::set_panning(int voice,int panning,bool invert_left,bool invert_right){
	synth.set_panning(voice,panning,invert_left,invert_right);
}


void SynthTracker::set_phase(int voice,int op_mask,int phi){
	synth.set_phase(voice,op_mask,phi);
}


void SynthTracker::set_lfo_freq(int lfo,float frequency){
	synth.set_lfo_freq(lfo,frequency*256.0);
}

void SynthTracker::set_lfo_wave_mode(int lfo,int mode){
	synth.set_lfo_wave_mode(lfo,mode);
}

void SynthTracker::set_lfo_duty_cycle(int lfo,int duty_cycle){
	synth.set_lfo_duty_cycle(lfo,duty_cycle);
}
