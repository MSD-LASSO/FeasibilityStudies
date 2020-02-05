package com.LASSO;

import org.orekit.time.AbsoluteDate;

import java.io.FileNotFoundException;

public class Runner {


    private AbsoluteDate initialDate,endDate;

    private int noradID;

    private double TLEestimatedErrorTime;

    private double recordingRate;

    //initialDate, endDate, noradID, TLEestimatedErrorTime, recordingRate

    public Runner(String filename){
//        this.fileName=filename;
    }


    public boolean execute() throws FileNotFoundException {
        Utils.addOrekitData();

//        //gathering parameters from the input file
//        InputReader theInputReader=new InputReader(fileName);
//        theInputReader.read();
//
//        //Declaring Variable Values from the input file
//
//        double baseFrequency=theInputReader.getBaseFrequency();
//        AbsoluteDate endDate= theInputReader.getEndTime();
//        int noradID=theInputReader.getNoradID();
//        double timeInterval=theInputReader.getTimeInterval();
//        double dopplerErrorTime=theInputReader.getDopplerErrorTime();
//        double signalBandwidth=theInputReader.getSignalBandwidth();
//        double recordTime=theInputReader.getRecordTime();
    }



}
