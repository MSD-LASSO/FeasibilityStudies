package com.LASSO;

import java.net.Socket;
import java.io.*;
import java.nio.ByteBuffer;
import java.net.*;
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
import java.time.Instant;

/** This class calculates the access times and the doppler shift during those access times for a given satellite noradID
 * file and station lcoations.
 * */
public class ADcalculator {

    /**5 digit code assigned to the satellite to track */
    private int noradID;

    /**time step to use when recording points during satellite access*/
    private double timeInterval;

    /** the time to shift back and forth for doppler upper and lower bound */
    private double dopplerErrorTime;
    private TLE satelliteOrbit;

    private ArrayList<Station> stations;

    private StringBuilder writeToText= new StringBuilder();

    /** custom event detector used to determine when 3 stations have access to the satellite.*/
    private BooleanDetector threeStationDetector;

    /**This is the frequency the satellite transmits at, NOT the frequency the receiver will get.*/
    private double baseFrequency;

    public ADcalculator(int noradID, double timeInterval, ArrayList<Station> stations, double baseFrequency,double dopplerErrorTime){
        this.noradID=noradID;
        this.timeInterval=timeInterval;
        this.stations=stations;
        this.baseFrequency=baseFrequency;
        this.dopplerErrorTime=dopplerErrorTime;
        try {
            satelliteOrbit=CelestrakImporter.importSatelliteData(noradID);
        } catch (IOException e) {
            throw new NoradIDnotFoundException("ERROR 002: The NORAD ID was not found!!!!!!!! Please check the input file!!!!!!!!!");
        }
    }

    public void setSatelliteOrbit(TLE satelliteOrbit) {
        this.satelliteOrbit = satelliteOrbit;
    }

    /**
     * Calculates all access times within the specified interval and outputs them to a text file with the name
     * DopplerAndAccessXXXXX where XXXXX is the noradID.
     * @param initialDate date to start looking for access times
     * @param endDate date to stop looking for access times
     * @param verbose set to true to get intermediate details. False to get no command outputs
     * @return an arrayList of size equal to the number of independent access times.
     */
    public ArrayList<Access> computeAccessTimes(AbsoluteDate initialDate, AbsoluteDate endDate, boolean verbose){


        Frame inertialFrame = FramesFactory.getEME2000();


        System.out.println("Start Date: "+initialDate.toString());
        System.out.println(initialDate.compareTo(endDate));
        if (initialDate.compareTo(endDate)>0)
        {

            throw new NoEventsFoundException("ERROR 004: END DATE IS BEFORE THE PROGRAM START DATE!!!!! CHECK THE END DATE AGAIN!!!!!!");

        }

        //TODO How can we better quanitify mass and attitude? Does it matter?
        double mass=100; // 54 kg is FalconSat3. 100kg assumption?
        NadirPointing nadirPointing = new NadirPointing(inertialFrame, stations.get(0).getEarth());


        SGP4 oreTLEPropagator=new SGP4(satelliteOrbit,nadirPointing,mass);

        // EVENT DETECTION USING ELEVATION DETECTORS//
        double maxCheck  = 60.0;  //"maximum checking interval"
        double threshold =  0.001; //convergence threshold value
        double minElevation = 0;     //min elevation (trigger elevation)
        createBooleanDetector(maxCheck,threshold,minElevation);

        //Create logger to buffer each event.
        EventsLogger booleanLogger=new EventsLogger();
        //add event detector to propagator
        oreTLEPropagator.addEventDetector(booleanLogger.monitorDetector(threeStationDetector));

        //Propagation
        oreTLEPropagator.propagate(initialDate, endDate);
        //Parse events
        List<EventsLogger.LoggedEvent> stationOverlap=booleanLogger.getLoggedEvents(); //getting event instances.
        if(verbose) {
            System.out.println(stationOverlap.get(0).getState().getDate().toString());
            System.out.println(initialDate.toString());
        }

        if (stationOverlap.size()<=1)
        {
            throw new NoEventsFoundException("ERROR 003: NO EVENTS BETWEEN PROGRAM START DATE AND INPUTTED END DATE!!!!!!!! CHECK END DATE!!!!!!!!!");
        }

        //CHECKING IF THE START OR END DATE WAS IN THE MIDDLE OF A PASS (this will screw up the outputted frequencies)

        if (! stationOverlap.get(0).isIncreasing()){  //if the 1st event returns false, it means that the event is an exit.
            stationOverlap.remove(0);          //You ran the program as the satellite was passing overhead.
        }                                            // simply remove this pass and start from next one to keep program working.
        if ( stationOverlap.get(stationOverlap.size()-1).isIncreasing() ){ //if the last event returns true, then it is an entry.
            stationOverlap.remove(stationOverlap.size()-1);         //You have an end date in the middle of a pass.
        }                                                                 // Remove this last pass to keep program working.

        if (stationOverlap.size()<=1)
        {
            throw new NoEventsFoundException("ERROR 003: NO EVENTS BETWEEN PROGRAM START DATE AND INPUTTED END DATE!!!!!!!! CHECK END DATE!!!!!!!!!");
        }



        //*/
        //Getting station frame array for doppler calcs.
        TopocentricFrame[] stationFramesForDoppler=new TopocentricFrame[stations.size()];

        for (int i=0;i<stations.size();i++){
            stationFramesForDoppler[i]=stations.get(i).getFrame();
        }

        //OUTPUT Text File Header/ Formatting/////////////////////////////////////////////////
        //TopocentricFrame stationFrameForDoppler=stations.get(stationFrameNo).getFrame();
        // crafting header string
        writeToText.append("numStations="+stations.size()+"\n");
        StringBuilder headerString=new StringBuilder();
        for (int b=0; b<stations.size();b++) {
            headerString = headerString.append(String.format("Sta # %d Nom         Lower           Upper       ", b));
        }

        //Station Name Identifiers for the top of the output text
        for (int p=0; p<stations.size();p++){
            writeToText.append(stations.get(p).getFrame().getName()).append("\n");
        }

        ArrayList<Access> accesses=new ArrayList<>();
        //For each event, propagate from the start to the end of the access with the specified interval time step.
        writeToText.append("numEvents="+stationOverlap.size()/2+"\n");
        for (int entryIndex=0;entryIndex<stationOverlap.size()-1;entryIndex=entryIndex+2) {

            writeToText.append("Access Number: ").append(entryIndex / 2).append("            "+headerString).append("\n");
            if(verbose) {
                System.out.println("Event" +entryIndex);
            }
            Access accessPoint=new Access(noradID,stationOverlap.get(entryIndex),stationOverlap.get(entryIndex+1),oreTLEPropagator,baseFrequency);
            System.out.println(stationOverlap.get(entryIndex).isIncreasing());
            System.out.println(stationOverlap.get(entryIndex+1).isIncreasing());

            accessPoint.computeAccessCalculations(300,timeInterval,stationFramesForDoppler,inertialFrame,dopplerErrorTime);
            writeToText.append(accessPoint.toStringStationList());
//            int stationFrameNo=2;
            //writeToText.append(accessPoint.toString(stationFrameNo));  //debugging line to check each station output individually.


            accesses.add(accessPoint);

        } //end of for loop for each station
        writeToFile();
        //TCPsend();

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

    /**
     * Write the string output to a text file with the name DopplerAccessXXXXX.txt with XXXXXX as the noradID.
     * */
    public void writeToFile(){
        try {
            PrintWriter unWriter= new PrintWriter("./DopplerAccess"+noradID+".txt", StandardCharsets.UTF_8);
            unWriter.print(writeToText);
            unWriter.close();
        } catch (FileNotFoundException e) {
            System.out.println("ERROR 010: Could not find specified file. Writing Failed.");
            System.out.println(e.getMessage());
        } catch (UnsupportedEncodingException e) {
            System.out.println("ERROR 011: Specified encoding not supported. Writing Failed.");
            System.out.println(e.getMessage());
        } catch (IOException e) {
            System.out.println("ERROR 012: Wrong Input. Writing Failed.");
            System.out.println(e.getMessage());
        }
    }


    public void TCPsend(){
        int intSize = 4;

        int Port = 5010;
        String IpAddress = "129.21.145.85";

        byte[] send = {'H', 'e', 'l', 'l', 'o', ',', ' ', 's', 'e', 'r', 'v', 'e', 'r'};
        int send_size_int = send.length;
        byte[] send_size_bytes;
        byte[] recv = new byte[256];

        try (Socket socket = new Socket(IpAddress, Port)) {

            OutputStream output = socket.getOutputStream();
            PrintWriter writer= new PrintWriter(output, true);
            send_size_bytes = ByteBuffer.allocate(intSize).putInt(writeToText.length()).array();
            output.write(send_size_bytes);
            output.flush();  //finish sending stuff

            writer.println(writeToText);
            writer.flush();
            socket.close();

        } catch (UnknownHostException ex) {

            System.out.println("Server not found: " + ex.getMessage());

        } catch (IOException ex) {

            System.out.println("I/O error: " + ex.getMessage());
        }
    }

}







