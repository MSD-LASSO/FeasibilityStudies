package com.LASSO;

import org.orekit.data.DataProvidersManager;
import org.orekit.data.DirectoryCrawler;
import org.orekit.propagation.analytical.tle.TLE;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;
import java.time.Instant;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;

//Java location
//C:\Program Files\JetBrains\IntelliJ IDEA Community Edition 2019.3.1\jbr\bin

//jar file
//C:\Users\Acer\IdeaProjects\OrekitAccessDopplerCalculator\out\artifacts\OrekitAccessDopplerCalculator_jar\OrekitAccessDopplerCalculation.jar

//command prompt calls
//cd C:\Program Files\JetBrains\IntelliJ IDEA Community Edition 2019.3.1\jbr\bin
//java -jar C:\Users\Acer\IdeaProjects\OrekitAccessDopplerCalculator\out\artifacts\OrekitAccessDopplerCalculator_jar\OrekitAccessDopplerCalculator.jar

//TODO Orekit-data needs to be on a relative path
//TODO check server java version. This will not run on java before 11.0. Built as is.

public class Main {

    public static void main(String[] args) throws FileNotFoundException {
        Utils.addOrekitData();

        //gathering parameters from the input file
//        String fileName="/Users/mtruong/IdeaProjects/FeasibilityStudies/OrekitAccessDopplerCalculator/LASSO_INPUT.txt";
        String fileName="./LASSO_INPUT.txt";
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
        //*/
        //Consider the below a test.
//        System.out.println("HI Daniel");
//
////        File orekitData = new File("C:\\Users\\Acer\\IdeaProjects\\OrekitAccessDopplerCalculator\\orekit-data-master");
//        File orekitData = new File(".\\orekit-data-master");
//        DataProvidersManager manager = DataProvidersManager.getInstance();
//        manager.addProvider(new DirectoryCrawler(orekitData));

//        try {
//            TLE sat = CelestrakImporter.importSatelliteData(26719);
//            System.out.println(sat.getLine1());
//        } catch (IOException e) {
//            e.printStackTrace();
//        }

    }
}
