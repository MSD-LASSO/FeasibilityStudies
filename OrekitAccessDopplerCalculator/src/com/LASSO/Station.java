package com.LASSO;

import org.orekit.bodies.BodyShape;
import org.orekit.bodies.GeodeticPoint;
import org.orekit.bodies.OneAxisEllipsoid;
import org.orekit.frames.Frame;
import org.orekit.frames.FramesFactory;
import org.orekit.frames.TopocentricFrame;
import org.orekit.utils.Constants;
import org.orekit.utils.IERSConventions;

import java.util.Random;

public class Station {



    /** Describes the minimum elevation this station can record data at */
    private double minElevation;

    /** Defines the estimated error in the station clock. This uncertainty says the station clock +/- this uncertainty
     * contains the actual clock time 95% of the time. Assumes a normal distribution.*/
    private double clockSyncError;

    /** Describes location of station*/
    private GeodeticPoint coordinates;

    /** Model for the Earth.*/
    private BodyShape earth;

    /** Latitude, Longitude, altitude. Lat Long is in radians, altitude in meters*/
    private double[] location;
    private double[] locationError;

    /** Describes the coordinate system centered at this station.*/
    private TopocentricFrame frame;

    /** Use a WGS84 model of the Earth.*/
    public Station(String name, double[] location, double[] locationError, double minElevation, double clockSyncError){
        this(name,location,locationError,minElevation,clockSyncError,getDefaultEarth());
    }

    /**
     * Create a station container.
     * @param name of the station
     * @param location of the station in latitude, longtitude (radians), and altitude (m)
     * @param locationError of the station in same units as Location
     * @param minElevation Below this elevation, the station cannot detect a satellite.
     * @param clockSyncError Error in the clock of the station.
     * @param earth model of the Earth
     */
    public Station(String name, double[] location, double[] locationError, double minElevation, double clockSyncError, BodyShape earth){
        this.location=location;
        this.locationError=locationError;
        this.earth=earth;
        this.minElevation=minElevation;
        this.clockSyncError=clockSyncError;
        coordinates=new GeodeticPoint(location[0],location[1],location[2]);
        frame=new TopocentricFrame(earth,coordinates,name);
    }

    public double getMinElevation() {
        return minElevation;
    }

    public double getClockSyncError() {
        return clockSyncError;
    }

    public GeodeticPoint getCoordinates() {
        return coordinates;
    }

    public BodyShape getEarth() {
        return earth;
    }

    public double[] getLocation() {
        return location;
    }

    public double[] getLocationError() {
        return locationError;
    }

    public TopocentricFrame getFrame() {
        return frame;
    }

    public static BodyShape getDefaultEarth(){
        Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2010, true);
        ///*
        return new OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                Constants.WGS84_EARTH_FLATTENING,
                earthFrame);
    }

    public TopocentricFrame getFrameInDistribution() {
        //TODO to be implemented.
        //randomly perturbate the geodetic point by its error. Return the topocentric frame at this new point.
        System.out.println("Needs to be implemented");
        return null;
    }

}
