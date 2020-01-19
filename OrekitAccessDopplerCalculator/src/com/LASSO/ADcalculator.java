package com.LASSO;

import org.hipparchus.analysis.function.Abs;
import org.hipparchus.geometry.euclidean.threed.Vector3D;
import org.orekit.attitudes.NadirPointing;
import org.orekit.bodies.GeodeticPoint;
import org.orekit.frames.Frame;
import org.orekit.frames.FramesFactory;
import org.orekit.frames.TopocentricFrame;
import org.orekit.propagation.SpacecraftState;
import org.orekit.propagation.analytical.tle.SGP4;
import org.orekit.propagation.analytical.tle.TLE;
import org.orekit.propagation.events.BooleanDetector;
import org.orekit.propagation.events.ElevationDetector;
import org.orekit.propagation.events.EventDetector;
import org.orekit.propagation.events.EventsLogger;
import org.orekit.propagation.events.handlers.RecordAndContinue;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;
import org.orekit.utils.PVCoordinates;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

public class ADcalculator {

    /**5 digit code assigned to the satellite to track */
    private int noradID;

    /**time step to use when recording points during satellite access*/
    private double timeInterval;

    private TLE satelliteOrbit;

    private ArrayList<Station> stations;

    /** custom event detector used to determine when 3 stations have access to the satellite.*/
    private BooleanDetector threeStationDetector;

    public ADcalculator(int noradID, double timeInterval, ArrayList<Station> stations){
        this.noradID=noradID;
        this.timeInterval=timeInterval;
        this.stations=stations;

        try {
            satelliteOrbit=CelestrakImporter.importSatelliteData(noradID);
        } catch (IOException e) {
            System.out.println("Fail to find Satellite");
        }
    }

    public ArrayList<AbsoluteDate> computeAccessTimes(AbsoluteDate endDate, boolean verbose){

        Frame inertialFrame = FramesFactory.getEME2000();
        TimeScale utc = TimeScalesFactory.getUTC();

        //set initial date as October 30th, 2019 at 0:00
        AbsoluteDate initialDate = new AbsoluteDate(2019, 10, 30, 0, 0, 00.000, utc);

        //TODO How can we better quanitify these? Does it matter?
        double mass=100; // 54 kg is FalconSat3. 100kg assumption?
        NadirPointing nadirPointing = new NadirPointing(inertialFrame, stations.get(0).getEarth());


        SGP4 oreTLEPropagator=new SGP4(satelliteOrbit,nadirPointing,mass);

        // EVENT DETECTION USING ELEVATION DETECTORS//
        double maxCheck  = 60.0;  //"maximum checking interval"
        double threshold =  0.001; //convergence threshold value
        double minElevation = 0;     //min elevation (trigger elevation)
        createBooleanDetector(maxCheck,threshold,minElevation);

        EventsLogger booleanLogger=new EventsLogger(); //creating logger to get data from detector
        oreTLEPropagator.addEventDetector(booleanLogger.monitorDetector(threeStationDetector));  //add event detector to propagator

        //Propagation
        SpacecraftState initialState= oreTLEPropagator.getInitialState();
        oreTLEPropagator.propagate(initialDate, endDate);
        List<EventsLogger.LoggedEvent> stationOverlap=booleanLogger.getLoggedEvents(); //getting event instances.
        if(verbose) {
            System.out.println(stationOverlap.get(0).getState().getDate().toString());
            System.out.println(initialDate.toString());
        }

        //For each event, propagate from the start to the end of the access with the specified interval time step.
        for (int entryIndex=0;entryIndex<stationOverlap.size()-1;entryIndex=entryIndex+2) {
            if(verbose) {
                System.out.println("Event" +entryIndex);
            }

            AbsoluteDate propagateTime=stationOverlap.get(entryIndex).getState().getDate(); //setting initial time for propagation.
            AbsoluteDate endTime=stationOverlap.get(entryIndex+1).getState().getDate();

            while (propagateTime.compareTo(endTime)<=0) {
                PVCoordinates pvInert   = oreTLEPropagator.getPVCoordinates(propagateTime);
                //TODO Insert Doppler Shift calculations here.
//                Vector3D positionVectorSatellite=pvInert.getPosition();   //3D vector of satellite in earth EME2000 frame.
//                String currentTimeStamp=propagateTime.getDate().toString();


                propagateTime = propagateTime.shiftedBy(timeInterval); //getting info every x seconds.
            } //end of propagation while loop

        } //end of for loop for each station

        //Write to file
        try {
            PrintWriter unWriter= new PrintWriter("./DopplerAccess"+noradID+".txt", "UTF_8");
            unWriter.printf("%d \n", tleLines.length);
            unWriter.printf("%s\t%s\t%s\t%s\n","Latitude","Longitude","Altitude","Station");
            for (int s=0;s<tleLines.length;s++) {
                //System.out.format("%s %n",maxElevationArray.get(s).toString().replaceAll("[,\\[\\]]",""));

                unWriter.printf("%s %n", maxElevationArray.get(s).toString().replaceAll("[,\\[\\]]",""));

                System.out.format("%s %n",maxElevationArray.get(s).toString().replaceAll("[,\\[\\]]",""));
                //System.out.println(maxElevationArray);
            }
            unWriter.close();
        } catch (FileNotFoundException e) {
            System.out.println("Could not find specified file");
        } catch (UnsupportedEncodingException e) {
            System.out.println("Specified encoding not supposted.");
        }

         return null;
        }


    /**
     * Creates a boolean event detector. Propagation triggers the detector when the specified satellite is in view of
     * all stations at the same time.
     * @param maxCheck Used to decide how often to check the event detector during propagation.
     * @param threshold The approximate accuracy of the event detector. WARNING: there is still inherent error in the
     *                  propagator itself.
     * @param minElevation Use this if below a certain elevation, the stations cannot detect the object.
     *                     //TODO consider changing minElevation to an ArrayList since each site may have a different min Elevation.
     * @return a booleanDetector to use for propagation.
     */
    public void createBooleanDetector(double maxCheck, double threshold, double minElevation) {

        ArrayList<EventDetector> stationVisibilityDetectors=new ArrayList<>();
        for (int i=0; i<stations.size();i++) {

            stationVisibilityDetectors.add(new ElevationDetector(maxCheck,threshold,stations.get(i).getFrame()).
                    withConstantElevation(minElevation).
                    withHandler(new RecordAndContinue()));
        }

        threeStationDetector=BooleanDetector.andCombine(stationVisibilityDetectors);
    }






}
