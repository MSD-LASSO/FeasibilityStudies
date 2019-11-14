This folder contains a program to run a 3 station TDoA simulation, which will be used to easily see the effects that different parameters (e.g., ground station location, ground station location error, clock synchronization error, satellite position) will have on our TDoA calculations. We will use a spherical earth for the calculations.

We currently have three programs.

1. Main (TopLevel)

2. Calculate Time Difference (TimeDiff)
Calculate the time difference of satellite signal arrival among stations, and iits associated error.
Inputs: Station locations (lat, long)
	Clock sync error
	Alignment error
	Ground position of each station
	Satellite position
	Absolute time of when signal was transmitted
Outputs: Time differences among stations and center of the earth
	 Absolute time of signal arrival at center of the earth?
	 Error of time difference among stations

3. Determine Satellite Location (LocateSat)
This will use the output of Program 2 to determine the satellite's location and its error.
Inputs: The ouputs of Calculate Time Difference
Outputs: Satellite location at the time it transmitted
	 Error of satellite location calculation

Important Notes:
11/12 Its very important which zPlanes we pick. Low zPlanes introduce error for high elevation cases. 0.007 deg -> 0.09 deg
High zPlanes introduce significant error for low elevation cases. 0.32 deg -> 1.8 deg
11/12 It appears as the planes approach infinity, we get better results.

11/13 The intersection of 2 hyperboloids is a hyperbola. If we can find the equation of that hyperbola, we can approximate the line with the hyperbola's asympotote.
Okay. Well fitting a hyperbola to a cloud of points is difficult because it requires a parametric variable, t, which is unknown before solving for the hyperbola.

Choices moving forward:
1) figure out how to vary the parametric value variables as well so the parametric fit converges
2) Consider intersecting 2 Hyperboloids together. The result should be 4 solutions, each a quarter of a hyperbola. If we can translate the symbolic toolbox
output to a hyperbola of the form x^2/a+y^2/b we can get the asymptote line. 

Upcoming Features:
11/11 Add time difference error functionality to one-sided vs. two-sided Hyperbola. If the time difference could be negative, plot the mirror image of that specific hyperbola.
11/11 Decide how to bound the solution. Currently take the 3 closest points -- most of the time. Doesn't always work. 
Test case:
TDoA2Dtest last test commented out TimeDiffs. 

