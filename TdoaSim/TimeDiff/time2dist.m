function [distance, distance_error] = time2dist(time, time_error)

c = 299792458;

min = time-time_error;
max = time+time_error;
distance = time*c;
max_distance = max*c;
min_distance = min*c;
distance_error = abs(max_distance-min_distance)/2;

