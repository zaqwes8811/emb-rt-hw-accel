#include "scilab/scicos_block4.h"
#include "scilab/scicos.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define r_IN(n, i) ((GetRealInPortPtrs(blk, n+1))[(i)])
#define r_OUT(n, i) ((GetRealOutPortPtrs(blk, n+1))[(i)])

// parameters
#define Lhi (GetRparPtrs(blk)[0]) // integrator high limit
#define Llo (GetRparPtrs(blk)[1]) // integrator low limit

// inputs
#define in (r_IN(0,0)) // integrator input
#define gainp (r_IN(1,0)) // integrator gain when X > 0
#define gainn (r_IN(2,0)) // integrator gain when X <= 0

// states
#define X (GetState(blk)[0]) // integrator state
#define Xdot (GetDerState(blk)[0]) // derivative of the integrator output

// outputs
#define out (r_OUT(0, 0)) // integrator output
#define Igain (r_OUT(1, 0)) // integrator gain

// other constants
#define surf0 (GetGPtrs(blk)[0])
#define surf1 (GetGPtrs(blk)[1])
#define surf2 (GetGPtrs(blk)[2])
#define mode0 (GetModePtrs(blk)[0])

// if X is greater than Lhi, then mode is 1
// if X is between Lhi and zero, then mode is 2
// if X is between zero and Llo, then mode is 3
// if X is less than Llo, then mode is 4

#define mode_xhzl 1
#define mode_hxzl 2
#define mode_hzxl 3
#define mode_hzlx 4

extern void h();

void lim_int(scicos_block *blk, int flag)
{
	h();

	double gain = 0;
	switch (flag)
	{
	case 0:
		// compute the derivative of the continuous time state
		if ((mode0 == mode_xhzl && in < 0) || mode0 == mode_hxzl)
			gain = gainp;
		else if ((mode0 == mode_hzlx && in > 0) || mode0 == mode_hzxl)
			gain = gainn;
		Xdot = gain * in;
		break;

	case 1:
		// compute the outputs of the block
		if (X >= Lhi || X <= Llo)
			Igain = 0;
		else if (X > 0)
			Igain = gainp;
		else
			Igain = gainn;
			out = X;
		break;

	case 9:
		// compute zero crossing surfaces and set modes
		surf0 = X - Lhi;
		surf1 = X;
		surf2 = X - Llo;

		if (get_phase_simulation() == 1)
		{
			if (surf0 >= 0)
				mode0 = mode_xhzl;
			else if (surf2 <= 0)
				mode0 = mode_hzlx;
			else if (surf1 > 0)
				mode0 = mode_hxzl;
			else
				mode0 = mode_hzxl;
		}
		break;
}
}
