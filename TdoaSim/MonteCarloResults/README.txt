These are .mat files saving the workspace for various Monte Carlo runs. NOTE: the symbolic 
Monte Carlo took close to 500 hours. This was split up on several machines and run in parallel to
make it possible.

The recommended results to look at are EdgesAdjustedClosestHyperbolaCost.

There is a theoretical maximum time difference given station locations. This Monte Carlo implements
the latest cost function for TDoA least squares that outputs a cost instead of nan if a time
difference is outside is maximum limit. This improved results. 

Estimated Uncertainty Monte Carlo does not rely on an absolute error when outputting uncertainties.

Time Difference Comparison uses TDoA least squares with time difference optimization, not as
accurate, but simple.

To read these, use plotMonteCarlo. 