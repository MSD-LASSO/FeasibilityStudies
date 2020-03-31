package com.LASSO;

import org.orekit.propagation.analytical.tle.SGP4;
import org.orekit.propagation.events.EventsLogger;
import org.orekit.time.AbsoluteDate;
import org.orekit.utils.PVCoordinates;
import org.hipparchus.geometry.euclidean.threed.Vector3D;

import java.util.ArrayList;
import java.util.List;

/**
 * This class serves as a container for everything related to a single satellite access.
 */
public class Access {

    private ArrayList<TimeFrequencyPair> timesAndFrequency=new ArrayList<>();
    private List<List<TimeFrequencyPair>> timesAndFrequencyStationList=new ArrayList<List<TimeFrequencyPair>>();

    private ArrayList<ArrayList<Double>> elevationStationList=new ArrayList<>();
    private ArrayList<ArrayList<Double>> azimuthStationList=new ArrayList<>();
    private ArrayList<ArrayList<Double>> rangeStationList=new ArrayList<>();

    private int noradID;

    private EventsLogger.LoggedEvent begin;
    private EventsLogger.LoggedEvent end;
    private SGP4 oreTLEPropagator;
    private double baseFrequency;

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
    public ArrayList<TimeFrequencyPair> computeAccessCalculations(double backupTime, double timeInterval,org.orekit.frames.TopocentricFrame[] staF,
                                                                  org.orekit.frames.Frame theInertialFrame, double dopplerErrorTime){
        AbsoluteDate startTime=begin.getState().getDate();
        AbsoluteDate propagateTime= begin.getState().getDate(); //setting initial time for propagation.
        AbsoluteDate endTime=end.getState().getDate();

        propagateTime=propagateTime.shiftedBy(-backupTime);
        //System.out.println(propagateTime.toString());
        // Setting up 2D TimeFrequencyPair arraylist private var based on the number of stations (imported from staF parameter)
        //simple loop to add X number of lists, based on X number of stations
        for (int a=0; a<staF.length;a++) {
            timesAndFrequencyStationList.add(new ArrayList<TimeFrequencyPair>());
            elevationStationList.add(new ArrayList<Double>());
            azimuthStationList.add(new ArrayList<Double>());
            rangeStationList.add(new ArrayList<Double>());
        }

        //ArrayList<Double> dopplerVelocities=new ArrayList<Double>();
        //ArrayList<Double> dopplerVelocitiesBehind=new ArrayList<Double>();
        //ArrayList<Double> dopplerVelocitiesAhead=new ArrayList<Double>();

        while (propagateTime.compareTo(endTime.shiftedBy(backupTime))<=0) {

            //propagation loop to get the time frequency Doppler shift values with respect to each station
            for (int i=0; i<staF.length; i++) {
                PVCoordinates pvInert = oreTLEPropagator.getPVCoordinates(propagateTime);
                PVCoordinates pvStation = theInertialFrame.getTransformTo(staF[i], propagateTime).transformPVCoordinates(pvInert);

                Vector3D positionVectorSatellite=pvInert.getPosition();   //3D vector of satellite in earth EME2000 frame.;
                // Get the azimuth, elevation, and range from the .get functions.
                // in reference to station Reference#. Position vector is in the inertial earth frame.
                double azimuth=staF[i].getAzimuth(positionVectorSatellite, theInertialFrame,propagateTime );
                double elevation=staF[i].getElevation(positionVectorSatellite, theInertialFrame, propagateTime);
                double range=staF[i].getRange(positionVectorSatellite, theInertialFrame, propagateTime);

                AbsoluteDate behindTime = propagateTime.shiftedBy(-dopplerErrorTime);
                PVCoordinates pvInertBehind = oreTLEPropagator.getPVCoordinates((behindTime));
                PVCoordinates pvStationBehind = theInertialFrame.getTransformTo(staF[i], behindTime).transformPVCoordinates(pvInertBehind);

                AbsoluteDate aheadTime = propagateTime.shiftedBy(+dopplerErrorTime);
                PVCoordinates pvInertAhead = oreTLEPropagator.getPVCoordinates((aheadTime));
                PVCoordinates pvStationAhead = theInertialFrame.getTransformTo(staF[i], aheadTime).transformPVCoordinates(pvInertAhead);

                //CALCULATING DOPPLER EFFECT (from orekit example online)
                double dopplerVelocity = Vector3D.dotProduct(pvStation.getPosition(), pvStation.getVelocity()) / pvStation.getPosition().getNorm();

                double dopplerVelocityBehind = Vector3D.dotProduct(pvStationBehind.getPosition(), pvStationBehind.getVelocity()) / pvStationBehind.getPosition().getNorm();

                double dopplerVelocityAhead = Vector3D.dotProduct(pvStationAhead.getPosition(), pvStationAhead.getVelocity()) / pvStationAhead.getPosition().getNorm();

                //System.out.println(doppler);

                //insert whatever needed parameters into frequencyCalc.
                TimeFrequencyPair omega = new TimeFrequencyPair(propagateTime, frequencyCalc(baseFrequency, dopplerVelocity, dopplerVelocityAhead, dopplerVelocityBehind));
                omega.calcRelativeTime(startTime);
                timesAndFrequencyStationList.get(i).add(omega);

                elevationStationList.get(i).add(elevation*180/Math.PI);
                azimuthStationList.get(i).add(azimuth*180/Math.PI);
                rangeStationList.get(i).add(range);
                timesAndFrequency.add(omega); //not used

            }
            propagateTime = propagateTime.shiftedBy(timeInterval); //getting info every x seconds.

        }
        getEndPointValues(staF, theInertialFrame,dopplerErrorTime,backupTime);  //a final call of the above loop, just to get data for the end of pass time

        return timesAndFrequency;
    }


    public ValueRange frequencyCalc(double baseFrequency, double dopplerVelocity,double dopplerVAhead,double dopplerVBehind){
        //TODO implement frequencyCalc method. Method should return the nominal frequency and estimate the lower and upper bound.
        double c=org.orekit.utils.Constants.SPEED_OF_LIGHT;

        //shifted frequency from Doppler effect. Altered by a factor of (c+ v_receiver) / (c+v_satellite)
        double shiftedFreqNom= (c/(c+dopplerVelocity))*baseFrequency;
        double shiftedFreqAhead=(c/(c+dopplerVAhead))*baseFrequency;
        double shiftedFreqBehind=(c/(c+dopplerVBehind))*baseFrequency;

        double upperBound=0;
        double lowerBound=0;

        if (shiftedFreqAhead>shiftedFreqBehind) {
            upperBound = shiftedFreqAhead;
            lowerBound = shiftedFreqBehind;
        }
        else {
            lowerBound=shiftedFreqAhead;
            upperBound=shiftedFreqBehind;
            }
        return new ValueRange(shiftedFreqNom,lowerBound,upperBound);
    }


    public String toString(int stationNo){
        StringBuilder output= new StringBuilder();
        for(int i=stationNo;i<timesAndFrequency.size();i=i+timesAndFrequencyStationList.size()){
            output.append(timesAndFrequency.get(i).toString()).append("\n");
        }
        return output.toString();
    }

    // method to craft string for each station Doppler Frequency bounds on a single line
    public String toStringStationList(){

        StringBuilder output= new StringBuilder();
        for(int i=0;i<timesAndFrequencyStationList.get(0).size();i++){  //i is counter for each time interval of propagation

            for (int a=0;a<timesAndFrequencyStationList.size();a++) {  // a is counter for the dif stations

                // this code is printing out frequencies. Should be used in Orekit output file.

                if (a==0) {
                    output.append(timesAndFrequencyStationList.get(a).get(i).toString());
                }
                else{
                    output.append(timesAndFrequencyStationList.get(a).get(i).toStringWithoutDate());
                }
            }

            output.append("\n");
        }
        return output.toString();
    }
    //string builder for printing el and az to the az el output text file.
    public String toStringStationListElAz(){

        StringBuilder output= new StringBuilder();
        for(int i=0;i<timesAndFrequencyStationList.get(0).size();i++){  //i is counter for each time interval of propagation

            for (int a=0;a<timesAndFrequencyStationList.size();a++) {  // a is counter for the dif stations

                // This code is for elevation testing amidst COVID-19 quarantine. Used in El Az debug text file.
                /////////////////////////////////////////////////////////////////////////////////////////////////////////
                if (a==timesAndFrequencyStationList.size()-1)
                {
                    output.append(timesAndFrequencyStationList.get(a).get(i).getDate().toString()+" , ");
                    double elapsedTime=timesAndFrequencyStationList.get(a).get(i).getDate().durationFrom(begin.getState().getDate()); //elapsed time from start
                    output.append(String.format("%7.2f ",elapsedTime));
                    //output.append("\n");
                    for (int f=0;f<elevationStationList.size();f++) {
                        output.append(String.format(",           %6.3f, %.3f, %6.15f      ",elevationStationList.get(f).get(i),azimuthStationList.get(f).get(i),rangeStationList.get(f).get(i)));

                    }
                }
                /////////////////////////////////////////////////////////////////////////////////////////////////////////

            }
            //output.append("\n");


            //output.append("\n");

            //output.append("elevations list size: "+ String.valueOf(elevationStationList.size()));
            output.append("\n");
        }
        return output.toString();
    }

    public void getEndPointValues(org.orekit.frames.TopocentricFrame[] staF,
                                  org.orekit.frames.Frame theInertialFrame, double dopplerErrorTime, double backupTime){
        AbsoluteDate startTime=begin.getState().getDate();
        AbsoluteDate endTime=end.getState().getDate();
        endTime=endTime.shiftedBy(backupTime);
        for (int i=0; i<staF.length; i++) {
            PVCoordinates pvInert = oreTLEPropagator.getPVCoordinates(endTime);
            PVCoordinates pvStation = theInertialFrame.getTransformTo(staF[i], endTime).transformPVCoordinates(pvInert);

            Vector3D positionVectorSatellite=pvInert.getPosition();   //3D vector of satellite in earth EME2000 frame.;
            // Get the azimuth, elevation, and range from the .get functions.
            // in reference to station Reference#. Position vector is in the inertial earth frame.
            double azimuth=staF[i].getAzimuth(positionVectorSatellite, theInertialFrame,endTime);
            double elevation=staF[i].getElevation(positionVectorSatellite, theInertialFrame, endTime);
            double range=staF[i].getRange(positionVectorSatellite, theInertialFrame, endTime);

            AbsoluteDate behindTime = endTime.shiftedBy(-dopplerErrorTime);
            PVCoordinates pvInertBehind = oreTLEPropagator.getPVCoordinates((behindTime));
            PVCoordinates pvStationBehind = theInertialFrame.getTransformTo(staF[i], behindTime).transformPVCoordinates(pvInertBehind);

            AbsoluteDate aheadTime = endTime.shiftedBy(+dopplerErrorTime);
            PVCoordinates pvInertAhead = oreTLEPropagator.getPVCoordinates((aheadTime));
            PVCoordinates pvStationAhead = theInertialFrame.getTransformTo(staF[i], aheadTime).transformPVCoordinates(pvInertAhead);

            //CALCULATING DOPPLER EFFECT (from orekit example online)
            double dopplerVelocity = Vector3D.dotProduct(pvStation.getPosition(), pvStation.getVelocity()) / pvStation.getPosition().getNorm();

            double dopplerVelocityBehind = Vector3D.dotProduct(pvStationBehind.getPosition(), pvStationBehind.getVelocity()) / pvStationBehind.getPosition().getNorm();

            double dopplerVelocityAhead = Vector3D.dotProduct(pvStationAhead.getPosition(), pvStationAhead.getVelocity()) / pvStationAhead.getPosition().getNorm();

            //System.out.println(doppler);

            //insert whatever needed parameters into frequencyCalc.
            TimeFrequencyPair omega = new TimeFrequencyPair(endTime, frequencyCalc(baseFrequency, dopplerVelocity,
                    dopplerVelocityAhead, dopplerVelocityBehind));
            omega.calcRelativeTime(startTime);
            timesAndFrequencyStationList.get(i).add(omega);

            elevationStationList.get(i).add(elevation*180/Math.PI);
            azimuthStationList.get(i).add(azimuth*180/Math.PI);
            rangeStationList.get(i).add(range);
            timesAndFrequency.add(omega); //not used //debug placeholder

        }

    }


}
