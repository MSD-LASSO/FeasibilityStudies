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
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class ADcalculator {

    /**5 digit code assigned to the satellite to track */
    private int noradID;

    /**time step to use when recording points during satellite access*/
    private double timeInterval;

    private TLE satelliteOrbit;

    private ArrayList<Station> stations;

    private StringBuilder writeToText= new StringBuilder();

    /** custom event detector used to determine when 3 stations have access to the satellite.*/
    private BooleanDetector threeStationDetector;

    /**This is the frequency the satellite transmits at, NOT the frequency the receiver will get.*/
    private double baseFrequency;

    public ADcalculator(int noradID, double timeInterval, ArrayList<Station> stations, double baseFrequency){
        this.noradID=noradID;
        this.timeInterval=timeInterval;
        this.stations=stations;
        this.baseFrequency=baseFrequency;

        try {
            satelliteOrbit=CelestrakImporter.importSatelliteData(noradID);
        } catch (IOException e) {
            System.out.println("Fail to find Satellite");
        }
    }

    public ArrayList<Access> computeAccessTimes(AbsoluteDate endDate, boolean verbose){

        Frame inertialFrame = FramesFactory.getEME2000();
        TimeScale utc = TimeScalesFactory.getUTC();

        //set initial date as October 30th, 2019 at 0:00
//        AbsoluteDate initialDate = new AbsoluteDate(2019, 10, 30, 0, 0, 00.000, utc);
        Date today= Calendar.getInstance().getTime();
        //TODO convert this to an Absolute Date.
        AbsoluteDate initialDate=new AbsoluteDate(2020,1,22,16,0,00.000,utc);

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
        oreTLEPropagator.propagate(initialDate, endDate);
        List<EventsLogger.LoggedEvent> stationOverlap=booleanLogger.getLoggedEvents(); //getting event instances.
        if(verbose) {
            System.out.println(stationOverlap.get(0).getState().getDate().toString());
            System.out.println(initialDate.toString());
        }

        //Getting station frame for doppler calcs.
        int stationFrameNo=2;
        TopocentricFrame stationFrameForDoppler=stations.get(stationFrameNo).getFrame();

        ArrayList<Access> accesses=new ArrayList<>();
        //For each event, propagate from the start to the end of the access with the specified interval time step.
        for (int entryIndex=0;entryIndex<stationOverlap.size()-1;entryIndex=entryIndex+2) {
            writeToText.append("Access Number: ").append(entryIndex / 2).append("\n");
            if(verbose) {
                System.out.println("Event" +entryIndex);
            }
            Access accessPoint=new Access(noradID,stationOverlap.get(entryIndex),stationOverlap.get(entryIndex+1),oreTLEPropagator,baseFrequency);
            accessPoint.computeAccessCalculations(300,timeInterval,stationFrameForDoppler,inertialFrame);
            writeToText.append(accessPoint.toString());
            accesses.add(accessPoint);

        } //end of for loop for each station
        writeToFile();

         return accesses;
        }


    /**
     * Creates a boolean event detector. Propagation triggers the detector when the specified satellite is in view of
     * all stations at the same time.
     * @param maxCheck Used to decide how often to check the event detector during propagation.
     * @param threshold The approximate accuracy of the event detector. WARNING: there is still inherent error in the
     *                  propagator itself.
     * @param minElevation Use this if below a certain elevation, the stations cannot detect the object.
     *                     //TODO consider changing minElevation to an ArrayList since each site may have a different min Elevation. The station object already has minElevation as an option.
     * @return a booleanDetector to use for propagation.
     */
    public void createBooleanDetector(double maxCheck, double threshold, double minElevation) {

        ArrayList<EventDetector> stationVisibilityDetectors=new ArrayList<>();
        for (Station station : stations) {

            stationVisibilityDetectors.add(new ElevationDetector(maxCheck, threshold, station.getFrame()).
                    withConstantElevation(minElevation));
        }

        threeStationDetector=BooleanDetector.andCombine(stationVisibilityDetectors).withHandler(new RecordAndContinue<>());
    }

    public void writeToFile(){
        try {
            PrintWriter unWriter= new PrintWriter("./DopplerAccess"+noradID+".txt", StandardCharsets.UTF_8);
            unWriter.print(writeToText);
            unWriter.close();
        } catch (FileNotFoundException e) {
            System.out.println("Could not find specified file");
            System.out.println(e.getMessage());
        } catch (UnsupportedEncodingException e) {
            System.out.println("Specified encoding not supported.");
            System.out.println(e.getMessage());
        } catch (IOException e) {
            System.out.println("Wrong Input");
            System.out.println(e.getMessage());
        }
    }






}
