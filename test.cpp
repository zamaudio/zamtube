#include <stdio.h>
#include <cmath>
#include "wdf.h"

int main(){ 
	T Fs = 48000.0;
	int N = Fs;
	T gain = 40.5;
	T f0 =2000.0;
	T input[384000] = { 0.0 };
	T output[384000] = { 0.0 };
	int i;
	for (i = 0; i < N; ++i) {
		input[i] = gain*sin(2.0*M_PI*f0/Fs*i);
	}

	//Model
	V Vi = V(0.0,100);
	C C1 = C(1e-9, Fs);
	R R1 = R(2e6);
	T Rl = 2e6;

	ser S0 = ser(&Vi, &C1);
	par P0 = par(&S0, &R1);

	
	for (int j = 0; j < N; ++j) {
		//Step 1: read input sample as voltage for the source
		Vi.e = input[j];

		//Step 2: propagate waves up to the 3 roots
		P0.waveUp();

		//Step 3: compute wave reflections at non-linearity
		
		//Step 4: propagate waves leaving non-linearity back to the leaves
		P0.setWD((Rl - P0.PortRes)/(Rl + P0.PortRes)*-P0.WU);

		//Step 5: measure the voltage across the output load resistance and set the sample
		output[j] = R1.Voltage();
		printf("%f %f %f\n", j/Fs, input[j], output[j]);
	}
}

