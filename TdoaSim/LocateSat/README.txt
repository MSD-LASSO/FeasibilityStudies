This Directory contains all functions used to do TDoA. 

wrt --- with respect to

See TDoA and TDoAwithErrorEstimation comments as a starting point for how to use these functions.

computeDirection -- transforms a line fit into azimuth and elevation and a reference point.
ComputeHyperboloid -- creates a hyperboloid in the fixed frame.
CreateHyperboloid -- creates a hyperboloid in the fixed frame symbolically.
fitHyperbolaParametric -- An attempt to fit a hyperbola to a set of points. This is incomplete.
fitLineParametric --  This fits a line to points using linear regression. 
geo2AzEl -- Convert a location to azimuth and elevation wrt to a given reference point. 
getAzEl -- get the Azimuth and elevation given an x,y,z point.
getAzElRotationMatrix -- get the rotation matrix based on azimuth and elevation.
getReceiverSet -- Used to separate a list of 4+ stations into many sets of 3 stations.
getRMandOffsets -- Calculate the rotation and offset needed to go from the body to fixed frame.
Intersect -- Calculate the real, exact solution between symbolic equations.
LeastSquaresLines -- Calculates the closest point of intersection between multiple lines.
LinearRegressionFit -- the linear regression equation. 
moveAzimuthReference -- moves the zero azimuth from 0 to 180 degrees when azimuth is near 0 degrees.
			we do this so averages aren't skewed when errors make azimuths 3,4,357, etc.
PlotLine -- visualize a line fit.
TDoA -- main runner for TDoA without estimating error. Uses symbolic solver or calls TDoAleastSquares
TDoAleastSquares -- called by TDoA
TDoAwithErrorEstimation -- calls TDoA with Monte Carlo error perturbations. 
