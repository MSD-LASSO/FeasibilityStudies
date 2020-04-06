Run the following in the command line:

AddAllPaths
runtests

This will run all test scripts. These test scripts help show functionality and status of
the algorithm. 

NOTE: fitHyperbolaParametricTest was never completed, thus these tests will fail. 
To save the plots coming out of GroundTrackTest, uncomment GraphSaver. It is recommended you only
uncomment this when running GroundTrackTest on its own. Running it with runtests will have other
figures open as well.

NOTE: Running TDoAwithErrorEstimationTest with a low elevation will result in a test failure
as the estimated error will likely be very off from the absolute error due to a non-normal output
distribution. 