#ifndef WAVE_H
#define WAVE_H

#include <cstddef>
#include "common_defs.h"

class Wave{
public:
	virtual FixedPoint generate(FixedPoint phi,FixedPoint pm_in,FixedPoint duty_cycle){return 0L;};

	virtual FixedPoint fix_loop(FixedPoint phi,FixedPoint mod_in){return phi+mod_in;};

	virtual FixedPoint get_size(){return FP_ONE;};

	virtual float get_recorded_freq(){return 1.0;};

	virtual float get_sample_freq(){return 1.0;};
};

#endif