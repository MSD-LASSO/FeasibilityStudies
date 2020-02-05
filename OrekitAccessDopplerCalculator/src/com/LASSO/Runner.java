package com.LASSO;

import org.orekit.time.AbsoluteDate;

import java.io.FileNotFoundException;
import java.util.ArrayList;

public class Runner {


    private AbsoluteDate initialDate,endDate;

    private int noradID;

    private double TLEestimatedErrorTime;

    private double recordingRate;

    private String fileName;

    //initialDate, endDate, noradID, TLEestimatedErrorTime, recordingRate

    public Runner(String filename){
        this.fileName=filename;
    }


    public boolean execute() throws FileNotFoundException {
        Utils.addOrekitData();

        //gathering parameters from the input file
        InputReader theInputReader=new InputReader(fileName);
        theInputReader.read();

        //Declaring Variable Values from the input file

        double baseFrequency=theInputReader.getBaseFrequency();
        AbsoluteDate endDate= theInputReader.getEndTime();
        int noradID=theInputReader.getNoradID();
        double timeInterval=theInputReader.getTimeInterval();
        double dopplerErrorTime=theInputReader.getDopplerErrorTime();
        double signalBandwidth=theInputReader.getSignalBandwidth();
        double recordTime=theInputReader.getRecordTime();




        ///* CASE 4: Mess Bristol , Brockport,   Webster High School:43.204291, -77.469981
        double[] stationLatitudes= {43.209037, 42.700192,43.204291 };
        double[] stationLongitudes=  {-77.950921,-77.408628,-77.469981};
        String[] stationNames={"Brockport University", "Mees Bristol","Webster HS"};


//        double[] stationLatitudes= {43.1574, 43.1574,43.1574 };
//        double[] stationLongitudes=  {-77.6042,-77.6042,-77.6042};


        double[] stationAltitudes=  {0,  0,  0 };
        double[] minElevations ={0,0,0};


       /*
        TimeScale utc = TimeScalesFactory.getUTC();
        double baseFrequency=437;

        //setting end date for propagation (initial is set in ADcalculator)?
        AbsoluteDate endDate = new AbsoluteDate(2020, 1, 23, 0, 0, 00.000, utc);
        */

        System.out.println("End Date: "+endDate.toString());

        ArrayList<Station> stations=Utils.createStations(false,stationLatitudes,stationLongitudes,stationAltitudes,minElevations,stationNames);

        ADcalculator calc=new ADcalculator(noradID,timeInterval,stations,baseFrequency,dopplerErrorTime,signalBandwidth,recordTime);

        calc.computeAccessTimes(endDate,true);
        return true;
    }



}
