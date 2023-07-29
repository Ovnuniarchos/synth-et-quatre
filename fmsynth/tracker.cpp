#include "tracker.h"
#include <Vector2.hpp>
#include <cstdio>

using namespace godot;

extern "C" void GDN_EXPORT fmsynth_gdnative_init(godot_gdnative_init_options *o){
	Godot::gdnative_init(o);
}

extern "C" void GDN_EXPORT fmsynth_gdnative_terminate(godot_gdnative_terminate_options *o){
	Godot::gdnative_terminate(o);
}

extern "C" void GDN_EXPORT fmsynth_nativescript_init(void *handle){
	Godot::nativescript_init(handle);
	register_class<SynthTracker>();
}

void SynthTracker::_register_methods(){
	register_method("generate", &SynthTracker::generate);
	register_method("set_mix_rate",&SynthTracker::set_mix_rate);
	register_method("set_note",&SynthTracker::set_note);
	register_method("set_freq_mul",&SynthTracker::set_freq_mul);
	register_method("set_freq_div",&SynthTracker::set_freq_div);
	register_method("set_detune",&SynthTracker::set_detune);

	register_method("set_wave",&SynthTracker::set_wave);
	register_method("set_duty_cycle",&SynthTracker::set_duty_cycle);
	register_method("define_wave",&SynthTracker::define_wave);
	register_method("define_sample",&SynthTracker::define_sample);

	register_method("set_volume",&SynthTracker::set_volume);
	register_method("set_attack_rate",&SynthTracker::set_attack_rate);
	register_method("set_decay_rate",&SynthTracker::set_decay_rate);
	register_method("set_sustain_level",&SynthTracker::set_sustain_level);
	register_method("set_sustain_rate",&SynthTracker::set_sustain_rate);
	register_method("set_release_rate",&SynthTracker::set_release_rate);
	register_method("set_repeat",&SynthTracker::set_repeat);
	register_method("set_ksr",&SynthTracker::set_ksr);

	register_method("set_am_intensity",&SynthTracker::set_am_intensity);
	register_method("set_am_lfo",&SynthTracker::set_am_lfo);
	register_method("set_fm_intensity",&SynthTracker::set_fm_intensity);
	register_method("set_fm_lfo",&SynthTracker::set_fm_lfo);

	register_method("key_on",&SynthTracker::key_on);
	register_method("key_off",&SynthTracker::key_off);
	register_method("stop",&SynthTracker::stop);
	register_method("set_enable",&SynthTracker::set_enable);
	register_method("set_clip",&SynthTracker::set_clip);

	register_method("set_pm_factor",&SynthTracker::set_pm_factor);
	register_method("set_output",&SynthTracker::set_output);

	register_method("set_panning",&SynthTracker::set_panning);

	register_method("set_phase",&SynthTracker::set_phase);
	register_method("shift_phase",&SynthTracker::shift_phase);

	register_method("set_lfo_wave",&SynthTracker::set_lfo_wave);
	register_method("set_lfo_duty_cycle",&SynthTracker::set_lfo_duty_cycle);
	register_method("set_lfo_freq",&SynthTracker::set_lfo_freq);
	register_method("set_lfo_phase",&SynthTracker::set_lfo_phase);

	register_method("mute_voices",&SynthTracker::mute_voices);
}


SynthTracker::SynthTracker(){
}

SynthTracker::~SynthTracker(){
}


void SynthTracker::_init(){
}

#define TRACE_WAIT "WAI[%d] "
#define TRACE_FREQUENCY "FRQ[%d %02x %d] "
#define TRACE_KEYON "KON[%d %02x %d] "
#define TRACE_KEYON_LEG "KOL[%d %02x %d] "
#define TRACE_KEYON_STA "KOS[%d %02x %d] "
#define TRACE_KEYOFF "KOF[%d %02x] "
#define TRACE_STOP "STO[%d %02x] "
#define TRACE_ENABLE "ENA[%d %02x %02x] "
#define TRACE_MUL "MUL[%d %02x %d] "
#define TRACE_DIV "DIV[%d %02x %d] "
#define TRACE_DETUNE "DET[%d %02x %d] "
#define TRACE_DUTY "DUC[%d %02x %06x] "
#define TRACE_WAVE "WAV[%d %02x %d] "
#define TRACE_VOLUME "VOL[%d %d] "
#define TRACE_ATTACK "ATR[%d %02x %d] "
#define TRACE_DECAY "DER[%d %02x %d] "
#define TRACE_SUST_LEVEL "SUL[%d %02x %d] "
#define TRACE_SUST_RATE "SUR[%d %02x %d] "
#define TRACE_RELEASE "RER[%02x %02x %02x] "
#define TRACE_ENV_REPEAT "RPM[%d %02x %d] "
#define TRACE_KEY_SCALE "KSR[%d %02x %d] "
#define TRACE_PM_FACTOR "PMF[%d %02x %02x %d] "
#define TRACE_OUTPUT "OUT[%d %02x %d] "
#define TRACE_PAN "PAN[%d %02x] "
#define TRACE_PHI "PHI[%d %02x %06x] "
#define TRACE_AM_FACTOR "AMS[%d %02x %d] "
#define TRACE_AM_LFO "AML[%d %02x %d] "
#define TRACE_FM_FACTOR "FMS[%d %02x %d] "
#define TRACE_FM_LFO "FML[%d %02x %d] "
#define TRACE_LFO_FREQUENCY "LFF[%d %d] "
#define TRACE_LFO_WAVE "LFW[%d %d] "
#define TRACE_LFO_DUTY_CYCLE "LFD[%d %d] "
#define TRACE_LFO_PHI "LFP[%d %d] "
#define TRACE_CLIP "CLIP[%d %02x] "
#define TRACE_DEBUG "DEBUG@%d "
#define TRACE_END "END@%d "
#define TRACE_UNKNOWN "???[%08x] "

// #define TRACE_CMDS
#ifdef TRACE_CMDS
#define TRACE(...) printf(__VA_ARGS__)
#else
#define TRACE(...)
#endif

#ifndef VAR2INT
#define VAR2INT(x) ((int32_t)x)
#endif

Array SynthTracker::generate(int size,float volume,Array cmds){
	buffer.resize(size);
	volume/=FP_ONE;
	int cmd_ptr=0;
	int cmd_sz=cmds.size();
	int next_time=0;
	uint8_t command;
	uint8_t voice;
	uint8_t op_mask;
	uint8_t data_8;
	int data;
	for(int time=0;size;size--,time++){
		while(cmd_ptr<cmd_sz && time==next_time){
			command=VAR2INT(cmds[cmd_ptr]);
			voice=VAR2INT(cmds[cmd_ptr])>>8;
			op_mask=VAR2INT(cmds[cmd_ptr])>>16;
			data_8=VAR2INT(cmds[cmd_ptr++])>>24;
			switch(command){
				case CMD_WAIT:
					data=VAR2INT(cmds[cmd_ptr++]);
					TRACE(TRACE_WAIT,data);
					next_time=time+data+1;
					break;
				case CMD_FREQ:
					data=VAR2INT(cmds[cmd_ptr++]);
					TRACE(TRACE_FREQUENCY,voice,op_mask,data);
					synth.set_note(voice,op_mask,data);
					break;
				case CMD_KEYON:
					TRACE(TRACE_KEYON,voice,op_mask,data_8);
					synth.key_on(voice,op_mask,data_8,false);
					break;
				case CMD_KEYON_LEG:
					TRACE(TRACE_KEYON_LEG,voice,op_mask,data_8);
					synth.key_on(voice,op_mask,data_8,true);
					break;
				case CMD_KEYON_STA:
					TRACE(TRACE_KEYON_STA,voice,op_mask,data_8);
					synth.stop(voice,op_mask);
					synth.key_on(voice,op_mask,data_8,false);
					break;
				case CMD_KEYOFF:
					TRACE(TRACE_KEYOFF,voice,op_mask);
					synth.key_off(voice,op_mask);
					break;
				case CMD_STOP:
					TRACE(TRACE_STOP,voice,op_mask);
					synth.stop(voice,op_mask);
					break;
				case CMD_ENABLE:
					TRACE(TRACE_ENABLE,voice,op_mask,data_8);
					synth.set_enable(voice,op_mask,data_8);
					break;
				case CMD_MULT:
					TRACE(TRACE_MUL,voice,op_mask,data_8);
					synth.set_freq_mul(voice,op_mask,data_8);
					break;
				case CMD_DIV:
					TRACE(TRACE_DIV,voice,op_mask,data_8);
					synth.set_freq_div(voice,op_mask,data_8);
					break;
				case CMD_DET:
					data=VAR2INT(cmds[cmd_ptr++]);
					TRACE(TRACE_DETUNE,voice,op_mask,data);
					synth.set_detune(voice,op_mask,data);
					break;
				case CMD_DUC:
					data=VAR2INT(cmds[cmd_ptr++]);
					TRACE(TRACE_DUTY,voice,op_mask,data);
					synth.set_duty_cycle(voice,op_mask,data);
					break;
				case CMD_WAVE:
					TRACE(TRACE_WAVE,voice,op_mask,data_8);
					synth.set_wave(voice,op_mask,data_8);
					break;
				case CMD_VOL:
					TRACE(TRACE_VOLUME,voice,op_mask);
					synth.set_volume(voice,op_mask);
				case CMD_AR:
					TRACE(TRACE_ATTACK,voice,op_mask,data_8);
					synth.set_attack_rate(voice,op_mask,data_8);
					break;
				case CMD_DR:
					TRACE(TRACE_DECAY,voice,op_mask,data_8);
					synth.set_decay_rate(voice,op_mask,data_8);
					break;
				case CMD_SL:
					TRACE(TRACE_SUST_LEVEL,voice,op_mask,data_8);
					synth.set_sustain_level(voice,op_mask,data_8);
					break;
				case CMD_SR:
					TRACE(TRACE_SUST_RATE,voice,op_mask,data_8);
					synth.set_sustain_rate(voice,op_mask,data_8);
					break;
				case CMD_RR:
					TRACE(TRACE_RELEASE,voice,op_mask,data_8);
					synth.set_release_rate(voice,op_mask,data_8);
					break;
				case CMD_RM:
					TRACE(TRACE_ENV_REPEAT,voice,op_mask,data_8);
					synth.set_repeat(voice,op_mask,data_8);
					break;
				case CMD_KSR:
					TRACE(TRACE_KEY_SCALE,voice,op_mask,data_8);
					synth.set_ksr(voice,op_mask,data_8);
					break;
				case CMD_PM:
					data=VAR2INT(cmds[cmd_ptr++]);
					TRACE(TRACE_PM_FACTOR,voice,data_8,op_mask,data);
					synth.set_pm_factor(voice,data_8,op_mask,data);
					break;
				case CMD_OUT:
					TRACE(TRACE_OUTPUT,voice,op_mask,data_8);
					synth.set_output(voice,op_mask,data_8);
					break;
				case CMD_PAN:
					TRACE(TRACE_PAN,voice,op_mask);
					synth.set_panning(voice,op_mask&0x3f,op_mask&0x40,op_mask&0x80);
					break;
				case CMD_PHI:
					data=VAR2INT(cmds[cmd_ptr++]);
					TRACE(TRACE_PHI,voice,op_mask,data);
					synth.set_phase(voice,op_mask,data);
					break;
				case CMD_AMS:
					TRACE(TRACE_AM_FACTOR,voice,op_mask,data_8);
					synth.set_am_intensity(voice,op_mask,data_8);
					break;
				case CMD_AM_LFO:
					TRACE(TRACE_AM_LFO,voice,op_mask,data_8);
					synth.set_am_lfo(voice,op_mask,data_8);
					break;
				case CMD_FMS:
					data=VAR2INT(cmds[cmd_ptr++]);
					TRACE(TRACE_FM_FACTOR,voice,op_mask,data);
					synth.set_fm_intensity(voice,op_mask,data);
					break;
				case CMD_FM_LFO:
					TRACE(TRACE_FM_LFO,voice,op_mask,data_8);
					synth.set_fm_lfo(voice,op_mask,data_8);
					break;
				case CMD_LFO_FREQ:
					data=VAR2INT(cmds[cmd_ptr++]);
					TRACE(TRACE_LFO_FREQUENCY,voice,op_mask,data/256.0f);
					synth.set_lfo_freq(voice,data/256.0f);
					break;
				case CMD_LFO_WAVE:
					TRACE(TRACE_LFO_WAVE,voice,op_mask);
					synth.set_lfo_wave(voice,op_mask);
					break;
				case CMD_LFO_DUC:
					data=VAR2INT(cmds[cmd_ptr++]);
					TRACE(TRACE_LFO_DUTY_CYCLE,voice,data);
					synth.set_lfo_duty_cycle(voice,data);
					break;
				case CMD_LFO_PHI:
					data=VAR2INT(cmds[cmd_ptr++]);
					TRACE(TRACE_LFO_PHI,voice,data);
					synth.set_lfo_phase(voice,data);
					break;
				case CMD_CLIP:
					TRACE(TRACE_CLIP,voice,data_8);
					synth.set_clip(voice,data_8);
					break;
				case CMD_DEBUG:
					TRACE(TRACE_DEBUG,cmd_ptr-1);
					debug(cmds,cmd_ptr-1);
					break;
				case CMD_END:
					TRACE(TRACE_END,cmd_ptr-1);
					cmd_ptr=cmd_sz;
					break;
				default:
					TRACE(TRACE_UNKNOWN,VAR2INT(cmds[cmd_ptr-1]));
					cmd_ptr=cmd_sz;
			}
		}
		FixedPoint left,right;
		synth.generate(left,right);
		buffer[time]=Vector2(left*volume,right*volume);
	}
	TRACE("\n");
	return buffer;
}

void SynthTracker::debug(Array cmds,int end_ix){
	uint8_t command;
	uint8_t voice;
	uint8_t op_mask;
	uint8_t data_8;
	int data;
	printf(">>>> DEBUG [0 - %d]\n",end_ix);
	for(int cmd_ptr=0;cmd_ptr<=end_ix;){
		command=VAR2INT(cmds[cmd_ptr])&0xff;
		voice=VAR2INT(cmds[cmd_ptr])>>8;
		op_mask=VAR2INT(cmds[cmd_ptr])>>16;
		data_8=VAR2INT(cmds[cmd_ptr++])>>24;
		switch(command){
			case CMD_WAIT:
				data=VAR2INT(cmds[cmd_ptr++]);
				printf(TRACE_WAIT,data);
				break;
			case CMD_FREQ:
				data=VAR2INT(cmds[cmd_ptr++]);
				printf(TRACE_FREQUENCY,voice,op_mask,data);
				break;
			case CMD_KEYON:
				printf(TRACE_KEYON,voice,op_mask,data_8);
				break;
			case CMD_KEYON_LEG:
				printf(TRACE_KEYON_LEG,voice,op_mask,data_8);
				break;
			case CMD_KEYON_STA:
				printf(TRACE_KEYON_STA,voice,op_mask,data_8);
				break;
			case CMD_KEYOFF:
				printf(TRACE_KEYOFF,voice,op_mask);
				break;
			case CMD_STOP:
				printf(TRACE_STOP,voice,op_mask);
				break;
			case CMD_ENABLE:
				printf(TRACE_ENABLE,voice,op_mask,data_8);
				break;
			case CMD_MULT:
				printf(TRACE_MUL,voice,op_mask,data_8);
				break;
			case CMD_DIV:
				printf(TRACE_DIV,voice,op_mask,data_8);
				break;
			case CMD_DET:
				data=VAR2INT(cmds[cmd_ptr++]);
				printf(TRACE_DETUNE,voice,op_mask,data);
				break;
			case CMD_DUC:
				data=VAR2INT(cmds[cmd_ptr++]);
				printf(TRACE_DUTY,voice,op_mask,data);
				break;
			case CMD_WAVE:
				printf(TRACE_WAVE,voice,op_mask,data_8);
				break;
			case CMD_VOL:
				printf(TRACE_VOLUME,voice,op_mask);
				break;
			case CMD_AR:
				printf(TRACE_ATTACK,voice,op_mask,data_8);
				break;
			case CMD_DR:
				printf(TRACE_DECAY,voice,op_mask,data_8);
				break;
			case CMD_SL:
				printf(TRACE_SUST_LEVEL,voice,op_mask,data_8);
				break;
			case CMD_SR:
				printf(TRACE_SUST_RATE,voice,op_mask,data_8);
				break;
			case CMD_RR:
				printf(TRACE_RELEASE,voice,op_mask,data_8);
				break;
			case CMD_RM:
				printf(TRACE_ENV_REPEAT,voice,op_mask,data_8);
				break;
			case CMD_KSR:
				printf(TRACE_KEY_SCALE,voice,op_mask,data_8);
				break;
			case CMD_PM:
				data=VAR2INT(cmds[cmd_ptr++]);
				printf(TRACE_PM_FACTOR,voice,data_8,op_mask,data);
				break;
			case CMD_OUT:
				printf(TRACE_OUTPUT,voice,op_mask,data_8);
				break;
			case CMD_PAN:
				printf(TRACE_PAN,voice,op_mask);
				break;
			case CMD_PHI:
				data=VAR2INT(cmds[cmd_ptr++]);
				printf(TRACE_PHI,voice,op_mask,data);
				break;
			case CMD_AMS:
				printf(TRACE_AM_FACTOR,voice,op_mask,data_8);
				break;
			case CMD_AM_LFO:
				printf(TRACE_AM_LFO,voice,op_mask,data_8);
				break;
			case CMD_FMS:
				data=VAR2INT(cmds[cmd_ptr++]);
				printf(TRACE_FM_FACTOR,voice,op_mask,data);
				break;
			case CMD_FM_LFO:
				printf(TRACE_AM_LFO,voice,op_mask,data_8);
				break;
			case CMD_LFO_FREQ:
				data=VAR2INT(cmds[cmd_ptr++]);
				printf(TRACE_LFO_FREQUENCY,voice,op_mask,data/256.0f);
				break;
			case CMD_LFO_WAVE:
				printf(TRACE_LFO_WAVE,voice,op_mask);
				break;
			case CMD_LFO_DUC:
				data=VAR2INT(cmds[cmd_ptr++]);
				printf(TRACE_LFO_DUTY_CYCLE,voice,data);
				break;
			case CMD_LFO_PHI:
				data=VAR2INT(cmds[cmd_ptr++]);
				printf(TRACE_LFO_PHI,VAR2INT(cmds[cmd_ptr]),VAR2INT(cmds[cmd_ptr+1]));
				break;
			case CMD_CLIP:
				printf(TRACE_CLIP,voice,data_8);
				break;
			case CMD_DEBUG:
				printf(TRACE_DEBUG,cmd_ptr-1);
				break;
			case CMD_END:
				printf(TRACE_END,cmd_ptr-1);
				break;
			default:
				printf(TRACE_UNKNOWN,VAR2INT(cmds[cmd_ptr-1]));
		}
	}
	printf("<<<< DEBUG [0 - %d]\n",end_ix);
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


void SynthTracker::set_wave(int voice,int op_mask,int wave_num){
	synth.set_wave(voice,op_mask,wave_num);
}

void SynthTracker::set_duty_cycle(int voice,int op_mask,FixedPoint duty_cycle){
	synth.set_duty_cycle(voice,op_mask,duty_cycle);
}

void SynthTracker::set_phase(int voice,int op_mask,FixedPoint phi){
	synth.set_phase(voice,op_mask,phi);
}

void SynthTracker::shift_phase(int voice,int op_mask,FixedPoint delta){
	synth.shift_phase(voice,op_mask,delta);
}

void SynthTracker::define_wave(int wave_num,Array wave){
	synth.define_wave(wave_num,wave);
	wave.clear();
}

void SynthTracker::define_sample(int wave_num,int loop_start,int loop_end,float rec_freq,float sam_freq,Array sample){
	synth.define_sample(wave_num,loop_start,loop_end,rec_freq,sam_freq,sample);
	sample.clear();
}


void SynthTracker::set_volume(int voice,int vel){
	synth.set_volume(voice,vel);
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

void SynthTracker::set_ksr(int voice,int op_mask,int ksr){
	synth.set_ksr(voice,op_mask,ksr);
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

void SynthTracker::set_enable(int voice,int op_mask,int enable_bits){
	synth.set_enable(voice,op_mask,enable_bits);
}

void SynthTracker::set_clip(int voice,bool clip){
	synth.set_clip(voice,clip);
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


void SynthTracker::set_lfo_freq(int lfo,float frequency){
	synth.set_lfo_freq(lfo,frequency);
}

void SynthTracker::set_lfo_wave(int lfo,int wave_num){
	synth.set_lfo_wave(lfo,wave_num);
}

void SynthTracker::set_lfo_duty_cycle(int lfo,FixedPoint duty_cycle){
	synth.set_lfo_duty_cycle(lfo,duty_cycle);
}

void SynthTracker::set_lfo_phase(int lfo,FixedPoint phi){
	synth.set_lfo_phase(lfo,phi);
}


void SynthTracker::mute_voices(int mute_mask){
	synth.mute_voices(mute_mask);
}
