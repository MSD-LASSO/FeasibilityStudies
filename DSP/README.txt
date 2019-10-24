This folder contains DSP simulations.

Reconstruction.m
Dependencies: DiracFloat.m, IfftBlock.m
This program reconstructs an input signal.
It plots (domain plotted noted):
	- Time: input signal
	- Freq: input signal
	- Time: impulse train (drives samples)
	- Time: sampled signal
	- Freq: filter
	- Freq: reconstructed signal
	- Time: reconstructed signal
NOTE: When reconstructing a new signal, edit the initial values at the start of the program. You may need to edit the axis for each plot, and change the value of OscAmplitude.

Signal Alignment
(not created)
Takes 2 signal inputs and aligns them
