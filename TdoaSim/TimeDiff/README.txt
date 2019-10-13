This program will have 4 functions.

1) Sets absolute time & calls other functions, then return results.
This will call functions 2, 3, and 4.

2) Convert ground station coordinates to global/polar coordinates
input: a single point of lat, long, and elevation
       error of the measurement
output: x, y, z or 3D polar coordinates
	error in x,y,z or 3D polar coordinate form

3) Find the parameters of the triangle
input: coordiantes for 3 points (sat, center of earth, and station)
       error for 3 points
output: lengths of 3 sides of triangle
	error for 3 lengths

4) Find the time difference
input: 2 lengths (e.g. sat to stationA, sat to stationB)
       error of 2 lengths
       clock sync error
       alignment error
output: time difference between the two stations
	error of time difference between two sation
