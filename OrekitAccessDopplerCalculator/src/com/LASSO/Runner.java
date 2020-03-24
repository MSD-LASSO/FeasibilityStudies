package com.LASSO;

// LASSO 2020
// 3/24/20
// Runner.java stores all the input parameters that the user inputs thru the terminal or the text file.
// MOST IMPORTANT NOTE!!!: The ground station are defined in Runner.java. Type in the latitude, longitude, and elevation
// of each ground station below.
// The minElevations array does not do anything...

import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.time.Instant;
import java.util.ArrayList;

public class Runner {


    private AbsoluteDate initialDate,endDate;

    private int noradID;

    private double errorTimeForTLE;

    private double recordingRate;

    private String fileName;

    private double channelFrequency;

    //initialDate, endDate, noradID, TLEestimatedErrorTime, recordingRate

    public Runner(AbsoluteDate initialDate, AbsoluteDate endDate, int noradID, double errorTimeForTLE, double recordingRate, double channelFrequency){
        this.noradID=noradID;
        this.initialDate=initialDate;
        this.endDate=endDate;
        this.errorTimeForTLE=errorTimeForTLE;
        this.recordingRate=recordingRate;
        this.channelFrequency=channelFrequency;
        Utils.addOrekitData();
    }


    public Runner(String filename){

        this.fileName=filename;
        Utils.addOrekitData();
        try {
            readFromText();
        } catch (IOException e){
            throw new NoradIDnotFoundException("ERROR 009: Failed to read the LASSO Input.txt. Please verify it has all required inputs: noradID, endDate, errorTimeForTLE, recordingRate, channelFrequency");
        }

    }

    public AbsoluteDate getInitialDate() {
        return initialDate;
    }

    public AbsoluteDate getEndDate() {
        return endDate;
    }

    public int getNoradID() {
        return noradID;
    }

    public double getErrorTimeForTLE() {
        return errorTimeForTLE;
    }

    public double getRecordingRate() {
        return recordingRate;
    }

    public String getFileName() {
        return fileName;
    }

    public double getChannelFrequency() {
        return channelFrequency;
    }

    public void readFromText() throws IOException {
        //gathering parameters from the input file
        InputReader theInputReader=new InputReader(fileName);
        theInputReader.read();

        //Declaring Variable Values from the input file

        endDate= theInputReader.getEndTime();
        noradID=theInputReader.getNoradID();
        errorTimeForTLE=theInputReader.getDopplerErrorTime();
        recordingRate=theInputReader.getRecordingRate();
        channelFrequency=theInputReader.getChannelFrequency();

        initialDate=Utils.getCurrentTime();
    }



    public boolean execute() {

        ///* CASE 4: Mess Bristol , Brockport,   Webster High School:43.204291, -77.469981
        //double[] stationLatitudes= {43.209037, 42.700192,43.204291 };
        //double[] stationLongitudes=  {-77.950921,-77.408628,-77.469981};
        //String[] stationNames={"Brockport University", "Mees Bristol","Webster HS"};
        //double[] stationAltitudes=  {0,  0,  0 };
        //double[] minElevations ={0,0,0};


        //test 2/22/20
        /*
        double[] stationLatitudes= {43.0845};
        double[] stationLongitudes=  {-77.6749};
        String[] stationNames={"rit"};
        double[] stationAltitudes=  {154};
        double[] minElevations ={0};
        //*/
        //test March 16th 2020. Checking NY Triangle "center", and then NY triangle due to Corona Outbreak.
        ///*
        double[] stationLatitudes= {41.9540};
        double[] stationLongitudes=  {-75.2805};
        String[] stationNames={"COVID_Center: (41.9540, -75.2805)"};
        double[] stationAltitudes=  {0};
        double[] minElevations ={0};
        //*/

        /*    NY Triangle 1: Luca, Connor, Anthony
        double[] stationLatitudes= {43.109762, 40.73902 ,39.77444444};
        double[] stationLongitudes=  {-77.410156,-73.14815, -76.67944444};
        String[] stationNames={"Luca: (43.109762, -77.410156)", "Connor: (40.73902,-73.14815)", "Anthony: (39.7744, -76.679444)"};
        double[] stationAltitudes=  {144.5,1.83,304.8};  // [m]
        double[] minElevations ={0,0,0}; // I don't think this array is actually used. There is a "minElevation" variable in "ADcalculator.java"
        //*/

        /*    NY Triangle 2: Luca, Connor, Andrew
        double[] stationLatitudes= {43.109762, 40.73902 ,43.14277778};
        double[] stationLongitudes=  {-77.410156,-73.14815, -73.75333333};
        String[] stationNames={"Luca: (43.109762, -77.410156)", "Connor: (40.73902,-73.14815)", "Andrew: (43.142778, -73.75333)"};
        double[] stationAltitudes=  {144.5,1.83,76.81};  // [m]
        double[] minElevations ={0,0,0}; // I don't think this array is actually used. There is a "minElevation" variable in "ADcalculator.java"
        //*/

        /*    NY Triangle 3: Connor, Anthony, Andrew
        double[] stationLatitudes= {40.73902 ,39.77444444,43.14277778};
        double[] stationLongitudes=  {-73.14815, -76.67944444,-73.75333333};
        String[] stationNames={"Connor: (40.73902,-73.14815)", "Anthony: (39.7744, -76.679444)","Andrew: (43.142778, -73.75333)"};
        double[] stationAltitudes=  {1.83,304.8,76.81};  // [m]
        double[] minElevations ={0,0,0}; // I don't think this array is actually used. There is a "minElevation" variable in "ADcalculator.java"
        //*/

        /*    NY Triangle 4: Luca, Anthony, Andrew
        double[] stationLatitudes= {43.109762,39.77444444,43.14277778};
        double[] stationLongitudes=  {-77.410156,-76.67944444,-73.75333333};
        String[] stationNames={"Luca: (43.109762, -77.410156)", "Anthony: (39.7744, -76.679444)","Andrew: (43.142778, -73.75333)"};
        double[] stationAltitudes=  {144.5,304.8,76.81};  // [m]
        double[] minElevations ={0,0,0}; // I don't think this array is actually used. There is a "minElevation" variable in "ADcalculator.java"
        //*/

        ArrayList<Station> stations=Utils.createStations(false,stationLatitudes,stationLongitudes,stationAltitudes,minElevations,stationNames);

        ADcalculator calc=new ADcalculator(noradID,recordingRate,stations,channelFrequency,errorTimeForTLE);

        calc.computeAccessTimes(initialDate, endDate,true);
        return true;
    }



}
