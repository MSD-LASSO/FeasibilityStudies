package com.LASSO;

import org.orekit.frames.TopocentricFrame;
import org.orekit.propagation.events.BooleanDetector;
import org.orekit.propagation.events.ElevationDetector;
import org.orekit.propagation.events.EventDetector;
import org.orekit.propagation.events.handlers.RecordAndContinue;
import org.orekit.time.AbsoluteDate;

import java.util.ArrayList;

public class ADcalculator {

    /**5 digit code assigned to the satellite to track */
    private int noradID;

    /**time step to use when recording points during satellite access*/
    private double timeInterval;

    /** custom event detector used to determine when 3 stations have access to the satellite.*/
    private BooleanDetector threeStationDetector;

    public ADcalculator(int noradID, double timeInterval){
        this.noradID=noradID;
        this.timeInterval=timeInterval;
    }

    public ArrayList<AbsoluteDate> computeAccessTimes(int numberOfAccess){
        return null;
    }


    /**
     * Creates a boolean event detector. Propagation triggers the detector when the specified satellite is in view of
     * all stations at the same time.
     * @param stationFrames ArrayList of all station saved as TopocentricFrame objects
     * @param maxCheck Used to decide how often to check the event detector during propagation.
     * @param threshold The approximate accuracy of the event detector. WARNING: there is still inherent error in the
     *                  propagator itself.
     * @param minElevation Use this if below a certain elevation, the stations cannot detect the object.
     *                     //TODO consider changing minElevation to an ArrayList since each site may have a different min Elevation.
     * @return a booleanDetector to use for propagation.
     */
    public void createBooleanDetector(ArrayList<TopocentricFrame> stationFrames, double maxCheck,
                                                        double threshold, double minElevation) {

        ArrayList<EventDetector> stationVisibilityDetectors=new ArrayList<>();
        for (int i=0; i<stationFrames.size();i++) {

            stationVisibilityDetectors.add(new ElevationDetector(maxCheck,threshold,stationFrames.get(i)).
                    withConstantElevation(minElevation).
                    withHandler(new RecordAndContinue()));
        }

        threeStationDetector=BooleanDetector.andCombine(stationVisibilityDetectors);
    }






}
