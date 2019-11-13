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

Upcoming Features:
11/11 Add time difference error functionality to one-sided vs. two-sided Hyperbola. If the time difference could be negative, plot the mirror image of that specific hyperbola.
11/11 Decide how to bound the solution. Currently take the 3 closest points -- most of the time. Doesn't always work. 
Test case:
TDoA2Dtest last test commented out TimeDiffs. 

