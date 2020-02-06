package com.LASSO;

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
            throw new NoradIDnotFoundException("ERROR: 009: Failed to read the LASSO Input.txt. Please verify it has all required inputs: noradID, endDate, errorTimeForTLE, recordingRate, channelFrequency");
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
        recordingRate=theInputReader.getTimeInterval();
        channelFrequency=theInputReader.getBaseFrequency();

        initialDate=Utils.getCurrentTime();
    }



    public boolean execute() {

        ///* CASE 4: Mess Bristol , Brockport,   Webster High School:43.204291, -77.469981
        double[] stationLatitudes= {43.209037, 42.700192,43.204291 };
        double[] stationLongitudes=  {-77.950921,-77.408628,-77.469981};
        String[] stationNames={"Brockport University", "Mees Bristol","Webster HS"};

        double[] stationAltitudes=  {0,  0,  0 };
        double[] minElevations ={0,0,0};


        System.out.println("End Date: "+endDate.toString());

        ArrayList<Station> stations=Utils.createStations(false,stationLatitudes,stationLongitudes,stationAltitudes,minElevations,stationNames);

        ADcalculator calc=new ADcalculator(noradID,recordingRate,stations,channelFrequency,errorTimeForTLE);

        calc.computeAccessTimes(initialDate, endDate,true);
        return true;
    }



}
