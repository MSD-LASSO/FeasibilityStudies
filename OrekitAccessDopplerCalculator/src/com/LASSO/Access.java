package com.LASSO;

import org.orekit.propagation.analytical.tle.SGP4;
import org.orekit.propagation.events.EventsLogger;
import org.orekit.time.AbsoluteDate;
import org.orekit.utils.PVCoordinates;

import java.util.ArrayList;

/**
 * This class serves as a container for everything related to a single satellite access.
 */
public class Access {

    private ArrayList<TimeFrequencyPair> timesAndFrequency=new ArrayList<>();

    private int noradID;

    private EventsLogger.LoggedEvent begin;
    private EventsLogger.LoggedEvent end;
    private SGP4 oreTLEPropagator;
    private double baseFrequency;
    private double dopplerVelocity;

    /**
     *
     * @param noradID name of satellite that is associated with this access
     * @param begin estimated time the satellite will first be in view of the network
     * @param end last time the satellite will be in view of the network
     * @param oreTLEPropagator the propagator associated with the TLE of this satellite.
     */
    public Access(int noradID,EventsLogger.LoggedEvent begin, EventsLogger.LoggedEvent end, SGP4 oreTLEPropagator, double baseFrequency) {
        this.noradID = noradID;
        this.begin = begin;
        this.end = end;
        this.oreTLEPropagator=oreTLEPropagator;
        this.baseFrequency=baseFrequency;
    }

    public ArrayList<TimeFrequencyPair> getTimesAndFrequency() {
        return timesAndFrequency;
    }

    public int getNoradID() {
        return noradID;
    }

    public EventsLogger.LoggedEvent getBegin() {
        return begin;
    }

    public EventsLogger.LoggedEvent getEnd() {
        return end;
    }

    public SGP4 getOreTLEPropagator() {
        return oreTLEPropagator;
    }

    /**
     *
     * @param backupTime amount of time (in sec) before and after a pass to record during also. Recommended ~5min.
     * @return list of all times to record and the frequency range to record at.
     */
    public ArrayList<TimeFrequencyPair> computeAccessCalculations(double backupTime, double timeInterval,org.orekit.frames.TopocentricFrame staF,
                                                                  org.orekit.frames.Frame theInertialFrame){
        AbsoluteDate propagateTime= begin.getState().getDate(); //setting initial time for propagation.
        AbsoluteDate endTime=end.getState().getDate();

        propagateTime.shiftedBy(-backupTime);


        while (propagateTime.compareTo(endTime.shiftedBy(backupTime))<=0) {

            PVCoordinates pvInert = oreTLEPropagator.getPVCoordinates(propagateTime);
//             Vector3D positionVectorSatellite=pvInert.getPosition();   //3D vector of satellite in earth EME2000 frame.
//             String currentTimeStamp=propagateTime.getDate().toString();
            PVCoordinates pvStation = theInertialFrame.getTransformTo(staF, propagateTime).transformPVCoordinates(pvInert);
            //CALCULATING DOPPLER EFFECT (from orekit example online)
            dopplerVelocity = org.hipparchus.geometry.euclidean.threed.Vector3D.dotProduct(pvStation.getPosition(), pvStation.getVelocity()) / pvStation.getPosition().getNorm();
            //System.out.println(doppler);

            //insert whatever needed parameters into frequencyCalc.
            TimeFrequencyPair omega=new TimeFrequencyPair(propagateTime,frequencyCalc(baseFrequency,dopplerVelocity));

            timesAndFrequency.add(omega);
            propagateTime = propagateTime.shiftedBy(timeInterval); //getting info every x seconds.
        }

        return timesAndFrequency;
    }


    public ValueRange frequencyCalc(double baseFrequency, double dopplerVelocity){
        //TODO implement frequencyCalc method. Method should return the nominal frequency and estimate the lower and upper bound.
        double c=org.orekit.utils.Constants.SPEED_OF_LIGHT;

        //shifted frequency from Doppler effect. Altered by a factor of (c+ v_receiver) / (c+v_satellite)

        double shiftedFreq= (c/(c+dopplerVelocity))*baseFrequency;
        System.out.println(shiftedFreq);
        return new ValueRange(437,436,438);
    }

    public String toString(){
        StringBuilder output= new StringBuilder();
        for(int i=0;i<timesAndFrequency.size();i++){
            output.append(timesAndFrequency.get(i).toString()).append("\n");
        }
        return output.toString();
    }




}
